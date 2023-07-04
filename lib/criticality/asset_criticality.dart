import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iko_reliability_flutter/admin/end_drawer.dart';
import 'package:iko_reliability_flutter/criticality/asset_criticality_notifier.dart';
import 'package:iko_reliability_flutter/settings/settings_notifier.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'percent_slider.dart';

import '../admin/cache_notifier.dart';
import '../admin/consts.dart';
import '../admin/db_drift.dart';
import '../main.dart';
import '../settings/theme_manager.dart';
import 'criticality_notifier.dart';
import 'functions.dart';

class AssetCriticalityPage extends StatefulWidget {
  const AssetCriticalityPage({Key? key}) : super(key: key);

  @override
  State<AssetCriticalityPage> createState() => _AssetCriticalityPageState();
}

///Widget for asset criticality page
class _AssetCriticalityPageState extends State<AssetCriticalityPage> {
  //table objects
  List<PlutoColumn> columns = [];
  List<PlutoRow> rows = [];
  Map<String, Asset> siteAssets = {};
  Map<String, List<Asset>> parentAssets = {};

  List<PlutoColumn> detailColumns = [];
  List<PlutoRow> detailRows = [];

  double years = 5;

  Key? currentRowKey;

  late PlutoGridStateManager stateManager;
  late PlutoGridStateManager detailStateManager;

  @override
  void initState() {
    super.initState();
    AssetCriticalityNotifier assetCriticalityNotifier =
        context.read<AssetCriticalityNotifier>();

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
    ]);

    columns.addAll([
      PlutoColumn(
        title: '',
        field: 'id',
        type: PlutoColumnType.number(),
        readOnly: true,
        hide: true,
      ),
      PlutoColumn(
        title: 'Hierarchy',
        field: 'hierarchy',
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
          title: 'Action',
          field: 'action',
          type: PlutoColumnType.text(),
          renderer: (rendererContext) {
            return Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                  ),
                  onPressed: () {
                    debugPrint('${rendererContext.rowIdx}');
                    assetCriticalityNotifier
                        .updateCollapsedAssets(stateManager);

                    String assetnum =
                        rendererContext.row.cells['assetnum']!.value;
                    refreshAsset(
                        assetnum, assetCriticalityNotifier.selectedSite);
                    //refresh children assets
                    Set<String> childAssetnums = getChildAssetnums(assetnum);
                    for (PlutoRow row in stateManager.rows) {
                      String tempAssetnum = row.cells['assetnum']!.value;
                      if (childAssetnums.contains(tempAssetnum)) {
                        refreshAsset(tempAssetnum,
                            assetCriticalityNotifier.selectedSite);
                      }
                    }
                  },
                  iconSize: 18,
                  color: Colors.green,
                  padding: const EdgeInsets.all(0),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.info,
                  ),
                  onPressed: () {
                    refreshAsset(rendererContext.row.cells['assetnum']!.value,
                        context.read<AssetCriticalityNotifier>().selectedSite);
                  },
                  iconSize: 18,
                  color: Colors.green,
                  padding: const EdgeInsets.all(0),
                ),
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
          return Consumer<SystemsNotifier>(builder: (context, systems, child) {
            return DropdownButton(
              value: rendererContext.cell.value,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              isExpanded: true,
              onChanged: (newValue) {
                setState(() {
                  //modify child assets as well. do this before changing the rendererContext.row's cell as to lessen the amount of events triggered
                  Set<String> childs = getChildAssetnums(
                      rendererContext.row.cells['assetnum']!.value);
                  for (PlutoRow row in stateManager.rows) {
                    //TODO: not the most efficient. Could iterate through the List<PlutoRows> after the rendererContext row and check their hierarchy.
                    // The consecutives assets that contain the rendererContext row's assetnum in their hierarchy would be child assets. This way we
                    // don't have to search all assets.
                    if (childs.contains(row.cells['assetnum']!.value)) {
                      stateManager.changeCellValue(
                          row.cells['system']!, newValue,
                          notify: false);
                    }
                  }
                  //change cell value
                  stateManager.changeCellValue(rendererContext.cell, newValue);
                });
              },
              items:
                  systems.systems.keys.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(systems.systems[value]!['description']!),
                );
              }).toList(),
            );
          });
        },
      ),

      // PlutoColumn(
      //   title: 'Type',
      //   field: 'type',
      //   type: PlutoColumnType.text(defaultValue: '1'),
      // ),
      // PlutoColumn(
      //   title: 'Production Line',
      //   field: 'prodLine',
      //   type: PlutoColumnType.text(defaultValue: '1'),
      // ),
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
            onChanged: (int? value) {
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
            onChanged: (int? value) {
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
        width: 50,
        title: 'RPN',
        field: 'rpn',
        readOnly: true,
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        width: 100,
        title: 'New Priority',
        field: 'newPriority',
        readOnly: true,
        type: PlutoColumnType.text(defaultValue: '---'),
      ),
    ]);
    _loadData();
  }

  void gridAHandler() {
    if (stateManager.currentRow == null) {
      return;
    }

    if (stateManager.currentRow!.key != currentRowKey) {
      currentRowKey = stateManager.currentRow!.key;

      detailStateManager.setShowLoading(true);

      fetchWoHistory(stateManager.currentRow!.cells['assetnum']!.value,
          context.read<AssetCriticalityNotifier>().selectedSite);
    }
  }

  void fetchWoHistory(String assetnum, String siteid) async {
    //TODO: use work order settings
    var wos = await database!.getAssetWorkorders(assetnum, siteid);
    List<PlutoRow> rows = [];
    for (var wo in wos) {
      rows.add(PlutoRow(cells: {
        'wonum': PlutoCell(value: wo.wonum),
        'description': PlutoCell(value: wo.description),
        'type': PlutoCell(value: wo.type),
        'status': PlutoCell(value: wo.status),
        'reportdate': PlutoCell(value: wo.reportdate),
        'downtime': PlutoCell(value: wo.downtime),
      }));
    }

    detailStateManager.removeRows(detailStateManager.rows);
    detailStateManager.resetCurrentState();
    detailStateManager.appendRows(rows);

    detailStateManager.setShowLoading(false);
  }

  ///Loading plutogrid data
  void _loadData() {
    _loadSiteData(context.read<AssetCriticalityNotifier>().selectedSite)
        .then((fetchedRows) {
      PlutoGridStateManager.initializeRowsAsync(
        columns,
        fetchedRows,
      ).then((value) {
        stateManager.refRows.clear();
        stateManager.refRows.addAll(value);
        stateManager.setShowLoading(false);
        stateManager.notifyListeners();
        // workaround since setting the group as expanded does not expand first row
        try {
          stateManager.toggleExpandedRowGroup(
              rowGroup: stateManager.rows.first);
          stateManager.toggleExpandedRowGroup(
              rowGroup: stateManager.rows.first);
        } catch (e) {
          debugPrint("Could not run 'stateManager.toggleExpandedRowGroup'");
        }
      }).then((value) {
        //load rpn numbers from plutogrid into AssetCriticalityNotifier
        Map<int, double> newRpnMap = {};
        for (PlutoRow row in stateManager.rows) {
          if (row.cells['id'] != null) {
            newRpnMap[row.cells['id']!.value] =
                (row.cells['rpn']?.value ?? -1) + 0.0;
          }
        }
        context
            .read<AssetCriticalityNotifier>()
            .setRpnMap(newRpnMap, notify: false);
      });
    });
  }

  ///Creates a list of [PlutoRow]s from the assets of [siteid]
  Future<List<PlutoRow>> _loadSiteData(String siteid) async {
    if (siteIDAndDescription.containsKey(siteid)) {
      try {
        siteAssets.clear();
        parentAssets.clear();
        final dbrows = await database!
            .getSiteAssets(siteid); //TODO make it able to load other sites
        await context.read<WorkOrderNotifier>().updateWorkOrders();
        for (var row in dbrows) {
          siteAssets[row.assetnum] = row;
          if (parentAssets.containsKey(row.parent)) {
            parentAssets[row.parent]!.add(row);
          } else {
            parentAssets[row.parent ?? "Top"] = [row];
          }
        }
        return getChilds('Top');
      } catch (e) {
        if (siteIDAndDescription.containsKey(siteid) &&
            !(context
                    .read<SettingsNotifier>()
                    .getSetting(ApplicationSetting.loadedSites) as Set<String>)
                .contains(siteid)) {
          debugPrint('Exception: Site $siteid is not loaded');
          //TODO: show dialog instead of print to console
        } else {
          debugPrint(e.toString());
        }
        return <PlutoRow>[];
      }
    } else {
      //siteid = 'NONE'
      siteAssets.clear();
      parentAssets.clear();
      return <PlutoRow>[];
    }
  }

  ///Gets a set of assetnums that have [assetnum] as a parent or ancestor.
  ///Recursive method
  Set<String> getChildAssetnums(String assetnum) {
    List<Asset>? directChilds = parentAssets[assetnum];
    //exit condition
    if (directChilds == null || directChilds.isEmpty) {
      return <String>{};
    }

    Set<String> childSet = {};
    for (Asset child in directChilds) {
      childSet.add(child.assetnum);
      childSet.addAll(getChildAssetnums(child.assetnum));
    }
    return childSet;
  }

  List<PlutoRow> getChilds(String parent) {
    AssetCriticalityNotifier assetCriticalityNotifier =
        Provider.of<AssetCriticalityNotifier>(context, listen: false);
    List<PlutoRow> rows = [];
    if (parentAssets.containsKey(parent)) {
      for (var child in parentAssets[parent]!) {
        final asset = context.read<WorkOrderNotifier>().systems[child.assetnum];
        final cache = Provider.of<Cache>(context, listen: false);
        double? calculatedRPN = rpnFunc(cache.getSystemScore(asset?.system),
            asset?.frequency, asset?.downtime);
        rows.add(PlutoRow(
          cells: {
            'assetnum': PlutoCell(value: child.assetnum),
            'parent': PlutoCell(value: child.parent),
            'description': PlutoCell(value: child.description),
            'priority': PlutoCell(value: child.priority),
            'system': PlutoCell(value: asset?.system ?? 0),
            'action': PlutoCell(value: ''),
            'frequency': PlutoCell(value: asset?.frequency ?? 0),
            'downtime': PlutoCell(value: asset?.downtime ?? 0),
            'hierarchy': PlutoCell(value: ''),
            'newPriority': PlutoCell(
                value: assetCriticalityNotifier
                    .rpnFindDistribution(calculatedRPN ?? -1)),
            'rpn': PlutoCell(value: calculatedRPN),
            'id': PlutoCell(value: child.id),
          },
          type: PlutoRowType.group(
              expanded:
                  assetCriticalityNotifier.assetIsCollapsed(child.assetnum),
              children: FilteredList<PlutoRow>(
                  initialList: getChilds(child.assetnum))),
        ));
      }
    }
    return rows;
  }

  void collapseRows() {
    for (var row in stateManager.iterateAllRow) {
      debugPrint(row.cells.values.first.value);
    }
  }

  void refreshAsset(String assetnum, [String? siteid]) async {
    //TODO: use work order settings
    await database!.getWorkOrderMaximo(
      assetnum,
      context.read<MaximoServerNotifier>().maximoServerSelected,
    );
    var wos = await database!.getAssetWorkorders(assetnum, siteid);
    double downtime = 0;
    double dtEvents = wos.length.toDouble();
    for (var wo in wos) {
      downtime += wo.downtime;
    }
    downtime = downtime / years;
    dtEvents = dtEvents / years;
    for (var row in stateManager.iterateRowAndGroup) {
      if (row.cells['assetnum']!.value == assetnum) {
        stateManager.changeCellValue(
            row.cells['downtime']!, ratingFromValue(downtime, impactRating));
        stateManager.changeCellValue(row.cells['frequency']!,
            ratingFromValue(dtEvents, frequencyRating));
        stateManager.notifyListeners();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager themeManager = Provider.of<ThemeManager>(context);
    return Builder(builder: (context) {
      final selectedSite =
          context.select((AssetCriticalityNotifier acn) => acn.selectedSite);
      _loadData();
      return Scaffold(
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
                    ))
          ],
        ),
        endDrawer: const EndDrawer(),
        body: Container(
            padding: const EdgeInsets.all(30),
            child: PlutoDualGrid(
              isVertical: true,
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
                onChanged: (PlutoGridOnChangedEvent event) {
                  Cache cache = context.read<Cache>();
                  AssetCriticalityNotifier assetCriticalityNotifier =
                      context.read<AssetCriticalityNotifier>();
                  assetCriticalityNotifier.priorityRangesUpToDate = false;
                  assetCriticalityNotifier.updateCollapsedAssets(stateManager);
                  int rowId = event.row.cells['id']?.value ?? -1;
                  double newRpn = rpnFunc(
                          cache
                              .getSystemScore(event.row.cells['system']!.value),
                          event.row.cells['frequency']!.value,
                          event.row.cells['downtime']!.value) ??
                      -1;
                  event.row.cells['rpn']!.value = newRpn;
                  if (rowId != -1) {
                    assetCriticalityNotifier.addToRpnMap({rowId: newRpn});
                  }
                  updateAsset(event.row);
                  debugPrint('$event');
                },
                configuration: PlutoGridConfiguration(
                    style: themeManager.isDark
                        ? const PlutoGridStyleConfig.dark()
                        : const PlutoGridStyleConfig(),
                    shortcut: PlutoGridShortcut(actions: {
                      ...PlutoGridShortcut.defaultActions,
                      LogicalKeySet(LogicalKeyboardKey.add):
                          CustomAddKeyAction(),
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
                    style: themeManager.isDark
                        ? const PlutoGridStyleConfig.dark()
                        : const PlutoGridStyleConfig()),
                columns: detailColumns,
                rows: detailRows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  detailStateManager = event.stateManager;
                },
              ),
              divider: themeManager.isDark
                  ? PlutoDualGridDivider.dark(
                      indicatorColor:
                          Theme.of(context).colorScheme.onBackground)
                  : const PlutoDualGridDivider(),
            )),
      );
    });
  }
}

Future<void> updateAsset(PlutoRow row) async {
  if (!row.cells.containsKey('id')) {
    return;
    //this shouldnt happen
  }
  await database!.updateAssetCriticality(
    row.cells['id']!.value,
    row.cells['system']!.value,
    row.cells['frequency']!.value,
    row.cells['downtime']!.value,
    'type', //row.cells['type']!.value,
  );
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

int ratingFromValue(double value, Map<int, Map<String, dynamic>> definition) {
  for (var i = 1; i < 11; i++) {
    if (value < definition[i]!['high']!) {
      return i;
    }
  }
  return 1;
}

///To calculate the system score for an asset.
///Uses the root mean squared (RMS) of the asset's ratings of safety, regulatory, economic, throughput, and quality.
///Economic and quality values are integers from 1-5, while the rest are between 1-10.
///System score is used to calculate risk priority number (RPN)
double calculateSystemScore(List<int> ratings) {
  if (ratings.length != 5) {
    throw Exception(
        'Error in parameter [ratings] for function [calculateSystemScore]. Must have a length of 5');
  }
  num sum2 = 0;
  for (int rating in ratings) {
    sum2 += pow(rating, 2);
  }
  return sqrt(sum2 / ratings.length);
}

///returns a list of rpn maximum values (inclusive) for rpn assessments (e.g. very low, medium, high, etc) in order to have the
///closest percent distribution to that listed in {rpnPercentDist}
///Params:
/// - rpnList: list of all the rpns (without 0 or -1 values)
/// - rpnPercentDist: desired rpn percent distribution in rpn assessments. Listed from least serious (very low) to most serious (very high)
/// - tolerance: a percentage. if the difference between the desired and actual percent distribution is greater than the tolerance, use a different distribution
/// Returns list of rpn maximum values for each distribution range, from very low to very high
List<double> rpnDistRange(List<double> rpnList, List<int> rpnPercentDist,
    {double tolerance = 10}) {
  /* 
  duplicates must be found as consider the following example:
    say the rpns are [1, 2, 3, 3, 3, 4, 5, 6, 7, 8] and we want to get 30% dist for very low.
    index = rpns.length * 30% - 1 = 2, so the cutoff point should be at rpn = rpns[2] = 3
    however, since there are duplicates of the cutoff point, the actual cutoff point will be at index = 4
    hence the distrubution will be 50%.
    if we set rpn = 2 as the cutoff point, the distrubution will be 20%, which is closer to 30% than 50% is
  */

  ///searches for duplicates of the item at index a in an ordered list.
  ///returns a List<int> of length 2 of the indicies of the furthest duplicate of item at index. result = [first, last]
  ///recursive(ish) function (don't use optional param {searchDownwardsThruList} when calling)
  dynamic searchForDuplicate(List orderedRpnList, int index,
      {bool? searchDownwardsThruList}) {
    if (searchDownwardsThruList == null) {
      return <int>[
        searchForDuplicate(orderedRpnList, index - 1,
            searchDownwardsThruList: true),
        searchForDuplicate(orderedRpnList, index - 1,
            searchDownwardsThruList: false)
      ];
      //recursive conditions
    } else if (searchDownwardsThruList) {
      try {
        if (orderedRpnList[index] == orderedRpnList[index + 1]) {
          return (searchForDuplicate(orderedRpnList, index - 1,
              searchDownwardsThruList: true));
        } else {
          return index + 1;
        }
      } catch (e) {
        return index + 1;
      }
    } else {
      try {
        if (orderedRpnList[index] == orderedRpnList[index - 1]) {
          return (searchForDuplicate(orderedRpnList, index + 1,
              searchDownwardsThruList: false));
        } else {
          return index - 1;
        }
      } catch (e) {
        return index - 1;
      }
    }
  }

  List<double> percentDist = List.from(rpnPercentDist
      .map((i) => i.toDouble())
      .toList()
      .reversed); //order list from highest to lowest priority. Will process from lowest to highest, but Dart only has list.removeLast
  List<double> list = List<double>.of(rpnList); //copy the ordered rpn list.
  list.sort((a, b) => b.compareTo(
      a)); //reversed (highest to lowest) for now, to use List.removelast. Since ordered, should be more efficient than removeWhere()
  while (list.isNotEmpty && list.last <= 0) {
    //remove all not yet calculated rpns
    list.removeLast();
  }
  if (Set.from(list).length < 5) {
    throw Exception(
        'Need at least 5 distinct RPNs to calculate distributions. Currently have ${Set.from(list).length} distinct RPN values.');
  }
  list = List.from(list.reversed); //reverse the list back to lowest to highest
  List<double> rangeDist = [];
  double diff = 100000.01; //some large number
  double targetDist = 0;

  while (percentDist.length > 1) {
    targetDist += percentDist.removeLast();
    //get supposed index position of the cutoff RPN in [list]
    int index = (list.length * targetDist / 100).round() - 1;
    //check for duplicates of the value at i
    List<int> duplicates = searchForDuplicate(list, index);
    if (duplicates[0] == index && duplicates[1] == index) {
      //no duplicates, list[index] is cutoff RPN for current dist
      //calculate the difference between ideal percent distribution and actual
      diff = targetDist - ((list.length - index - 1) / list.length * 100);
    } else {
      //duplicates exist, three possible cutoff RPNs: RPN at list[index], the RPN right before it, and the RPN after it. Use whatever results in percent distribution closer to [targetDist]
      int? indexDwn = (duplicates[0] - 1) >= 0
          ? searchForDuplicate(list, duplicates[0] - 1)[0]
          : null; //lower index on list, RPN right above list[index]. Note that list is from greatest to least. Must account for dupes
      int indexMid = duplicates[0];
      int? indexUp =
          (duplicates[1] + 1) < list.length ? (duplicates[1] + 1) : null;

      if (indexDwn != null) {
        index = indexDwn;
        diff = targetDist - ((index + 1) / list.length * 100);
      }
      if (indexUp != null) {
        double tempDiff = targetDist - ((indexUp + 1) / list.length * 100);
        if (tempDiff.abs() < diff.abs()) {
          diff = tempDiff;
          index = indexUp;
        }
      }
      double tempDiff = targetDist - ((indexMid + 1) / list.length * 100);
      if (tempDiff.abs() < diff.abs()) {
        diff = tempDiff;
        index = indexMid;
      }
    }
    if (diff.abs() > tolerance) {
      //when actual percent distripution becomes way off
      debugPrint(
          'Tolerance exceeded. Use different percent distribution. Diff = $diff%, RPN = ${list[index]}, Target = $targetDist%');
      throw Exception(
          'Calculated distributions are way off the configured distributions.');
    }

    //add to cutoff RPN to [rangeDist]
    rangeDist.add(list[index]);
    //modify the remaining percent distributions with the difference
    for (int i = 0; i < percentDist.length; i++) {
      percentDist[i] += diff / (percentDist.length);
    }
  }

  //make highest priority cutoff RPN include all RPNs
  rangeDist.add(list.last);

  //cannot have duplicates in [rangeDist]
  if (Set.from(rangeDist).length != rangeDist.length) {
    debugPrint(
        'error: duplicate values in [rangeDist]. rangeDist = \n$rangeDist');
    throw Exception('An unexpected error occured.');
  }
  return rangeDist;
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
  SettingsNotifier settingsNotifier =
      Provider.of<SettingsNotifier>(context, listen: false);
  List<TextEditingController> distControllers = [];
  for (ApplicationSetting distSetting in rpnDistributionGroups) {
    distControllers.add(TextEditingController(
        text: settingsNotifier.getSetting(distSetting).toString()));
  }

  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: RpnDistDialog(
              distGroups: distGroups, distControllers: distControllers),
        );
      });
}

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

  ///returns the sum of all distributions. Should be equal to 100
  int calculateTotal() {
    int sum = 0;
    for (int dist in dists!) {
      sum += dist;
    }
    return sum;
  }

  void reloadTextControllers() {
    for (int i = 0; i < widget.distControllers.length; i++) {
      widget.distControllers[i].text = dists![i].toString();
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
      Colors.red[200]!,
      Colors.red[300]!,
      Colors.red[400]!,
      Colors.red[700]!,
      Colors.red[900]!
    ];
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        width: MediaQuery.of(context).size.width * 0.7,
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Expanded(
              //title
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(top: 30.0, left: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Text(
                          'Rating Distribution',
                          style: TextStyle(fontSize: 30.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              //Multislider/visual representation
              flex: 3,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
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
                        setState(() {
                          dists = List.from(newPercentDists);
                          reloadTextControllers();
                        });
                      },
                      tooltip: rpnPossibleDistributions,
                    );
                  }),
                ),
              ),
            ),
            Expanded(
              //input boxes
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
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
                            //limits characters to digits between 0-999
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          onChanged: (value) {
                            int? val = int.tryParse(value);
                            setState(() {
                              dists![i] = val ?? 0;
                              total = calculateTotal();
                            });
                          },
                        ),
                      )));
                    }
                    return widgets;
                  }(),
                ),
              ),
            ),
            Expanded(
                //print total percentage
                flex: 1,
                child: Text('Total: ${total ?? calculateTotal()}%')),
            Expanded(
              //close buttons
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, right: 4.0),
                    child: ElevatedButton(
                        //save changes button
                        onPressed: () {
                          //only allow to save changes if total percent is 100%
                          if (calculateTotal() == 100) {
                            Map<ApplicationSetting, dynamic> settingChanges =
                                {};
                            for (int i = 0;
                                i < rpnDistributionGroups.length;
                                i++) {
                              settingChanges[rpnDistributionGroups[i]] =
                                  dists![i];
                            }
                            context
                                .read<AssetCriticalityNotifier>()
                                .priorityRangesUpToDate = false;
                            context
                                .read<SettingsNotifier>()
                                .changeSettings(settingChanges);
                            Navigator.pop(context);
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                      title:
                                          const Text('Improper Distributions'),
                                      content: const Text(
                                          'The total percentage must be 100%'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('OK'))
                                      ],
                                    ));
                          }
                        },
                        child: const Text('Confirm')),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, left: 4.0),
                    child: ElevatedButton(
                        //cancel button
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel')),
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
  DateTime? beforeDate;

  ///Exclude all work orders before this date
  DateTime? afterDate;

  bool? usingBeforeDate;
  bool? usingAfterDate;

  ///whether to show all sites' work orders or not
  bool? showAllSites;

  @override
  void initState() {
    super.initState();
    AssetCriticalityNotifier assetCriticalityNotifier =
        context.read<AssetCriticalityNotifier>();
    beforeDate = assetCriticalityNotifier.beforeDate;
    afterDate = assetCriticalityNotifier.afterDate;
    usingBeforeDate = (beforeDate != null) &&
        (assetCriticalityNotifier.usingBeforeDate ?? false);
    usingAfterDate = (afterDate != null) &&
        (assetCriticalityNotifier.usingAfterDate ?? false);

    showAllSites = assetCriticalityNotifier.showAllSites ?? false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: make it look pretty ✧˖°🌷📎⋆ ˚｡⋆୨୧˚
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
                        'Work Order View Settings',
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
                            value: usingAfterDate,
                            onChanged: (value) => setState(() {
                                  usingAfterDate = value;
                                })),
                        title: const Text('Hide Work Orders Before'),
                        valueDisplay: Text(
                          '${afterDate?.year ?? 'YY'}/${afterDate?.month ?? 'mm'}/${afterDate?.day ?? 'dd'}',
                          style: usingAfterDate!
                              ? null
                              : const TextStyle(
                                  decoration: TextDecoration.lineThrough),
                        ),
                        inputWidget: Builder(
                            builder: (context) => ElevatedButton(
                                onPressed: (usingAfterDate!)
                                    ? () async {
                                        DateTime? newDate =
                                            await showDatePicker(
                                                context: context,
                                                initialDate:
                                                    afterDate ?? DateTime.now(),
                                                firstDate: DateTime(1951),
                                                lastDate: DateTime.now());
                                        if (newDate != null) {
                                          setState(() {
                                            afterDate = newDate;
                                          });
                                        }
                                      }
                                    : () {},
                                child: const Text('Select Date')))),
                    buildSettingRow(
                        checkbox: Checkbox(
                            value: usingBeforeDate,
                            onChanged: (value) => setState(() {
                                  usingBeforeDate = value;
                                })),
                        title:
                            const Text('Hide Work Orders After (Inclusive):'),
                        valueDisplay: Text(
                          '${beforeDate?.year ?? 'YY'}/${beforeDate?.month ?? 'mm'}/${beforeDate?.day ?? 'dd'}',
                          style: usingBeforeDate!
                              ? null
                              : const TextStyle(
                                  decoration: TextDecoration.lineThrough),
                        ),
                        inputWidget: Builder(
                            builder: (context) => ElevatedButton(
                                onPressed: (usingBeforeDate!)
                                    ? () async {
                                        DateTime? newDate =
                                            await showDatePicker(
                                                context: context,
                                                initialDate: beforeDate ??
                                                    DateTime.now(),
                                                firstDate: DateTime(1951),
                                                lastDate: DateTime.now());
                                        if (newDate != null) {
                                          setState(() {
                                            beforeDate = newDate;
                                          });
                                        }
                                      }
                                    : () {},
                                child: const Text('Select Date')))),
                    //TODO add a setting for toggling show/hide workorders from all sites not just selected site
                    buildSettingRow(
                        checkbox: Checkbox(
                            value: showAllSites,
                            onChanged: (value) => setState(() {
                                  showAllSites = value;
                                })),
                        title: const Text('Show work orders from all sites'),
                        valueDisplay: Container(),
                        inputWidget: Container()),
                  ],
                )),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        //TODO: check if settings are valid (e.g. afterdate is not after beforedate). if so, use new settings
                        if (usingAfterDate! && afterDate == null) {
                          //if using after date, afterDate must not be null
                          //TODO: show dialog
                        } else if (usingBeforeDate! && beforeDate == null) {
                          //if using before date, beforeDate must not be null
                          //TODO: show dialog
                        } else if (usingAfterDate! &&
                            usingBeforeDate! &&
                            afterDate!.compareTo(beforeDate!) >= 0) {
                          //invalid format, afterDate must be before beforeDate
                          ///TODO: show dialog
                        } else {
                          context
                              .read<AssetCriticalityNotifier>()
                              .setWOSettings(
                                  beforeDate: beforeDate,
                                  afterDate: afterDate,
                                  usingBeforeDate: usingBeforeDate!,
                                  usingAfterDate: usingAfterDate!,
                                  showAllSites: showAllSites!);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Confirm')),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'))
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
