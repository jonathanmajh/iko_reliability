import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../main.dart';

class SystemCriticalityPage extends StatefulWidget {
  const SystemCriticalityPage({Key? key}) : super(key: key);

  @override
  State<SystemCriticalityPage> createState() => _SystemCriticalityPageState();
}

class _SystemCriticalityPageState extends State<SystemCriticalityPage> {
  List<PlutoColumn> columns = [];
  List<PlutoRow> rows = [];
  List<Widget> fabList = [];
  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    _updateFab();

    columns.addAll([
      PlutoColumn(
        title: '',
        field: 'id',
        type: PlutoColumnType.number(),
        readOnly: true,
        hide: true,
      ),
      PlutoColumn(
        title: 'System Name',
        field: 'description',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Safety',
        field: 'safety',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Regulatory',
        field: 'regulatory',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Economic',
        field: 'economic',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Throughput',
        field: 'throughput',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Quality',
        field: 'quality',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Score',
        field: 'score',
        type: PlutoColumnType.number(
          format: '#.##',
        ),
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
    final dbrows = await database!.getSystemCriticalities();
    List<PlutoRow> rows = [];
    for (var row in dbrows) {
      rows.add(PlutoRow(cells: {
        'id': PlutoCell(value: row.id),
        'description': PlutoCell(value: row.description),
        'safety': PlutoCell(value: row.safety),
        'regulatory': PlutoCell(value: row.regulatory),
        'economic': PlutoCell(value: row.economic),
        'throughput': PlutoCell(value: row.throughput),
        'quality': PlutoCell(value: row.quality),
        'score': PlutoCell(
            value: sqrt((row.safety * row.safety +
                    row.regulatory * row.regulatory +
                    row.economic * row.economic +
                    row.throughput * row.throughput +
                    row.quality * row.quality) /
                5)),
      }));
    }
    return rows;
  }

  void _updateFab([bool show = false]) {
    List<Widget> temp = [];
    if (show) {
      temp = [
        Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: FloatingActionButton.extended(
              heroTag: UniqueKey(),
              onPressed: () async {
                addRow();
                _updateFab();
              },
              label: const Text('Add Row'),
              icon: const Icon(Icons.playlist_add),
            )),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: FloatingActionButton.extended(
            heroTag: UniqueKey(),
            onPressed: () async {},
            label: const Text('Delete Row'),
            icon: const Icon(Icons.playlist_remove),
          ),
        ),
        FloatingActionButton(
          heroTag: UniqueKey(),
          onPressed: () {
            _updateFab();
          },
          child: const Icon(Icons.close),
        ),
      ];
    } else {
      temp.add(
        FloatingActionButton(
          heroTag: UniqueKey(),
          onPressed: () {
            _updateFab(true);
          },
          child: const Icon(Icons.add),
        ),
      );
    }

    setState(() {
      fabList = temp;
    });
  }

  void addRow() {
    final newRows = stateManager.getNewRows();
    newRows.first.cells['id'] = PlutoCell(value: -1);
    //cells with ID -1 are new,
    //once they are added to DB they are assigned a proper ID
    //TODO read only scores when new
    stateManager.appendRows(newRows);
    stateManager.setCurrentCell(
      newRows.first.cells.entries.first.value,
      stateManager.refRows.length - 1,
    );
    stateManager.moveScrollByRow(
      PlutoMoveDirection.down,
      stateManager.refRows.length - 2,
    );

    stateManager.setKeepFocus(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Criticality'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: fabList,
      ),
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoGridOnChangedEvent event) {
          event.row.cells['score']!.value = sqrt(
              (event.row.cells['safety']?.value *
                          event.row.cells['safety']?.value +
                      event.row.cells['regulatory']?.value *
                          event.row.cells['regulatory']?.value +
                      event.row.cells['economic']?.value *
                          event.row.cells['economic']?.value +
                      event.row.cells['throughput']?.value *
                          event.row.cells['throughput']?.value +
                      event.row.cells['quality']?.value *
                          event.row.cells['quality']?.value) /
                  5);
          updateSystem(event.row)
              .then((value) => event.row.cells['id']!.value = value);
          print(event);
        },
        onLoaded: (PlutoGridOnLoadedEvent event) {
          event.stateManager.setSelectingMode(PlutoGridSelectingMode.cell);

          stateManager = event.stateManager;
        },
      ),
    );
  }
}

Future<int> updateSystem(PlutoRow row) async {
  var id = -1;
  if (!row.cells.containsKey('id')) {
    return id;
    //this shouldnt happen
  } else {
    if (row.cells['id']!.value == -1) {
      id = await database!
          .addSystemCriticalitys(row.cells['description']!.value);
    } else {
      id = await database!.updateSystemCriticalitys(
        row.cells['id']!.value,
        row.cells['description']!.value,
        row.cells['safety']!.value,
        row.cells['regulatory']!.value,
        row.cells['economic']!.value,
        row.cells['throughput']!.value,
        row.cells['quality']!.value,
      );
    }
  }
  return id;
}
