import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../admin/consts.dart';
import '../admin/db_drift.dart';
import '../main.dart';
import 'system_notifier.dart';

class AssetCriticalityPage extends StatefulWidget {
  const AssetCriticalityPage({Key? key}) : super(key: key);

  @override
  State<AssetCriticalityPage> createState() => _AssetCriticalityPageState();
}

class _AssetCriticalityPageState extends State<AssetCriticalityPage> {
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
        type: PlutoColumnType.select([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        formatter: (dynamic value) {
          return frequencyRating[value]?['description'] ?? '';
        },
      ),
      PlutoColumn(
        width: 150,
        title: 'Downtime',
        field: 'downtime',
        type: PlutoColumnType.select([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        formatter: (dynamic value) {
          return impactRating[value]?['description'] ?? '';
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
    final dbrows = await database!.getSiteAssets('GH');
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
        rows.add(PlutoRow(
          cells: {
            'assetnum': PlutoCell(value: child.assetnum),
            'parent': PlutoCell(value: child.parent),
            'description': PlutoCell(value: child.description),
            'priority': PlutoCell(value: child.priority),
            'system': PlutoCell(value: 0),
            'action': PlutoCell(value: ''),
            'frequency': PlutoCell(value: 0),
            'downtime': PlutoCell(value: 0),
            'hierarchy': PlutoCell(value: ''),
            'newPriority': PlutoCell(value: 0),
            'rpn': PlutoCell(value: 0),
          },
          type: PlutoRowType.group(
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
        row.cells['downtime']!.value = ratingFromValue(downtime, impactRating);
        // '${downtime.floor()}:${((downtime - downtime.floor()) * 60).toStringAsFixed(0).padLeft(2, "0")}';
        row.cells['frequency']!.value =
            ratingFromValue(dtEvents, frequencyRating);
        stateManager.notifyListeners();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Criticality'),
      ),
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
                configuration: PlutoGridConfiguration(
                    shortcut: PlutoGridShortcut(actions: {
                  ...PlutoGridShortcut.defaultActions,
                  LogicalKeySet(LogicalKeyboardKey.add): CustomAddKeyAction(),
                  LogicalKeySet(LogicalKeyboardKey.numpadAdd):
                      CustomAddKeyAction(),
                  LogicalKeySet(LogicalKeyboardKey.minus):
                      CustomMinusKeyAction(),
                  LogicalKeySet(LogicalKeyboardKey.numpadSubtract):
                      CustomMinusKeyAction(),
                }))),
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
    stateManager.currentCell!.value = stateManager.currentCell!.value + 1;
    stateManager.notifyListeners();
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
    stateManager.currentCell!.value = stateManager.currentCell!.value - 1;
    stateManager.notifyListeners();
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
