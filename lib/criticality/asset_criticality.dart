import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pluto_grid/pluto_grid.dart';

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
        title: 'Asset Number',
        field: 'assetnum',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Parent',
        field: 'parent',
        type: PlutoColumnType.text(),
      ),
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
      // PlutoColumn(
      //   title: 'Frequency of Breakdown',
      //   field: 'frequency',
      //   type: PlutoColumnType.text(defaultValue: '1'),
      // ),
      // PlutoColumn(
      //   title: 'Downtime',
      //   field: 'downtime',
      //   type: PlutoColumnType.text(defaultValue: '1'),
      // ),
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
    final dbrows = await database!.getSiteAssets('GX');
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
