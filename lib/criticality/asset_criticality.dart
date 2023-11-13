import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iko_reliability_flutter/bin/end_drawer.dart';
import 'package:iko_reliability_flutter/criticality/asset_criticality_notifier.dart';
import 'package:iko_reliability_flutter/settings/settings_notifier.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import '../bin/drawer.dart';
import 'criticality_settings_notifier.dart';
import 'percent_slider.dart';

import '../bin/consts.dart';
import '../bin/db_drift.dart';
import '../main.dart';
import '../settings/theme_manager.dart';
import 'functions.dart';

@RoutePage()
class AssetCriticalityPage extends StatefulWidget {
  const AssetCriticalityPage({super.key});

  @override
  State<AssetCriticalityPage> createState() => _AssetCriticalityPageState();
}

///Widget for asset criticality page
class _AssetCriticalityPageState extends State<AssetCriticalityPage> {
  //table objects
  List<PlutoColumn> columns = [];
  Map<String, AssetCriticalityWithAsset> siteAssets = {};
  Map<String, List<AssetCriticalityWithAsset>> parentAssets = {};
  String loadedSite = '';
  // used to track if update event is done by system or manually
  List<String> systemUpdate = [];

  List<PlutoColumn> detailColumns = [];
  List<PlutoRow> detailRows = [];

  double years = 5;

  Key? currentRowKey;

  late PlutoGridStateManager stateManager;
  late PlutoGridStateManager detailStateManager;

  @override
  void initState() {
    super.initState();

// Columns for Work Orders
    detailColumns.addAll([
      PlutoColumn(
        readOnly: true,
        width: 150,
        title: 'WO Number',
        field: 'wonum',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        readOnly: true,
        width: 300,
        title: 'Description',
        field: 'description',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        width: 100,
        readOnly: true,
        title: 'WO Type',
        field: 'type',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
          width: 100,
          readOnly: true,
          title: 'Status',
          field: 'status',
          type: PlutoColumnType.text()),
      PlutoColumn(
        width: 150,
        readOnly: true,
        title: 'Reported Date',
        field: 'reportdate',
        type: PlutoColumnType.date(
          format: 'yyyy-MM-dd',
        ),
      ),
      PlutoColumn(
        width: 100,
        readOnly: true,
        title: 'Downtime',
        field: 'downtime',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        width: 100,
        readOnly: true,
        title: 'Site',
        field: 'site',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        width: 100,
        readOnly: true,
        title: 'Included',
        field: 'included',
        type: PlutoColumnType.text(),
      ),
    ]);

// Columns for Assets
    columns.addAll([
      PlutoColumn(
        title: '',
        field: 'id',
        type: PlutoColumnType.text(),
        readOnly: true,
        hide: true,
      ),
      PlutoColumn(
        title: 'Hierarchy',
        field: 'hierarchy',
        width: 250,
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        width: 100,
        title: 'Asset Number',
        field: 'assetnum',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
          width: 100,
          title: 'Status',
          field: 'action',
          type: PlutoColumnType.text(),
          renderer: (rendererContext) {
            return Row(
              children: [
                IconButton(
                  tooltip:
                      'Refresh breakdown information from Maximo.\nUpdates child assets if parent selected',
                  icon: const Icon(
                    Icons.refresh,
                  ),
                  onPressed: () {
                    String assetnum =
                        rendererContext.row.cells['assetnum']!.value;
                    refreshAsset(assetnum);
                    //refresh children assets
                    Set<String> childAssetnums = getChildAssetnums(assetnum);
                    for (PlutoRow row in stateManager.iterateAllRowAndGroup) {
                      String tempAssetnum = row.cells['assetnum']!.value;
                      if (childAssetnums.contains(tempAssetnum)) {
                        refreshAsset(tempAssetnum);
                      }
                    }
                  },
                  iconSize: 18,
                  color: Colors.green,
                  padding: const EdgeInsets.all(0),
                ),
                StatusIcon(rendererContext: rendererContext),
              ],
            );
          }),
      PlutoColumn(
        title: 'Description',
        field: 'description',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        width: 100,
        readOnly: true,
        enableAutoEditing: false,
        title: 'Old Criticality',
        field: 'priority',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        width: 400,
        title: 'System',
        field: 'system',
        type: PlutoColumnType.number(),
        renderer: (rendererContext) {
          // change cell to dropdown button
          return Consumer<SelectedSiteNotifier>(
            builder: (context, site, child) {
              return FutureBuilder(
                future:
                    database!.getSystemCriticalitiesFiltered(site.selectedSite),
                builder: (BuildContext context,
                    AsyncSnapshot<List<SystemCriticality>> snapshot) {
                  List<DropdownMenuItem<int>> items = [];
                  if (snapshot.hasData) {
                    if (snapshot.data?.isNotEmpty ?? false) {
                      items =
                          snapshot.data!.map<DropdownMenuItem<int>>((value) {
                        return DropdownMenuItem<int>(
                          value: value.id,
                          child: Text(value.description),
                        );
                      }).toList();
                      items.add(const DropdownMenuItem<int>(
                        value: 0,
                        child: Text(''),
                      ));
                    }
                  }
                  return DropdownButton<int>(
                    value: rendererContext.cell.value,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    isExpanded: true,
                    onChanged: (int? newValue) async {
                      //modify child assets as well. do this before changing the rendererContext.row's cell as to lessen the amount of events triggered
                      String assetnum =
                          rendererContext.row.cells['assetnum']!.value;
                      //refresh children assets
                      Set<String> childAssetnums = getChildAssetnums(assetnum);
                      // update child assets
                      for (PlutoRow row in stateManager.iterateAllRowAndGroup) {
                        String tempAssetnum = row.cells['assetnum']!.value;
                        if (childAssetnums.contains(tempAssetnum)) {
                          PlutoCell? tempCellRef = row.cells['system'];
                          // only update child assets if they don't already have a system
                          if (tempCellRef!.value == 0) {
                            debugPrint('caller A');
                            await database!.updateAssetCriticality(
                              assetid: row.cells['id']!.value,
                              downtime: row.cells['downtime']!.value,
                              system: newValue,
                              frequency: row.cells['frequency']!.value,
                            );
                            setState(() {
                              stateManager.changeCellValue(
                                  tempCellRef, newValue);
                            });
                          }
                        }
                      }
                      // update parent asset
                      debugPrint('caller B');
                      await database!.updateAssetCriticality(
                        assetid: rendererContext.row.cells['id']!.value,
                        downtime: rendererContext.row.cells['downtime']!.value,
                        system: newValue,
                        frequency:
                            rendererContext.row.cells['frequency']!.value,
                      );
                      setState(() {
                        stateManager.changeCellValue(
                            rendererContext.cell, newValue);
                      });
                    },
                    items: items,
                  );
                },
              );
            },
          );
        },
      ),
      PlutoColumn(
        title: 'Frequency of Breakdown',
        field: 'frequency',
        type: PlutoColumnType.number(),
        renderer: (rendererContext) {
          // change cell to dropdown button
          return DropdownButton<int>(
            value: rendererContext.cell.value,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            isExpanded: true,
            onChanged: (int? value) async {
              debugPrint('caller C');
              await database!.updateAssetCriticality(
                assetid: rendererContext.row.cells['id']!.value,
                frequency: value,
                manual: true,
                downtime: rendererContext.row.cells['downtime']!.value,
                system: rendererContext.row.cells['system']!.value,
              );

              if (context.mounted) {
                context.read<AssetOverrideNotifier>().updateAssetOverride(
                  assets: [rendererContext.row.cells['assetnum']!.value],
                  status: AssetOverride.breakdowns,
                );
              }
              setState(() {
                stateManager.changeCellValue(rendererContext.cell, value);
              });
            },
            items: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                .map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(
                    '$value: ${frequencyRating[value]?["description"] ?? ""}'),
              );
            }).toList(),
          );
        },
      ),
      PlutoColumn(
        width: 250,
        title: 'Downtime',
        field: 'downtime',
        type: PlutoColumnType.number(),
        renderer: (rendererContext) {
          // change cell to dropdown button
          return DropdownButton<int>(
            value: rendererContext.cell.value,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            isExpanded: true,
            onChanged: (int? value) async {
              debugPrint('caller D');
              await database!.updateAssetCriticality(
                assetid: rendererContext.row.cells['id']!.value,
                downtime: value,
                manual: true,
                frequency: rendererContext.row.cells['frequency']!.value,
                system: rendererContext.row.cells['system']!.value,
              );
              if (context.mounted) {
                context.read<AssetOverrideNotifier>().updateAssetOverride(
                  assets: [rendererContext.row.cells['assetnum']!.value],
                  status: AssetOverride.breakdowns,
                );
              }
              setState(() {
                stateManager.changeCellValue(rendererContext.cell, value);
              });
            },
            items: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                .map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                  value: value,
                  child: Tooltip(
                    message: impactRating[value]?["longdesc"] ?? '',
                    child: Text(
                        '$value: ${impactRating[value]?["description"] ?? ""}'),
                  ));
            }).toList(),
          );
        },
      ),
      PlutoColumn(
        width: 75,
        title: 'RPN',
        field: 'rpn',
        readOnly: true,
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        width: 150,
        title: 'New Priority',
        field: 'newPriority',
        type: PlutoColumnType.number(),
        renderer: (rendererContext) {
          // change cell to dropdown button
          return DropdownButton<int>(
            value: rendererContext.cell.value,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            isExpanded: true,
            onChanged: (int? value) async {
              debugPrint('caller E');
              await database!.updateAssetCriticality(
                assetid: rendererContext.row.cells['id']!.value,
                newPriority: value,
                downtime: rendererContext.row.cells['downtime']!.value,
                system: rendererContext.row.cells['system']!.value,
                frequency: rendererContext.row.cells['frequency']!.value,
              );
              if (context.mounted) {
                context.read<AssetOverrideNotifier>().updateAssetOverride(
                  assets: [rendererContext.row.cells['assetnum']!.value],
                  status: AssetOverride.priority,
                );
              }
              setState(() {
                stateManager.changeCellValue(rendererContext.cell, value);
              });
            },
            items: [0, ...assetCriticality.keys]
                .map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value: ${assetCriticality[value] ?? ""}'),
              );
            }).toList(),
          );
        },
      ),
      PlutoColumn(
          width: 100,
          title: 'Override',
          field: 'override',
          type: PlutoColumnType.text(),
          renderer: (rendererContext) {
            return Row(
              children: [
                OverrideStatusIcon(rendererContext: rendererContext),
              ],
            );
          }),
    ]);
  }

  void gridAHandler() {
    if (stateManager.currentRow == null) {
      return;
    }
    // if the selected row changes, load WOs for a different asset
    if (stateManager.currentRow!.key != currentRowKey) {
      currentRowKey = stateManager.currentRow!.key;

      detailStateManager.setShowLoading(true);

      fetchWoHistory(stateManager.currentRow!.cells['assetnum']!.value,
          context.read<SelectedSiteNotifier>().selectedSite);
    }
  }

  void fetchWoHistory(String assetnum, String siteid) async {
    var wos = await database!.getAssetWorkorders(assetnum, siteid);
    List<PlutoRow> rows = [];
    List<PlutoRow> excludedRows = [];
    for (var wo in wos) {
      if (isWorkOrderInRange(wo)) {
        rows.add(PlutoRow(
          cells: {
            'wonum': PlutoCell(value: wo.wonum),
            'description': PlutoCell(value: wo.description),
            'type': PlutoCell(value: wo.type),
            'status': PlutoCell(value: wo.status),
            'reportdate': PlutoCell(value: wo.reportdate),
            'downtime': PlutoCell(value: wo.downtime),
            'site': PlutoCell(value: siteIDAndDescription[wo.siteid]),
            'included': PlutoCell(value: ('Yes')),
          },
        ));
      } else {
        excludedRows.add(PlutoRow(
          cells: {
            'wonum': PlutoCell(value: wo.wonum),
            'description': PlutoCell(value: wo.description),
            'type': PlutoCell(value: wo.type),
            'status': PlutoCell(value: wo.status),
            'reportdate': PlutoCell(value: wo.reportdate),
            'downtime': PlutoCell(value: wo.downtime),
            'site': PlutoCell(value: siteIDAndDescription[wo.siteid]),
            'included': PlutoCell(value: ('No')),
          },
        ));
      }
    }

    detailStateManager.removeRows(detailStateManager.rows);
    detailStateManager.resetCurrentState();
    detailStateManager.appendRows([...rows, ...excludedRows]);

    detailStateManager.setShowLoading(false);
  }

  ///Gets a set of assetnums that have [assetnum] as a parent or ancestor.
  ///Recursive method
  Set<String> getChildAssetnums(String assetnum) {
    List<AssetCriticalityWithAsset>? directChilds = parentAssets[assetnum];
    //exit condition
    if (directChilds == null || directChilds.isEmpty) {
      return <String>{};
    }

    Set<String> childSet = {};
    for (AssetCriticalityWithAsset child in directChilds) {
      childSet.add(child.asset.assetnum);
      childSet.addAll(getChildAssetnums(child.asset.assetnum));
    }
    return childSet;
  }

  List<PlutoRow> getChilds(String parent) {
    List<PlutoRow> rows = [];
    if (parentAssets.containsKey(parent)) {
      for (var child in parentAssets[parent]!) {
        double calculatedRPN = child.assetCriticality?.newRPN ?? -1;
        int priorityText = child.assetCriticality?.newPriority ??
            context
                .read<AssetCriticalityNotifier>()
                .rpnFindDistribution(calculatedRPN);
        if (child.assetCriticality?.newPriority != null) {
          context.read<AssetOverrideNotifier>().assets[child.asset.assetnum] =
              AssetOverride.priority;
        }
        if (child.assetCriticality?.manual ?? false) {
          context.read<AssetOverrideNotifier>().assets[child.asset.assetnum] =
              AssetOverride.breakdowns;
        }
        if (calculatedRPN > 0) {
          context.read<AssetStatusNotifier>().assets[child.asset.assetnum] =
              AssetStatus.complete;
        }
        rows.add(PlutoRow(
          cells: {
            'assetnum': PlutoCell(value: child.asset.assetnum),
            'parent': PlutoCell(value: child.asset.parent),
            'description': PlutoCell(value: child.asset.description),
            'priority': PlutoCell(value: child.asset.priority),
            'system': PlutoCell(value: child.systemCriticality?.id ?? 0),
            'action': PlutoCell(value: ''),
            'frequency':
                PlutoCell(value: child.assetCriticality?.frequency ?? 0),
            'downtime': PlutoCell(value: child.assetCriticality?.downtime ?? 0),
            'hierarchy': PlutoCell(value: ''),
            'newPriority': PlutoCell(value: priorityText),
            'rpn': PlutoCell(value: calculatedRPN),
            'id': PlutoCell(value: child.asset.id),
            'override': PlutoCell(value: ''),
          },
          type: PlutoRowType.group(
              expanded: true,
              children: FilteredList<PlutoRow>(
                  initialList: getChilds(child.asset.assetnum))),
        ));
      }
    }
    return rows;
  }

  void refreshAsset(String assetnum) async {
    // if asset has been locked dont refresh
    if (navigatorKey.currentContext!
            .read<AssetOverrideNotifier>()
            .getAssetStatus(assetnum) !=
        AssetOverride.none) {
      return;
    }
    // change status icon
    AssetStatus previousStatus =
        context.read<AssetStatusNotifier>().getAssetStatus(assetnum);
    context.read<AssetStatusNotifier>().updateAssetStatus(
      assets: [assetnum],
      status: AssetStatus.refreshingWorkOrders,
    );
    AssetCriticalitySettingsNotifier assetCriticalitySettings =
        context.read<AssetCriticalitySettingsNotifier>();
    // get all WOs from Maximo
    try {
      await database!.getWorkOrderMaximo(
        assetnum,
        context.read<MaximoServerNotifier>().maximoServerSelected,
      );
    } catch (e) {
      previousStatus = AssetStatus.refreshError;
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(
        content: Text(
            'Error retriving Work Orders from Maximo for: $assetnum \n ${e.toString()}'),
      ));
      return;
    }
    // bring back previous status Icon
    if (context.mounted) {
      context.read<AssetStatusNotifier>().updateAssetStatus(
        assets: [assetnum],
        status: previousStatus,
      );
    }
    var wos = await database!.getAssetWorkorders(assetnum);
    double downtime = 0;
    double dtEvents = 0;

    for (var wo in wos) {
      if (!isWorkOrderInRange(wo)) {
        continue;
      }
      downtime = downtime + wo.downtime;
      dtEvents++;
    }
    downtime = downtime / assetCriticalitySettings.frequencyPeriodYears;
    dtEvents = dtEvents / assetCriticalitySettings.frequencyPeriodYears;
    for (var row in stateManager.iterateRowAndGroup) {
      if (row.cells['assetnum']!.value == assetnum) {
        // update values in db
        debugPrint('caller F');
        await database!.updateAssetCriticality(
          assetid: row.cells['id']!.value,
          frequency: ratingFromValue(dtEvents, frequencyRating),
          downtime: ratingFromValue(downtime, impactRating),
          system: row.cells['system']!.value,
        );
        stateManager.changeCellValue(
            row.cells['downtime']!, ratingFromValue(downtime, impactRating));
        stateManager.changeCellValue(row.cells['frequency']!,
            ratingFromValue(dtEvents, frequencyRating));
      }
    }
  }

  bool isWorkOrderInRange(Workorder workorder) {
    String selectedSite = context.read<SelectedSiteNotifier>().selectedSite;
    AssetCriticalitySettingsNotifier assetCriticalitySettings =
        context.read<AssetCriticalitySettingsNotifier>();
    DateTime reportedDate = DateTime.parse(workorder.reportdate);
    if (reportedDate.compareTo(assetCriticalitySettings.workOrderCutoffStart) <
        0) {
      return false;
    }
    if (reportedDate.compareTo(assetCriticalitySettings.workOrderCutoffEnd) >
        0) {
      return false;
    }
    // check site
    switch (assetCriticalitySettings.workOrderFilterBy) {
      case WorkOrderFilterBy.currentSite:
        if (workorder.siteid != selectedSite) {
          return false;
        }
      default:
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager themeManager = Provider.of<ThemeManager>(context);
    return Scaffold(
      drawer: const Drawer(
        //navigation drawer
        child: NavDrawer(),
      ),
      appBar: AppBar(
        title: const Text('Asset Criticality'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
            ),
          )
        ],
      ),
      endDrawer: const EndDrawer(),
      body: FutureBuilder<List<AssetCriticalityWithAsset>>(
        future: () async {
          context
              .read<AssetCriticalitySettingsNotifier>()
              .setSite(context.watch<SelectedSiteNotifier>().selectedSite);
          return database!.getAssetCriticalities(
              context.watch<SelectedSiteNotifier>().selectedSite);
        }(),
        builder: (BuildContext context,
            AsyncSnapshot<List<AssetCriticalityWithAsset>> snapshot) {
          List<PlutoRow> rows = [];
          if (snapshot.hasData) {
            if (snapshot.data!.isNotEmpty) {
              // only update grid if the selected site is different from what is currently loaded
              // or if grid is marked for update
              if (loadedSite != snapshot.data?.first.asset.siteid ||
                  context.watch<AssetCriticalityNotifier>().updateGrid) {
                debugPrint('Reloading Grid');
                siteAssets = {};
                parentAssets = {};
                for (var row in snapshot.data!) {
                  siteAssets[row.asset.assetnum] = row;
                  if (parentAssets.containsKey(row.asset.parent)) {
                    parentAssets[row.asset.parent]!.add(row);
                  } else {
                    parentAssets[row.asset.parent ?? "Top"] = [row];
                  }
                }
                context
                    .read<AssetStatusNotifier>()
                    .updateParentAssets(parentAssets.keys.toList());
                loadedSite = snapshot.data!.first.asset.siteid;
                rows = getChilds('Top');
                stateManager.removeAllRows();
                stateManager.appendRows(rows);
                //load rpn numbers from plutogrid into AssetCriticalityNotifier
                Map<String, double> newRpnMap = {};
                for (PlutoRow row in stateManager.rows) {
                  if (row.cells['id'] != null) {
                    newRpnMap[row.cells['id']!.value] =
                        (row.cells['rpn']?.value ?? -1) + 0.0;
                  }
                }
                stateManager.toggleExpandedRowGroup(
                    rowGroup: stateManager.rows.first);
                stateManager.toggleExpandedRowGroup(
                    rowGroup: stateManager.rows.first);
                context.watch<AssetCriticalityNotifier>().updateGrid = false;
              }
            }
          } else if (snapshot.hasError) {
            rows.add(PlutoRow(
              cells: {
                'assetnum': PlutoCell(value: 'Error!'),
                'parent': PlutoCell(value: ''),
                'description': PlutoCell(value: snapshot.error),
                'priority': PlutoCell(value: 0),
                'system': PlutoCell(value: 0),
                'action': PlutoCell(value: ''),
                'frequency': PlutoCell(value: 0),
                'downtime': PlutoCell(value: 0),
                'hierarchy': PlutoCell(value: ''),
                'newPriority': PlutoCell(value: 0),
                'rpn': PlutoCell(value: 0),
                'id': PlutoCell(value: ''),
                'override': PlutoCell(value: ''),
              },
            ));
          } else {
            rows.add(PlutoRow(
              cells: {
                'assetnum': PlutoCell(value: ''),
                'parent': PlutoCell(value: ''),
                'description': PlutoCell(value: 'No Site Selected'),
                'priority': PlutoCell(value: 0),
                'system': PlutoCell(value: 0),
                'action': PlutoCell(value: ''),
                'frequency': PlutoCell(value: 0),
                'downtime': PlutoCell(value: 0),
                'hierarchy': PlutoCell(value: ''),
                'newPriority': PlutoCell(value: 0),
                'rpn': PlutoCell(value: 0),
                'id': PlutoCell(value: ''),
                'override': PlutoCell(value: ''),
              },
            ));
          }
          return PlutoDualGrid(
            isVertical: true,
            display: PlutoDualGridDisplayRatio(ratio: 0.75),
            gridPropsA: PlutoDualGridProps(
              columns: columns,
              rows: rows,
              onLoaded: (PlutoGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                context.read<AssetCriticalityNotifier>().stateManager =
                    stateManager;
                event.stateManager.addListener(gridAHandler);
                stateManager.setShowColumnFilter(true);
                stateManager.setRowGroup(PlutoRowGroupTreeDelegate(
                  resolveColumnDepth: (column) =>
                      stateManager.columnIndex(column),
                  showText: (cell) => true,
                  showCount: false,
                  showFirstExpandableIcon: true,
                ));
              },
              onChanged: (PlutoGridOnChangedEvent event) async {
                // recalculate rpn number > nre priority if not overwritten
                if (![5, 6, 7].contains(event.columnIdx)) {
                  // only need to update if changes made to these columns
                  return;
                }
                debugPrint('running grid A on change event');
                AssetCriticalityNotifier assetCriticalityNotifier =
                    context.read<AssetCriticalityNotifier>();
                AssetStatusNotifier assetStatusNotifier =
                    context.read<AssetStatusNotifier>();
                assetCriticalityNotifier.priorityRangesUpToDate = false;
                String rowId = event.row.cells['id']!.value;
                // get data from db and update cache while we are at it
                AssetCriticalityWithAsset assetCrit =
                    await database!.getAssetCriticality(assetid: rowId);
                siteAssets[event.row.cells['assetnum']!.value] = assetCrit;
                // Create an new ACWA object for rpn calculation
                try {
                  double newRpn = rpnFunc(assetCrit) ?? -1;
                  debugPrint('caller C');
                  await database!.updateAssetCriticality(
                    assetid: event.row.cells['id']!.value,
                    downtime: event.row.cells['downtime']!.value,
                    system: event.row.cells['system']!.value,
                    frequency: event.row.cells['frequency']!.value,
                    newRPN: newRpn,
                  );
                  event.row.cells['rpn']!.value = newRpn;
                  assetCriticalityNotifier.addToRpnMap({rowId: newRpn});
                  event.row.cells['newPriority']!.value =
                      assetCrit.assetCriticality?.newPriority ??
                          assetCriticalityNotifier.rpnFindDistribution(newRpn);
                  if (newRpn > 0) {
                    assetStatusNotifier.updateAssetStatus(
                      assets: [event.row.cells['assetnum']!.value],
                      status: AssetStatus.complete,
                    );
                  } else if (assetStatusNotifier.getAssetStatus(
                              event.row.cells['assetnum']!.value) ==
                          AssetStatus.complete &&
                      event.row.cells['newPriority']!.value < 1) {
                    assetStatusNotifier.updateAssetStatus(
                      assets: [event.row.cells['assetnum']!.value],
                      status: AssetStatus.incomplete,
                    );
                  }
                } catch (e) {
                  debugPrint('Failed to calculate RPN number ${e.toString()}');
                }
                // debugPrint('$event');
                // systemUpdate.remove(assetCrit.asset.assetnum);
              },
              configuration: PlutoGridConfiguration(
                  style: themeManager.theme == ThemeMode.dark
                      ? const PlutoGridStyleConfig.dark()
                      : const PlutoGridStyleConfig(),
                  shortcut: PlutoGridShortcut(actions: {
                    ...PlutoGridShortcut.defaultActions,
                    LogicalKeySet(LogicalKeyboardKey.add): CustomAddKeyAction(),
                    LogicalKeySet(LogicalKeyboardKey.numpadAdd):
                        CustomAddKeyAction(),
                    LogicalKeySet(LogicalKeyboardKey.minus):
                        CustomMinusKeyAction(),
                    LogicalKeySet(LogicalKeyboardKey.numpadSubtract):
                        CustomMinusKeyAction(),
                  })),
            ),
            gridPropsB: PlutoDualGridProps(
              configuration: PlutoGridConfiguration(
                  style: themeManager.theme == ThemeMode.dark
                      ? const PlutoGridStyleConfig.dark()
                      : const PlutoGridStyleConfig()),
              columns: detailColumns,
              rows: detailRows,
              onLoaded: (PlutoGridOnLoadedEvent event) {
                detailStateManager = event.stateManager;
              },
              rowColorCallback: (rowColorContext) {
                if (rowColorContext.row.cells['included']!.value != 'Yes') {
                  return Colors.grey;
                }
                return themeManager.theme == ThemeMode.dark
                    ? Colors.black
                    : Colors.white;
              },
            ),
            divider: themeManager.theme == ThemeMode.dark
                ? PlutoDualGridDivider.dark(
                    indicatorColor: Theme.of(context).colorScheme.onBackground)
                : const PlutoDualGridDivider(),
          );
        },
      ),
    );
  }
}

class CustomAddKeyAction extends PlutoGridShortcutAction {
  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    debugPrint('Pressed add key.');
    if (stateManager.currentColumnField != 'frequency' &&
        stateManager.currentColumnField != 'downtime') {
      return;
    }
    if (stateManager.currentCell!.value == 10) {
      return;
    }
    stateManager.changeCellValue(
        stateManager.currentCell!, stateManager.currentCell!.value + 1);
  }
}

class CustomMinusKeyAction extends PlutoGridShortcutAction {
  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    debugPrint('Pressed minus key.');
    if (stateManager.currentColumnField != 'frequency' &&
        stateManager.currentColumnField != 'downtime') {
      return;
    }
    if (stateManager.currentCell!.value == 0) {
      return;
    }
    stateManager.changeCellValue(
        stateManager.currentCell!, stateManager.currentCell!.value - 1);
  }
}

///shows the dialog for changing rpn rating distributions
void showRpnDistDialog(BuildContext context) {
  ///Text for the labels
  const List<String> distGroups = [
    'Very Low',
    'Low',
    'Medium',
    'High',
    'Very High'
  ];
  AssetCriticalitySettingsNotifier settingsNotifier =
      Provider.of<AssetCriticalitySettingsNotifier>(context, listen: false);
  List<TextEditingController> distControllers = [];
  distControllers.add(
      TextEditingController(text: settingsNotifier.percentVLow.toString()));
  distControllers
      .add(TextEditingController(text: settingsNotifier.percentLow.toString()));
  distControllers.add(
      TextEditingController(text: settingsNotifier.percentMedium.toString()));
  distControllers.add(
      TextEditingController(text: settingsNotifier.percentHigh.toString()));
  distControllers.add(
      TextEditingController(text: settingsNotifier.percentVHigh.toString()));

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: RpnDistDialog(
            distGroups: distGroups,
            distControllers: distControllers,
          ),
        );
      });
}

///Shows a dialog alerting users that they haven't updated the 'new priority'calculations yet.
///Returns [true] if user decides to continue export, returns [false] or [null] otherwise
Future<bool> assetCriticalityCSVExportWarning(BuildContext context) async {
  return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Risk Priority Not Calculated'),
              content: const Text(
                  'The new risk priorities have not been calculated yet. This can lead to inaccurate data. Do you still wish to continue?'),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('No')),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Yes'))
              ],
            );
          }) ??
      false;
}

///Dialog for changing rpn rating distributions
class RpnDistDialog extends StatefulWidget {
  const RpnDistDialog({
    super.key,
    required this.distGroups,
    required this.distControllers,
  });

  ///Label text for rating groups, from very low to very high
  final List<String> distGroups;

  ///TextEditingControllers for rating groups' input bar
  final List<TextEditingController> distControllers;

  @override
  State<RpnDistDialog> createState() => _RpnDistDialogState();
}

class _RpnDistDialogState extends State<RpnDistDialog> {
  ///The percent distribution for the rating groups, from very low to very high
  List<int>? dists;

  ///total percent distribution. Should be 100
  int? total;

  String calculationMessage = '';

  ///Calculates the points for the [MultiSlider]
  List<double> calculatePoints() {
    List<double> points = [0];
    double sum = 0;

    for (int i = 0; i < dists!.length - 1; i++) {
      sum += dists![i].toDouble();
      points.add(sum);
      points.add(sum);
    }
    points.add(100);
    return points;
  }

  void reloadTextControllers() {
    for (int i = 0; i < widget.distControllers.length; i++) {
      widget.distControllers[i].text = '${dists![i].toString()}%';
    }
  }

  @override
  void initState() {
    super.initState();
    dists = List.from(
        widget.distControllers.map((element) => int.parse(element.text)));
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in widget.distControllers) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    ///Color gradient for [MultiSlider]. The colors for the range bars are every other item on the list, starting from index = 1
    List<Color> colorGradient = [
      Colors.blue,
      Colors.green,
      Colors.yellow[600]!,
      Colors.orange,
      Colors.red
    ];
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        width: MediaQuery.of(context).size.width * 0.7,
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            const Padding(
              padding: EdgeInsets.only(top: 30.0, left: 30.0, bottom: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Rating Distribution',
                        style: TextStyle(fontSize: 30.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Center(
              // fancy slider
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Builder(builder: (context) {
                  return PercentSlider(
                    initialValues: () {
                      List<int> initValues = [];
                      int sum = 0;
                      for (int i = 0; i < dists!.length - 1; i++) {
                        sum += dists![i];
                        initValues.add(sum);
                      }
                      return initValues;
                    }(),
                    max: total ?? 100,
                    barColors: colorGradient,
                    size: const Size(10, 10),
                    onSliderUpdate: (newPercentDists) {
                      dists = List.from(newPercentDists);
                      setState(() {
                        reloadTextControllers();
                      });
                    },
                    onSliderUpdateEnd: (newPercentDists) async {
                      List<int> dists2 = List.from(newPercentDists);
                      var temp =
                          await calculateRPNDistribution(context, dists2);
                      setState(() {
                        dists = dists2;

                        calculationMessage = temp;
                      });
                    },
                    tooltip: criticalityStrings,
                  );
                }),
              ),
            ),
            Center(
                //print total percentage
                child: Text(
                    'Total Percentage: ${total ?? calculateTotal(dists!)}%')),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: () {
                  List<Widget> widgets = [];
                  for (int i = 0; i < widget.distGroups.length; i++) {
                    widgets.add(Expanded(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: widget.distGroups[i],
                        ),
                        controller: widget.distControllers[i],
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          //limits characters to digits between 0-99
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        onChanged: (value) async {
                          int? val = int.tryParse(value);
                          dists![i] = val ?? 0;
                          var temp =
                              await calculateRPNDistribution(context, dists!);
                          setState(() {
                            dists![i] = val ?? 0;
                            calculationMessage = temp;
                          });
                        },
                      ),
                    )));
                  }
                  return widgets;
                }(),
              ),
            ),
            const Center(child: Text('RPN Cutoffs')),
            Padding(
              padding: const EdgeInsets.all(20),
              child: generateRow(
                  context
                      .read<AssetCriticalityNotifier>()
                      .rpnCutoffs
                      .asMap()
                      .entries
                      .map((e) => RowofTextWidgets(
                          label: '${widget.distGroups[e.key]} Cutoff',
                          value: e.value.toString()))
                      .toList(),
                  5),
            ),
            Center(child: Text(calculationMessage)),
            Expanded(
              //close buttons
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, right: 4.0),
                    child: ElevatedButton(
                      child: const Text('Calculate'),
                      onPressed: () async {
                        var temp =
                            await calculateRPNDistribution(context, dists!);
                        setState(() {
                          calculationMessage = temp;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16.0,
                      left: 4.0,
                    ),
                    child: ElevatedButton(
                      //close button ratings are auto saved
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
                    ),
                  )
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}

///shows the dialog for changing work order settings
void showWOSettingsDialog(BuildContext context) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width * 0.7,
              child: const WorkOrderSettingsDialog()),
        );
      });
}

class WorkOrderSettingsDialog extends StatefulWidget {
  const WorkOrderSettingsDialog({super.key});

  @override
  State<StatefulWidget> createState() => _WorkOrderSettingsDialogState();
}

class _WorkOrderSettingsDialogState extends State<WorkOrderSettingsDialog> {
  ///Exculde all work orders after this date
  DateTime? startDate;

  ///Exclude all work orders before this date
  DateTime? endDate;

  ///whether to show all sites' work orders or not
  WorkOrderFilterBy? siteFilterBy;

  @override
  void initState() {
    super.initState();
    AssetCriticalitySettingsNotifier assetCriticalitySettingsNotifier =
        context.read<AssetCriticalitySettingsNotifier>();
    startDate = assetCriticalitySettingsNotifier.workOrderCutoffStart;
    endDate = assetCriticalitySettingsNotifier.workOrderCutoffEnd;

    siteFilterBy = assetCriticalitySettingsNotifier.workOrderFilterBy;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 40),
                      child: Text(
                        'Breakdown Calculation Settings',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    )
                  ],
                )),
            Expanded(
                flex: 6,
                child: ListView(
                  children: [
                    buildSettingRow(
                        checkbox: Checkbox(
                            value: true, onChanged: (value) => setState(() {})),
                        title: const Text('Ignore Work Orders Before'),
                        valueDisplay:
                            Text(DateFormat('yyyy-MM-dd').format(startDate!)),
                        inputWidget: Builder(
                            builder: (context) => ElevatedButton(
                                onPressed: () async {
                                  DateTime? newDate = await showDatePicker(
                                      context: context,
                                      initialDate: startDate ?? DateTime.now(),
                                      firstDate: DateTime(1951),
                                      lastDate: DateTime.now());
                                  if (newDate != null) {
                                    setState(() {
                                      startDate = newDate;
                                      context
                                          .read<
                                              AssetCriticalitySettingsNotifier>()
                                          .setWOSettings(
                                              selectedSite: context
                                                  .read<SelectedSiteNotifier>()
                                                  .selectedSite,
                                              workOrderCutoffStart: newDate);
                                    });
                                  }
                                },
                                child: const Text('Select Date')))),
                    buildSettingRow(
                        checkbox: Checkbox(
                            value: true, onChanged: (value) => setState(() {})),
                        title: const Text('Ignore Work Orders After'),
                        valueDisplay:
                            Text(DateFormat('yyyy-MM-dd').format(endDate!)),
                        inputWidget: Builder(
                            builder: (context) => ElevatedButton(
                                onPressed: () async {
                                  DateTime? newDate = await showDatePicker(
                                      context: context,
                                      initialDate: endDate ?? DateTime.now(),
                                      firstDate: DateTime(1951),
                                      lastDate: DateTime.now());
                                  if (newDate != null) {
                                    setState(() {
                                      endDate = newDate;
                                      context
                                          .read<
                                              AssetCriticalitySettingsNotifier>()
                                          .setWOSettings(
                                              selectedSite: context
                                                  .read<SelectedSiteNotifier>()
                                                  .selectedSite,
                                              workOrderCutoffEnd: newDate);
                                    });
                                  }
                                },
                                child: const Text('Select Date')))),
                    ListTile(
                      title: const Text('Consider Work Orders from:'),
                      subtitle: Consumer<AssetCriticalitySettingsNotifier>(
                        builder: (context, value, child) {
                          return DropdownButton(
                              isExpanded: true,
                              value: value.workOrderFilterBy,
                              items: WorkOrderFilterBy.values.map((filter) {
                                return DropdownMenuItem(
                                    value: filter,
                                    child: Text(filter.description));
                              }).toList(),
                              onChanged: (WorkOrderFilterBy? newValue) {
                                setState(() {
                                  siteFilterBy = newValue!;
                                  value.setWOSettings(
                                      selectedSite: context
                                          .read<SelectedSiteNotifier>()
                                          .selectedSite,
                                      workOrderFilterBy: newValue);
                                });
                              });
                        },
                      ),
                    )
                  ],
                )),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        if (endDate!.compareTo(startDate!) < 0) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                'End date is before Start date! Please correct dates'),
                          ));
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Confirm')),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSettingRow(
      {Widget? checkbox,
      required Widget title,
      required Widget valueDisplay,
      required Widget inputWidget}) {
    return Row(
      children: [
        Expanded(flex: 1, child: checkbox ?? Container()),
        Expanded(
          flex: 4,
          child: title,
        ),
        Expanded(
          flex: 3,
          child: valueDisplay,
        ),
        Expanded(
          flex: 2,
          child: inputWidget,
        )
      ],
    );
  }
}

Future<String> calculateRPNDistribution(
    BuildContext context, List<int> dists) async {
  if (calculateTotal(dists) != 100) {
    return 'Please make sure percentages add up to 100%';
  }
  try {
    AssetCriticalityNotifier assetCriticalityNotifier =
        context.read<AssetCriticalityNotifier>();
    AssetCriticalitySettingsNotifier assetCriticalitySettingsNotifier =
        context.read<AssetCriticalitySettingsNotifier>();
    assetCriticalitySettingsNotifier.setPercentages(
      selectedSite: context.read<SelectedSiteNotifier>().selectedSite,
      percentVLow: dists[0],
      percentLow: dists[1],
      percentMedium: dists[2],
      percentHigh: dists[3],
      percentVHigh: dists[4],
    );
    //set rpn ranges
    List<double> newCutoffs = calculateRPNCutOffs(
      targetPercentages: assetCriticalitySettingsNotifier.fiveCriticality,
      frequencyOfRPNs: await assetCriticalityNotifier
          .frequencyOfRPNs(context.read<SelectedSiteNotifier>().selectedSite),
    ).ordered();
    assetCriticalityNotifier.setRpnCutoffs(newCutoffs);
    debugPrint('new rpn cutoffs: ${assetCriticalityNotifier.rpnCutoffs}');
    if (newCutoffs.toSet().length != newCutoffs.length) {
      return 'Duplicate values in RPN cutoffs\nIncrease percentage of duplicate value, Or ensure RPN values are more spread out';
    }
    assetCriticalityNotifier.priorityRangesUpToDate = true;
    assetCriticalityNotifier.updateGrid = true;
  } catch (e) {
    debugPrint(e.toString());
    return e.toString();
  }
  return 'RPN cutoffs successfully calculated';
}

class RowofTextWidgets {
  String label;
  String value;

  RowofTextWidgets({
    required this.label,
    required this.value,
  });
}

Widget generateRow(List<RowofTextWidgets> values, [int minFields = 0]) {
  List<Widget> widgets = [];
  for (var i = 0; i < max(minFields, values.length); i++) {
    TextEditingController controller = TextEditingController.fromValue(
        TextEditingValue(text: values.elementAtOrNull(i)?.value ?? ''));
    widgets.add(
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: values.elementAtOrNull(i)?.label,
            ),
            controller: controller,
            keyboardType: TextInputType.number,
            readOnly: true,
          ),
        ),
      ),
    );
  }
  return Row(
    children: widgets,
  );
}

class StatusIcon extends StatefulWidget {
  const StatusIcon({
    super.key,
    required this.rendererContext,
  });

  final PlutoColumnRendererContext rendererContext;

  @override
  State<StatusIcon> createState() => _StatusIconState();
}

class _StatusIconState extends State<StatusIcon> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PlutoGridStateManager stateManager = widget.rendererContext.stateManager;
    AssetStatus status = context
        .watch<AssetStatusNotifier>()
        .getAssetStatus(widget.rendererContext.row.cells['assetnum']!.value);
    Color color = Colors.grey;
    IconData icon = Icons.pending;
    String statusText = '';
    String searchText = '';
    switch (status) {
      case AssetStatus.complete:
        icon = Icons.check_circle;
        color = Colors.green;
        statusText = 'RPN generated';
        searchText = 'complete-child';

      case AssetStatus.incomplete:
        icon = Icons.pending;
        color = Colors.orange;
        statusText = 'Please check columns to generate RPN';
        searchText = 'pending-child';

      case AssetStatus.parentAsset:
        icon = Icons.hide_source;
        color = Colors.grey;
        statusText = 'Parent asset: Not ranked';
        searchText = 'parent';

      case AssetStatus.refreshingWorkOrders:
        icon = Icons.downloading;
        color = Colors.blue;
        statusText = 'Loading...';
        searchText = 'loading-child';

      case AssetStatus.refreshError:
        icon = Icons.error;
        color = Colors.red;
        statusText = 'Error refreshing WOs';
        searchText = 'error-child';
    }
    stateManager.changeCellValue(
      widget.rendererContext.cell,
      searchText,
    );
    return IconButton(
      icon: Icon(
        icon,
        color: color,
      ),
      onPressed: () {},
      tooltip: statusText,
    );
  }
}

class OverrideStatusIcon extends StatefulWidget {
  const OverrideStatusIcon({
    super.key,
    required this.rendererContext,
  });

  final PlutoColumnRendererContext rendererContext;

  @override
  State<OverrideStatusIcon> createState() => _OverrideStatusIconState();
}

class _OverrideStatusIconState extends State<OverrideStatusIcon> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PlutoGridStateManager stateManager = widget.rendererContext.stateManager;
    AssetOverride status = context
        .watch<AssetOverrideNotifier>()
        .getAssetStatus(widget.rendererContext.row.cells['assetnum']!.value);
    Color color = Colors.green;
    IconData icon = Icons.lock_open;
    String statusText = '';
    String searchText = '';
    switch (status) {
      case AssetOverride.none:
        statusText = 'No Overrides';
        searchText = 'none';

      case AssetOverride.priority:
        icon = Icons.lock;
        color = Colors.orange;
        statusText = 'New Priority is overridden';
        searchText = 'priority';

      case AssetOverride.breakdowns:
        icon = Icons.lock_clock;
        color = Colors.orange;
        statusText = 'Breakdown information overridden';
        searchText = 'breakdowns';
    }
    stateManager.changeCellValue(
      widget.rendererContext.cell,
      searchText,
    );
    return IconButton(
      icon: Icon(
        icon,
        color: color,
      ),
      onPressed: () async {
        context.read<AssetOverrideNotifier>().updateAssetOverride(
          assets: [widget.rendererContext.row.cells['assetnum']!.value],
          status: AssetOverride.none,
        );
        await database!.removeAssetOverride(
            assetid: widget.rendererContext.row.cells['id']!.value);
        widget.rendererContext.stateManager.changeCellValue(
          widget.rendererContext.row.cells['frequency']!,
          0,
        );
        widget.rendererContext.stateManager.changeCellValue(
          widget.rendererContext.row.cells['downtime']!,
          0,
        );
        widget.rendererContext.stateManager.changeCellValue(
          widget.rendererContext.row.cells['newPriority']!,
          0,
        );
      },
      tooltip: statusText,
    );
  }
}
