import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iko_reliability_flutter/criticality/asset_crit_drawer.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../admin/cache_notifier.dart';
import '../admin/consts.dart';
import '../admin/db_drift.dart';
import '../main.dart';
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
  Map<String, String> collapsedAssets = {};

  List<PlutoColumn> detailColumns = [];
  List<PlutoRow> detailRows = [];

  double years = 5;

  Key? currentRowKey;

  late PlutoGridStateManager stateManager;
  late PlutoGridStateManager detailStateManager;

  //settings objects
  String? startDateRange;
  String? endDateRange;
  List<int> priorityDistribution = []; //from lowest to highest priority

  @override
  void initState() {
    super.initState();

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
                    print(rendererContext.rowIdx);
                    refreshAsset(
                        rendererContext.row.cells['assetnum']!.value, 'GH');
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
                    refreshAsset(
                        rendererContext.row.cells['assetnum']!.value, 'GH');
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
        title: 'Criticality',
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
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        width: 100,
        title: 'New Priority',
        field: 'newPriority',
        type: PlutoColumnType.number(),
        renderer: (rendererContext) {
          return Text('asdf');
          // call notifier and convert to string Very High etc
        },
      ),
    ]);
    _loadData().then((fetchedRows) {
      PlutoGridStateManager.initializeRowsAsync(
        columns,
        fetchedRows,
      ).then((value) {
        stateManager.refRows.addAll(value);
        stateManager.setShowLoading(false);
        stateManager.notifyListeners();
        // workaround since setting the group as expanded does not expand first row
        stateManager.toggleExpandedRowGroup(rowGroup: stateManager.rows.first);
        stateManager.toggleExpandedRowGroup(rowGroup: stateManager.rows.first);
      });
    });
  }

  void gridAHandler() {
    if (stateManager.currentRow == null) {
      return;
    }

    if (stateManager.currentRow!.key != currentRowKey) {
      currentRowKey = stateManager.currentRow!.key;

      detailStateManager.setShowLoading(true);

      fetchWoHistory(stateManager.currentRow!.cells['assetnum']!.value, 'GH');
    }
  }

  void fetchWoHistory(String assetnum, [String? siteid]) async {
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

  Future<List<PlutoRow>> _loadData() async {
    final dbrows = await database!
        .getSiteAssets('GH'); //TODO make it able to load other sites
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
  }

  List<PlutoRow> getChilds(String parent) {
    List<PlutoRow> rows = [];
    if (parentAssets.containsKey(parent)) {
      for (var child in parentAssets[parent]!) {
        final asset = context.read<WorkOrderNotifier>().systems[child.assetnum];
        final cache = Provider.of<Cache>(context);
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
            'newPriority': PlutoCell(value: 0),
            'rpn': PlutoCell(value: 0),
            'id': PlutoCell(value: child.id),
          },
          type: PlutoRowType.group(
              expanded: true,
              children: FilteredList<PlutoRow>(
                  initialList: getChilds(child.assetnum))),
        ));
      }
    }
    return rows;
  }

  void collapseRows() {
    for (var row in stateManager.iterateAllRow) {
      print(row.cells.values.first.value);
    }
  }

  void refreshAsset(String assetnum, [String? siteid]) async {
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
      endDrawer: const AssetCritSettingsDrawer(),
      body: Container(
          padding: const EdgeInsets.all(30),
          child: PlutoDualGrid(
            isVertical: true,
            gridPropsA: PlutoDualGridProps(
              columns: columns,
              rows: rows,
              onLoaded: (PlutoGridOnLoadedEvent event) {
                stateManager = event.stateManager;
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
              onRowDoubleTap: (event) {
                setState(() {
                  collapsedAssets[event.cell.value] = event.cell.value;
                  event.cell.value = 'Non Production';
                  // print(collapsedAssets);
                  // collapseRows();
                });
              },
              onChanged: (PlutoGridOnChangedEvent event) {
                event.row.cells['rpn']!.value = event
                        .row.cells['frequency']!.value *
                    event.row.cells['downtime']!.value *
                    double.parse(context
                        .read<SystemsNotifier>()
                        .systems[event.row.cells['system']!.value]!['score']!);
                updateAsset(event.row);
                print(event);
              },
              configuration: PlutoGridConfiguration(
                  shortcut: PlutoGridShortcut(actions: {
                ...PlutoGridShortcut.defaultActions,
                LogicalKeySet(LogicalKeyboardKey.add): CustomAddKeyAction(),
                LogicalKeySet(LogicalKeyboardKey.numpadAdd):
                    CustomAddKeyAction(),
                LogicalKeySet(LogicalKeyboardKey.minus): CustomMinusKeyAction(),
                LogicalKeySet(LogicalKeyboardKey.numpadSubtract):
                    CustomMinusKeyAction(),
              })),
            ),
            gridPropsB: PlutoDualGridProps(
              columns: detailColumns,
              rows: detailRows,
              onLoaded: (PlutoGridOnLoadedEvent event) {
                detailStateManager = event.stateManager;
              },
            ),
          )),
    );
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
    print('Pressed add key.');
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
    print('Pressed minus key.');
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

List<double> rpnDistRange(List<double> rpnList, List<int> rpnPercentDist,
    {double tolerance = 10}) {
  ///searches for duplicates of the item at index i a in an ordered list.
  ///returns a List<int> of length 2 of the indicies of the furthest duplicate of item at index i (first, last)
  ///recursive function (don't use optional param [searchDown] when calling)
  dynamic searchForDuplicate(List list, int i, {bool? searchDown}) {
    if (searchDown == null) {
      return <int>[
        searchForDuplicate(list, i - 1, searchDown: true),
        searchForDuplicate(list, i - 1, searchDown: false)
      ];
    } else if (searchDown) {
      try {
        if (list[i] == list[i + 1]) {
          return (searchForDuplicate(list, i - 1, searchDown: true));
        } else {
          return i + 1;
        }
      } catch (e) {
        return i + 1;
      }
    } else {
      try {
        if (list[i] == list[i - 1]) {
          return (searchForDuplicate(list, i + 1, searchDown: false));
        } else {
          return i - 1;
        }
      } catch (e) {
        return i - 1;
      }
    }
  }

  List<double> percentDist = List.from(rpnPercentDist
      .map((i) => i.toDouble())
      .toList()
      .reversed); //order list from highest to lowest priority. Will process from lowest to highest, but Dart only has list.removeLast
  List<double> list = List<double>.of(rpnList);
  list.sort((a, b) => a.compareTo(b));
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
      throw Exception(
          'Tolerance exceeded. Use different percent distribution. Diff = $diff%, RPN = ${list[index]}, Target = $targetDist%');
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

  return rangeDist;
}
