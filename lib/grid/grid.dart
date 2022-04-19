import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class GridPage extends StatefulWidget {
  const GridPage({Key? key}) : super(key: key);

  @override
  State<GridPage> createState() => _GridPageState();
}

class _GridPageState extends State<GridPage> {
  final myData = Griddata();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('PlutoGrid Demo'),
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: PlutoGrid(
          columns: myData.columns,
          rows: myData.rows,
        ),
      ),
    );
  }
}

class Griddata {
  late List<PlutoColumn> columns;
  late List<PlutoRow> rows;

  Griddata() {
    columns = [
      PlutoColumn(
        title: 'Site ID',
        field: 'site_id',
        type: PlutoColumnType.select(['GH', 'GV', 'GK']),
      ),
      PlutoColumn(
        title: 'Parent Asset',
        field: 'parent_number',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Asset Number',
        field: 'asset_number',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Asset Description',
        field: 'asset_description',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Standard Job Plan Description',
        field: 'sjp_description',
        type: PlutoColumnType.text(),
      ),
    ];

    rows = [
      PlutoRow(
        cells: {
          'site_id': PlutoCell(
            value: 'GV',
          ),
          'parent_number': PlutoCell(
            value: 'column a value',
          ),
          'asset_number': PlutoCell(
            value: 'column a value',
          ),
          'asset_description': PlutoCell(
            value: 'column a value',
          ),
          'sjp_description': PlutoCell(
            value: 'column a value',
          ),
        },
      ),
    ];
  }
}
