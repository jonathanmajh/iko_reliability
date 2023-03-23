import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../admin/db_drift.dart';
import '../main.dart';

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

  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      PlutoColumn(
        title: 'Hierarchy',
        field: 'hierarchy',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Asset Number',
        field: 'assetnum',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
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
                    stateManager
                        .getRowByIdx(rendererContext.rowIdx)!
                        .cells['system']!
                        .value = 'asdfasdf';
                    stateManager.notifyListeners();
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
        title: 'Criticality',
        field: 'priority',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'System',
        field: 'system',
        type: PlutoColumnType.select(['Production', 'Non Production']),
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
        type: PlutoColumnType.text(defaultValue: '1'),
      ),
      PlutoColumn(
        title: 'Downtime',
        field: 'downtime',
        type: PlutoColumnType.text(defaultValue: '1'),
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
            'priority': PlutoCell(value: 0),
            'system': PlutoCell(value: ''),
            'action': PlutoCell(value: ''),
            'frequency': PlutoCell(value: ''),
            'downtime': PlutoCell(value: ''),
            'hierarchy': PlutoCell(value: ''),
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
        assetnum, context.read<MaximoServerNotifier>().maximoServerSelected);
    var wos = await database!.getAssetWorkorders(assetnum, siteid);
    double downtime = 0;
    int dtEvents = wos.length;
    for (var wo in wos) {
      downtime += wo.downtime;
    }
    for (var row in stateManager.iterateRowAndGroup) {
      if (row.cells['assetnum']!.value == assetnum) {
        row.cells['downtime']!.value =
            '${downtime.floor()}:${((downtime - downtime.floor()) * 60).toStringAsFixed(0).padLeft(2, "0")}';
        row.cells['frequency']!.value = dtEvents;
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
        child: PlutoGrid(
          columns: columns,
          rows: rows,
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;
            stateManager.setShowColumnFilter(true);
            stateManager.setRowGroup(PlutoRowGroupTreeDelegate(
              resolveColumnDepth: (column) => stateManager.columnIndex(column),
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
        ),
      ),
    );
  }
}
