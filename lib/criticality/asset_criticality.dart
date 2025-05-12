import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iko_reliability_flutter/bin/end_drawer.dart';
import 'package:iko_reliability_flutter/criticality/asset_criticality_notifier.dart';
import 'package:iko_reliability_flutter/settings/settings_notifier.dart';
import 'package:intl/intl.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:provider/provider.dart';
import '../bin/common.dart';
import '../bin/drawer.dart';
import 'criticality_settings_notifier.dart';
import 'percent_slider.dart';

import '../bin/consts.dart';
import '../bin/db_drift.dart';
import '../main.dart';
import '../settings/theme_manager.dart';
import 'functions.dart';
import 'system_criticality_notifier.dart';

@RoutePage()
class AssetCriticalityPage extends StatefulWidget {
  const AssetCriticalityPage({super.key});

  @override
  State<AssetCriticalityPage> createState() => _AssetCriticalityPageState();
}

///Widget for asset criticality page
class _AssetCriticalityPageState extends State<AssetCriticalityPage> {
  //table objects
  List<TrinaColumn> columns = [];
  Map<String, AssetCriticalityWithAsset> siteAssets = {};
  Map<String, List<AssetCriticalityWithAsset>> parentAssets = {};
  String loadedSite = '';
  // used to track if update event is done by system or manually
  List<String> systemUpdate = [];

  List<TrinaColumn> detailColumns = [];
  List<TrinaRow> detailRows = [];

  double years = 5;

  Key? currentRowKey;

  late TrinaGridStateManager stateManager;
  late TrinaGridStateManager detailStateManager;

  @override
  void initState() {
    super.initState();

// Columns for Work Orders
    detailColumns.addAll([
      TrinaColumn(
        readOnly: true,
        width: 150,
        title: 'WO Number',
        field: 'wonum',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        readOnly: true,
        width: 300,
        title: 'Description',
        field: 'description',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        width: 100,
        readOnly: true,
        title: 'WO Type',
        field: 'type',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
          width: 100,
          readOnly: true,
          title: 'Status',
          field: 'status',
          type: TrinaColumnType.text()),
      TrinaColumn(
        width: 150,
        readOnly: true,
        title: 'Reported Date',
        field: 'reportdate',
        type: TrinaColumnType.date(
          format: 'yyyy-MM-dd',
        ),
      ),
      TrinaColumn(
        width: 100,
        readOnly: true,
        title: 'Downtime Per Event',
        field: 'downtime',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        width: 100,
        readOnly: true,
        title: 'Site',
        field: 'site',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        width: 100,
        readOnly: true,
        title: 'Included',
        field: 'included',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        width: 400,
        readOnly: true,
        title: 'Details',
        field: 'details',
        type: TrinaColumnType.text(),
      ),
    ]);

// Columns for Assets
    columns.addAll([
      TrinaColumn(
        title: '',
        field: 'id',
        type: TrinaColumnType.text(),
        readOnly: true,
        hide: true,
      ),
      TrinaColumn(
          title: 'Hierarchy (Parent Filter)',
          field: 'hierarchy',
          width: 250,
          type: TrinaColumnType.text(),
          renderer: (rendererContext) {
            return Container();
          }),
      TrinaColumn(
        width: 100,
        title: 'Asset Number',
        field: 'assetnum',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
          width: 100,
          title: 'Status',
          field: 'action',
          type: TrinaColumnType.text(),
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
                    Set<String> childAssetnums =
                        getChildAssetnums(assetnum, parentAssets);
                    for (TrinaRow row in stateManager.iterateAllRowAndGroup) {
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
      TrinaColumn(
        title: 'Description',
        field: 'description',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        width: 100,
        readOnly: true,
        enableAutoEditing: false,
        title: 'Old Criticality',
        field: 'priority',
        type: TrinaColumnType.number(),
      ),
      TrinaColumn(
        width: 400,
        title: 'System',
        field: 'system',
        checkReadOnly: (row, cell) => assetEditCheck(row),
        type: TrinaColumnType.number(),
        renderer: (rendererContext) {
          // change cell to dropdown button
          return Consumer<SelectedSiteNotifier>(
              builder: (context, site, child) {
            return FutureBuilder(
              future: () async {
                if (context.read<SystemCriticalityNotifier>().selectedSite ==
                    site.selectedSite) {
                  return context.read<SystemCriticalityNotifier>().systems;
                }
                return database!
                    .getSystemCriticalitiesFiltered(site.selectedSite);
              }(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<SystemCriticality>> snapshot) {
                List<DropdownMenuItem<int>> items = [];
                if (snapshot.hasData) {
                  if (snapshot.data?.isNotEmpty ?? false) {
                    items = snapshot.data!.map<DropdownMenuItem<int>>((value) {
                      return DropdownMenuItem<int>(
                        value: value.id,
                        child: Text(value.description),
                      );
                    }).toList();
                    items.add(const DropdownMenuItem<int>(
                      value: 0,
                      child: Text(''),
                    ));
                    context.read<SystemCriticalityNotifier>().selectedSite =
                        site.selectedSite;
                    context.read<SystemCriticalityNotifier>().systems =
                        snapshot.data!;
                  }
                }
                return SystemDropdown(
                    rendererContext: rendererContext,
                    items: items,
                    parentAssets: parentAssets);
              },
            );
          });
        },
      ),
      TrinaColumn(
        title: 'Functional Failure Frequency',
        field: 'frequency',
        type: TrinaColumnType.number(),
        renderer: (rendererContext) {
          // change cell to dropdown button
          return DropdownButton<int>(
            value: rendererContext.cell.value,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            disabledHint: const Text('Parent Asset'),
            isExpanded: true,
            onChanged: rendererContext.row.cells['action']!.value == 'parent'
                ? null
                : (int? value) async {
                    debugPrint('caller C');
                    await database!.updateAssetCriticality(
                      assetid: rendererContext.row.cells['id']!.value,
                      frequency: value,
                      manual: true,
                      downtime: rendererContext.row.cells['downtime']!.value,
                      system: rendererContext.row.cells['system']!.value,
                      type: rendererContext.row.cells['assetnum']!.value,
                    );

                    if (mounted) {
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
      TrinaColumn(
        width: 250,
        title: 'Downtime Impact',
        field: 'downtime',
        type: TrinaColumnType.number(),
        renderer: (rendererContext) {
          // change cell to dropdown button
          return DropdownButton<int>(
            value: rendererContext.cell.value,
            icon: const Icon(Icons.arrow_downward),
            disabledHint: const Text('Parent Asset'),
            elevation: 16,
            isExpanded: true,
            onChanged: rendererContext.row.cells['action']!.value == 'parent'
                ? null
                : (int? value) async {
                    debugPrint('caller D');
                    await database!.updateAssetCriticality(
                      assetid: rendererContext.row.cells['id']!.value,
                      downtime: value,
                      manual: true,
                      frequency: rendererContext.row.cells['frequency']!.value,
                      system: rendererContext.row.cells['system']!.value,
                      type: rendererContext.row.cells['assetnum']!.value,
                    );
                    if (mounted) {
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
      TrinaColumn(
        width: 250,
        title: 'Early Detection Effectiveness',
        field: 'earlyDetection',
        enableAutoEditing: true,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        width: 75,
        title: 'RPN',
        field: 'rpn',
        readOnly: true,
        type: TrinaColumnType.number(),
      ),
      TrinaColumn(
        width: 150,
        title: 'New Priority',
        field: 'newPriority',
        type: TrinaColumnType.number(),
        renderer: (rendererContext) {
          // change cell to dropdown button
          return DropdownButton<int>(
            value: rendererContext.cell.value,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            disabledHint: const Text('Parent Asset'),
            isExpanded: true,
            onChanged: rendererContext.row.cells['action']!.value == 'parent'
                ? null
                : (int? value) async {
                    debugPrint('caller E');
                    await database!.updateAssetCriticality(
                      assetid: rendererContext.row.cells['id']!.value,
                      newPriority: value,
                      downtime: rendererContext.row.cells['downtime']!.value,
                      system: rendererContext.row.cells['system']!.value,
                      type: rendererContext.row.cells['assetnum']!.value,
                      frequency: rendererContext.row.cells['frequency']!.value,
                      manualPriority: true,
                    );
                    if (mounted) {
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
      TrinaColumn(
          width: 100,
          title: 'Override',
          field: 'override',
          type: TrinaColumnType.text(),
          renderer: (rendererContext) {
            return Row(
              children: [
                OverrideStatusIcon(rendererContext: rendererContext),
              ],
            );
          }),
      TrinaColumn(
          width: 100,
          title: 'System Locked',
          field: 'lockedSystem',
          type: TrinaColumnType.text(),
          renderer: (rendererContext) {
            Color color = Colors.green;
            IconData icon = Icons.lock_open;
            String statusText = 'System can be freely changed';
            String searchText = rendererContext.cell.value;
            if (searchText == 'locked') {
              color = Colors.red;
              icon = Icons.lock;
              statusText = 'System has been pre-assigned by Corporate';
            }
            return Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    icon,
                    color: color,
                  ),
                  tooltip: statusText,
                )
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

      fetchWoHistory(stateManager.currentRow!.cells['assetnum']!.value);
    }
  }

  void fetchWoHistory(String assetnum) async {
    var wos = await database!.getAssetWorkorders(assetnum);
    List<TrinaRow> rows = [];
    List<TrinaRow> excludedRows = [];
    for (var wo in wos) {
      if (isWorkOrderInRange(wo)) {
        rows.add(TrinaRow(
          cells: {
            'wonum': TrinaCell(value: wo.wonum),
            'description': TrinaCell(value: wo.description),
            'type': TrinaCell(value: wo.type),
            'status': TrinaCell(value: wo.status),
            'reportdate': TrinaCell(value: wo.reportdate),
            'downtime': TrinaCell(value: wo.downtime),
            'site': TrinaCell(value: siteIDAndDescription[wo.siteid]),
            'included': TrinaCell(value: ('Yes')),
            'details': TrinaCell(value: wo.details),
          },
        ));
      } else {
        excludedRows.add(TrinaRow(
          cells: {
            'wonum': TrinaCell(value: wo.wonum),
            'description': TrinaCell(value: wo.description),
            'type': TrinaCell(value: wo.type),
            'status': TrinaCell(value: wo.status),
            'reportdate': TrinaCell(value: wo.reportdate),
            'downtime': TrinaCell(value: wo.downtime),
            'site': TrinaCell(value: siteIDAndDescription[wo.siteid]),
            'included': TrinaCell(value: ('No')),
            'details': TrinaCell(value: wo.details),
          },
        ));
      }
    }

    detailStateManager.removeRows(detailStateManager.rows);
    detailStateManager.resetCurrentState();
    detailStateManager.appendRows([...rows, ...excludedRows]);

    detailStateManager.setShowLoading(false);
  }

  List<TrinaRow> getChilds(String parent) {
    List<TrinaRow> rows = [];
    var f = NumberFormat('##0.0%');
    if (parentAssets.containsKey(parent)) {
      for (var child in parentAssets[parent]!) {
        double calculatedRPN = child.assetCriticality?.newRPN ?? -1;
        int priorityText = child.assetCriticality?.newPriority ?? 0;
        if (child.assetCriticality?.manualPriority ?? false) {
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
        rows.add(TrinaRow(
          cells: {
            'assetnum': TrinaCell(value: child.asset.assetnum),
            'parent': TrinaCell(value: child.asset.parent),
            'description': TrinaCell(value: child.asset.description),
            'priority': TrinaCell(value: child.asset.priority),
            'system': TrinaCell(value: child.systemCriticality?.id ?? 0),
            'action': TrinaCell(value: ''),
            'frequency':
                TrinaCell(value: child.assetCriticality?.frequency ?? 0),
            'downtime': TrinaCell(value: child.assetCriticality?.downtime ?? 0),
            'earlyDetection': TrinaCell(
                value: f.format(child.assetCriticality?.earlyDetection ?? 0)),
            'hierarchy': TrinaCell(value: child.asset.hierarchy ?? ''),
            'newPriority': TrinaCell(value: priorityText),
            'rpn': TrinaCell(value: calculatedRPN),
            'id': TrinaCell(value: child.asset.id),
            'lockedSystem': TrinaCell(
                value: child.assetCriticality?.lockedSystem ?? false
                    ? 'locked'
                    : 'open'),
            'override': TrinaCell(value: ''),
          },
          type: TrinaRowType.group(
              expanded: true,
              children: FilteredList<TrinaRow>(
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
    // don't update for parent assets
    if (previousStatus == AssetStatus.parentAsset) {
      return;
    }
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
      throw Exception(
          'Error retriving Work Orders from Maximo for: $assetnum \n ${e.toString()}}');
    }
    // bring back previous status Icon
    if (mounted) {
      context.read<AssetStatusNotifier>().updateAssetStatus(
        assets: [assetnum],
        status: previousStatus,
      );
    }
    var wos = await database!.getAssetWorkorders(assetnum);
    double downtime = 0;
    double dtEvents = 0;
    double followUps = 0;

    for (var wo in wos) {
      if (!isWorkOrderInRange(wo)) {
        continue;
      }
      downtime = downtime + wo.downtime;
      dtEvents++;
      if (wo.recordType == 'FollowUp') {
        followUps++;
      }
    }
    downtime = downtime;
    followUps = followUps / dtEvents;
    if (!followUps.isFinite) {
      followUps = 0;
    }
    dtEvents = dtEvents / assetCriticalitySettings.frequencyPeriodYears;
    for (var row in stateManager.iterateRowAndGroup) {
      if (row.cells['assetnum']!.value == assetnum) {
        // update values in db
        debugPrint('caller F');
        await database!.updateAssetCriticality(
          assetid: row.cells['id']!.value,
          frequency: ratingFromValue(dtEvents, frequencyRating),
          downtime: ratingFromValue(downtime, impactRating),
          earlyDetection: followUps,
          system: row.cells['system']!.value,
          type: row.cells['assetnum']!.value,
        );
        stateManager.changeCellValue(
            row.cells['downtime']!, ratingFromValue(downtime, impactRating));
        stateManager.changeCellValue(row.cells['frequency']!,
            ratingFromValue(dtEvents, frequencyRating));
        var f = NumberFormat('##0.0%');
        stateManager.changeCellValue(
            row.cells['earlyDetection']!, f.format(followUps));
      }
    }
  }

  bool isWorkOrderInRange(Workorder workorder) {
    String selectedSite = context.read<SelectedSiteNotifier>().selectedSite;
    AssetCriticalitySettingsNotifier assetCriticalitySettings =
        context.read<AssetCriticalitySettingsNotifier>();
    if (workorder.status != 'CLOSE') {
      return false;
    }
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
          List<TrinaRow> rows = [];
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
                //load rpn numbers from Trinagrid into AssetCriticalityNotifier
                Map<String, double> newRpnMap = {};
                for (TrinaRow row in stateManager.rows) {
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
            rows.add(TrinaRow(
              cells: {
                'assetnum': TrinaCell(value: 'Error!'),
                'parent': TrinaCell(value: ''),
                'description': TrinaCell(value: snapshot.error),
                'priority': TrinaCell(value: 0),
                'system': TrinaCell(value: 0),
                'action': TrinaCell(value: ''),
                'frequency': TrinaCell(value: 0),
                'earlyDetection': TrinaCell(value: "0%"),
                'downtime': TrinaCell(value: 0),
                'hierarchy': TrinaCell(value: ''),
                'newPriority': TrinaCell(value: 0),
                'rpn': TrinaCell(value: 0),
                'id': TrinaCell(value: ''),
                'lockedSystem': TrinaCell(value: 'open'),
                'override': TrinaCell(value: ''),
              },
            ));
          } else {
            rows.add(TrinaRow(
              cells: {
                'assetnum': TrinaCell(value: ''),
                'parent': TrinaCell(value: ''),
                'description': TrinaCell(value: 'No Site Selected'),
                'priority': TrinaCell(value: 0),
                'system': TrinaCell(value: 0),
                'action': TrinaCell(value: ''),
                'frequency': TrinaCell(value: 0),
                'earlyDetection': TrinaCell(value: "0%"),
                'downtime': TrinaCell(value: 0),
                'hierarchy': TrinaCell(value: ''),
                'newPriority': TrinaCell(value: 0),
                'rpn': TrinaCell(value: 0),
                'id': TrinaCell(value: ''),
                'lockedSystem': TrinaCell(value: 'open'),
                'override': TrinaCell(value: ''),
              },
            ));
          }
          return TrinaDualGrid(
            isVertical: true,
            display: TrinaDualGridDisplayRatio(ratio: 0.75),
            gridPropsA: TrinaDualGridProps(
              columns: columns,
              rows: rows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                context.read<AssetCriticalityNotifier>().stateManager =
                    stateManager;
                event.stateManager.addListener(gridAHandler);
                stateManager.setShowColumnFilter(true);
                stateManager.setRowGroup(TrinaRowGroupTreeDelegate(
                  resolveColumnDepth: (column) =>
                      stateManager.columnIndex(column),
                  showText: (cell) => true,
                  showCount: false,
                  showFirstExpandableIcon: true,
                ));
              },
              onChanged: (TrinaGridOnChangedEvent event) async {
                // recalculate rpn number > nre priority if not overwritten
                if (![5, 6, 7, 8].contains(event.columnIdx)) {
                  // only need to update if changes made to these columns
                  return;
                }
                double? earlyDetection =
                    double.tryParse(event.value.toString().split('%')[0]);
                if (event.column.field == 'earlyDetection') {
                  if (earlyDetection == null) {
                    event.row.cells['earlyDetection']!.value = event.oldValue;
                    earlyDetection = double.tryParse(
                        event.oldValue.toString().split('%')[0]);
                    toast(context,
                        'Invalid value entered for Early Detection Effectiveness, reverted to previous value.');
                  } else {
                    if (earlyDetection < 0) {
                      earlyDetection = 0;
                    } else if (earlyDetection < 0.99) {
                    } else if (earlyDetection < 100) {
                      earlyDetection = earlyDetection / 100;
                    } else {
                      earlyDetection = 0.99;
                    }
                    var f = NumberFormat('##0.0%');
                    event.row.cells['earlyDetection']!.value =
                        f.format(earlyDetection);
                    await database!.updateAssetCriticality(
                      assetid: event.row.cells['id']!.value,
                      downtime: event.row.cells['downtime']!.value,
                      system: event.row.cells['system']!.value,
                      frequency: event.row.cells['frequency']!.value,
                      earlyDetection: earlyDetection,
                      type: event.row.cells['assetnum']!.value,
                    );
                  }
                }
                debugPrint('running grid A on change event');
                if (!context.mounted) {
                  return;
                }
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
                  debugPrint('caller G');
                  await database!.updateAssetCriticality(
                    assetid: event.row.cells['id']!.value,
                    downtime: event.row.cells['downtime']!.value,
                    system: event.row.cells['system']!.value,
                    frequency: event.row.cells['frequency']!.value,
                    type: event.row.cells['assetnum']!.value,
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
              configuration: TrinaGridConfiguration(
                  style: themeManager.theme == ThemeMode.dark
                      ? const TrinaGridStyleConfig.dark()
                      : const TrinaGridStyleConfig(),
                  shortcut: TrinaGridShortcut(actions: {
                    ...TrinaGridShortcut.defaultActions,
                    LogicalKeySet(LogicalKeyboardKey.add): CustomAddKeyAction(),
                    LogicalKeySet(LogicalKeyboardKey.numpadAdd):
                        CustomAddKeyAction(),
                    LogicalKeySet(LogicalKeyboardKey.minus):
                        CustomMinusKeyAction(),
                    LogicalKeySet(LogicalKeyboardKey.numpadSubtract):
                        CustomMinusKeyAction(),
                  })),
            ),
            gridPropsB: TrinaDualGridProps(
              configuration: TrinaGridConfiguration(
                  // columnFilter: TrinaGridColumnFilterConfig(),
                  style: themeManager.theme == ThemeMode.dark
                      ? const TrinaGridStyleConfig.dark()
                      : const TrinaGridStyleConfig()),
              columns: detailColumns,
              rows: detailRows,
              onLoaded: (TrinaGridOnLoadedEvent event) {
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
                ? TrinaDualGridDivider.dark(
                    indicatorColor: Theme.of(context).colorScheme.onSurface)
                : const TrinaDualGridDivider(),
          );
        },
      ),
    );
  }
}

class CustomAddKeyAction extends TrinaGridShortcutAction {
  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) async {
    debugPrint('Pressed add key.');
    if (stateManager.currentColumnField != 'frequency' &&
        stateManager.currentColumnField != 'downtime') {
      return;
    }
    if (stateManager.currentCell!.value == 10) {
      return;
    }
    debugPrint('caller H');
    await database!.updateAssetCriticality(
      assetid: stateManager.currentRow!.cells['id']!.value,
      downtime: stateManager.currentColumnField == 'downtime'
          ? stateManager.currentCell!.value + 1
          : stateManager.currentRow!.cells['downtime']!.value,
      manual: true,
      frequency: stateManager.currentColumnField == 'frequency'
          ? stateManager.currentCell!.value + 1
          : stateManager.currentRow!.cells['frequency']!.value,
      system: stateManager.currentRow!.cells['system']!.value,
      type: stateManager.currentRow!.cells['assetnum']!.value,
    );
    stateManager.changeCellValue(
        stateManager.currentCell!, stateManager.currentCell!.value + 1);
  }
}

class CustomMinusKeyAction extends TrinaGridShortcutAction {
  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
  }) async {
    debugPrint('Pressed minus key.');
    if (stateManager.currentColumnField != 'frequency' &&
        stateManager.currentColumnField != 'downtime') {
      return;
    }
    if (stateManager.currentCell!.value == 0) {
      return;
    }
    debugPrint('caller I');
    await database!.updateAssetCriticality(
      assetid: stateManager.currentRow!.cells['id']!.value,
      downtime: stateManager.currentColumnField == 'downtime'
          ? stateManager.currentCell!.value - 1
          : stateManager.currentRow!.cells['downtime']!.value,
      manual: true,
      frequency: stateManager.currentColumnField == 'frequency'
          ? stateManager.currentCell!.value - 1
          : stateManager.currentRow!.cells['frequency']!.value,
      system: stateManager.currentRow!.cells['system']!.value,
      type: stateManager.currentRow!.cells['assetnum']!.value,
    );
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
                      child: const Text('Calculate RPN Cutoffs'),
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
                    padding: const EdgeInsets.only(bottom: 16.0, right: 4.0),
                    child: ElevatedButton(
                      child: const Text('Save Criticality'),
                      onPressed: () async {
                        var temp = await assignNewCriticality(
                            context.read<AssetCriticalityNotifier>().rpnCutoffs,
                            context.read<SelectedSiteNotifier>().selectedSite);
                        setState(() {
                          calculationMessage = '$temp';
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
  showDataAlert(
    [
      'Please use the "Refresh" button for each asset after changing settings',
    ],
    'Work Order History Calculation Settings',
    [const WorkOrderSettingsDialog()],
  );
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

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController siteFilterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AssetCriticalitySettingsNotifier assetCriticalitySettingsNotifier =
        context.read<AssetCriticalitySettingsNotifier>();
    startDate = assetCriticalitySettingsNotifier.workOrderCutoffStart;
    endDate = assetCriticalitySettingsNotifier.workOrderCutoffEnd;
    siteFilterBy = assetCriticalitySettingsNotifier.workOrderFilterBy;
    startDateController.text = DateFormat('yyyy-MM-dd').format(startDate!);
    endDateController.text = DateFormat('yyyy-MM-dd').format(endDate!);
    siteFilterController.text = siteFilterBy.toString();
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    siteFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssetCriticalitySettingsNotifier>(
        builder: (context, notifier, child) {
      return Column(
        children: [
          TextField(
            controller: startDateController,
            decoration: const InputDecoration(
                icon: Icon(Icons.calendar_month),
                labelText: 'Ignore Work Orders Before'),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: startDate,
                  firstDate: DateTime(1951),
                  //DateTime.now() - not to allow to choose before today.
                  lastDate: DateTime.now());
              if (pickedDate != null) {
                setState(() {
                  startDateController.text =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                  //set output date to TextField value.
                  notifier.setWOSettings(
                      selectedSite:
                          context.read<SelectedSiteNotifier>().selectedSite,
                      workOrderCutoffStart: pickedDate);
                });
              }
            },
          ),
          TextField(
            controller: endDateController,
            decoration: const InputDecoration(
                icon: Icon(Icons.calendar_month),
                labelText: 'Ignore Work Orders After'),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: endDate,
                  firstDate: DateTime(1951),
                  //DateTime.now() - not to allow to choose before today.
                  lastDate: DateTime.now());
              if (pickedDate != null) {
                setState(() {
                  endDateController.text =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                  //set output date to TextField value.
                  notifier.setWOSettings(
                      selectedSite:
                          context.read<SelectedSiteNotifier>().selectedSite,
                      workOrderCutoffEnd: pickedDate);
                });
              }
            },
          ),
          ListTile(
              title: const Text('Work Order Site Filter'),
              leading: const Icon(Icons.map),
              subtitle: DropdownButton(
                  isExpanded: true,
                  value: siteFilterBy,
                  items: WorkOrderFilterBy.values.map((filter) {
                    return DropdownMenuItem(
                        value: filter, child: Text(filter.description));
                  }).toList(),
                  onChanged: (WorkOrderFilterBy? newValue) {
                    setState(() {
                      siteFilterBy = newValue!;
                      notifier.setWOSettings(
                          selectedSite:
                              context.read<SelectedSiteNotifier>().selectedSite,
                          workOrderFilterBy: newValue);
                    });
                  })),
        ],
      );
    });
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
    BuildContext context, List<int> selectedPercentDistribution) async {
  if (calculateTotal(selectedPercentDistribution) != 100) {
    return 'Please make sure percentages add up to 100%';
  }
  try {
    AssetCriticalityNotifier assetCriticalityNotifier =
        context.read<AssetCriticalityNotifier>();
    AssetCriticalitySettingsNotifier assetCriticalitySettingsNotifier =
        context.read<AssetCriticalitySettingsNotifier>();
    assetCriticalitySettingsNotifier.setPercentages(
      selectedSite: context.read<SelectedSiteNotifier>().selectedSite,
      percentVLow: selectedPercentDistribution[0],
      percentLow: selectedPercentDistribution[1],
      percentMedium: selectedPercentDistribution[2],
      percentHigh: selectedPercentDistribution[3],
      percentVHigh: selectedPercentDistribution[4],
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

/// assign criticality to all assets based on rpn number
/// special logic to have ~150 shingle assets be set as VH + H
Future<int> assignNewCriticality(List<double> rpnCutoffs, String siteid) async {
  var shingle140 = 0;
  var shingle55 = 0;
  if (rpnCutoffs.length != 5) {
    throw Exception('Unexpected format for List [rpnCutoffs]');
  }
  var criticalitys = await database!.assetCriticalityOrdered(siteid).get();
  var updates = [];
  for (var criticality in criticalitys) {
    var newCriticality = 0;
    for (int i = rpnCutoffs.length - 1; i >= 0; i--) {
      if (criticality.newRPN <= rpnCutoffs[i]) {
        newCriticality = assetCriticality.keys.elementAt(i);
      }
    }
    if (criticality.asset.substring(2, 3) == 'S') {
      if (shingle55 < 55) {
        shingle55++;
        shingle140++;
        newCriticality = 9;
      } else if (shingle140 < 140) {
        shingle140++;
        newCriticality = 7;
      } else if (newCriticality > 5) {
        newCriticality = 5;
      }
    }
    updates.add([criticality.asset, newCriticality]);
  }
  await database!.batchUpdateAssetNewCriticality(criticalityUpdates: updates);
  return updates.length;
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

  final TrinaColumnRendererContext rendererContext;

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
    TrinaGridStateManager stateManager = widget.rendererContext.stateManager;
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

  final TrinaColumnRendererContext rendererContext;

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
    TrinaGridStateManager stateManager = widget.rendererContext.stateManager;
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

class SystemDropdown extends StatefulWidget {
  const SystemDropdown({
    super.key,
    required this.rendererContext,
    required this.items,
    required this.parentAssets,
  });

  final TrinaColumnRendererContext rendererContext;
  final List<DropdownMenuItem<int>> items;
  final Map<String, List<AssetCriticalityWithAsset>> parentAssets;

  @override
  State<SystemDropdown> createState() => _SystemDropdownState();
}

class _SystemDropdownState extends State<SystemDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: widget.rendererContext.cell.value,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      isExpanded: true,
      disabledHint: const Text('Loading Systems...'),
      onChanged: widget.rendererContext.row.cells['lockedSystem']?.value ==
              'locked'
          ? null
          : (int? newValue) async {
              //modify child assets as well. do this before changing the rendererContext.row's cell as to lessen the amount of events triggered
              String assetnum =
                  widget.rendererContext.row.cells['assetnum']!.value;
              //refresh children assets
              Set<String> childAssetnums =
                  getChildAssetnums(assetnum, widget.parentAssets);
              // update child assets
              for (TrinaRow row in widget
                  .rendererContext.stateManager.iterateAllRowAndGroup) {
                String tempAssetnum = row.cells['assetnum']!.value;
                if (childAssetnums.contains(tempAssetnum)) {
                  TrinaCell? tempCellRef = row.cells['system'];
                  // only update child assets if they don't already have a system
                  if (tempCellRef!.value == 0 &&
                      row.cells['lockedSystem']!.value == 'open') {
                    debugPrint('caller A');
                    await database!.updateAssetCriticality(
                      assetid: row.cells['id']!.value,
                      downtime: row.cells['downtime']!.value,
                      system: newValue,
                      frequency: row.cells['frequency']!.value,
                      type: row.cells['assetnum']!.value,
                    );
                    if (mounted) {
                      setState(() {
                        widget.rendererContext.stateManager
                            .changeCellValue(tempCellRef, newValue);
                      });
                    }
                  }
                }
              }
              // update parent asset
              debugPrint('caller B');
              await database!.updateAssetCriticality(
                assetid: widget.rendererContext.row.cells['id']!.value,
                downtime: widget.rendererContext.row.cells['downtime']!.value,
                system: newValue,
                type: widget.rendererContext.row.cells['assetnum']!.value,
                frequency: widget.rendererContext.row.cells['frequency']!.value,
              );
              if (mounted) {
                setState(() {
                  widget.rendererContext.stateManager
                      .changeCellValue(widget.rendererContext.cell, newValue);
                });
              }
            },
      items: widget.items,
    );
  }
}

///Gets a set of assetnums that have [assetnum] as a parent or ancestor.
///Recursive method
Set<String> getChildAssetnums(String assetnum,
    Map<String, List<AssetCriticalityWithAsset>> parentAssets) {
  List<AssetCriticalityWithAsset>? directChilds = parentAssets[assetnum];
  //exit condition
  if (directChilds == null || directChilds.isEmpty) {
    return <String>{};
  }

  Set<String> childSet = {};
  for (AssetCriticalityWithAsset child in directChilds) {
    childSet.add(child.asset.assetnum);
    childSet.addAll(getChildAssetnums(child.asset.assetnum, parentAssets));
  }
  return childSet;
}

class AssetCriticalityLoadingIndicator extends StatefulWidget {
  const AssetCriticalityLoadingIndicator({super.key});

  @override
  State<AssetCriticalityLoadingIndicator> createState() =>
      _AssetCriticalityLoadingIndicatorState();
}

class _AssetCriticalityLoadingIndicatorState
    extends State<AssetCriticalityLoadingIndicator> {
  String message = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    if (context.watch<SelectedSiteNotifier>().selectedSite.isEmpty) {
      return const SiteToggle();
    }
    assetLoading(
      siteid: context.read<SelectedSiteNotifier>().selectedSite,
      env: context.read<MaximoServerNotifier>().maximoServerSelected,
    );
    return Text(message);
  }

  Future<void> assetLoading(
      {required String siteid, required String env}) async {
    if (loading) {
      // dont load multiple times
      return;
    }
    setState(() {
      loading = true;
    });
    debugPrint('running');
    setState(() {
      message = 'Checking asset information...';
    });
    // Navigator.pop(navigatorKey.currentContext!);
    navigatorKey.currentContext!.router.replaceNamed("/criticality/asset");
    // Navigator.pop(navigatorKey.currentContext!);
  }
}

bool assetEditCheck(TrinaRow row) {
  if (row.cells['lockedSystem']?.value == 'locked') {
    return true;
  }
  return false;
}

Future<void> reCalculateAssetRpnValues(
    TrinaGridStateManager stateManager) async {
  for (TrinaRow row in stateManager.rows) {
    await database!.updateAssetCriticality(
      assetid: row.cells['id']!.value,
      frequency: row.cells['frequency']!.value,
      downtime: row.cells['downtime']!.value,
      system: row.cells['system']!.value,
      type: row.cells['assetnum']!.value,
    );
    AssetCriticalityWithAsset assetCrit =
        await database!.getAssetCriticality(assetid: row.cells['id']!.value);
    double newRpn = rpnFunc(assetCrit) ?? -1;
    await database!.updateAssetCriticality(
      assetid: row.cells['id']!.value,
      downtime: row.cells['downtime']!.value,
      system: row.cells['system']!.value,
      frequency: row.cells['frequency']!.value,
      type: row.cells['assetnum']!.value,
      newRPN: newRpn,
    );
  }
}
