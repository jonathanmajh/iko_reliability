import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iko_reliability_flutter/admin/consts.dart';
import 'package:iko_reliability_flutter/settings/theme_manager.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../main.dart';

@RoutePage()
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

// define columns
    columns.addAll([
      PlutoColumn(
        title: '',
        field: 'id',
        type: PlutoColumnType.number(),
        readOnly: true,
        hide: true,
      ),
      // TODO implement site selection for systems
      PlutoColumn(
        width: 150,
        title: 'Production Line',
        field: 'line',
        type: PlutoColumnType.text(),
        renderer: (rendererContext) {
          // change cell to dropdown button
          return DropdownButton<String>(
            value: rendererContext.cell.value,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            isExpanded: true,
            onChanged: (String? value) {
              setState(() {
                stateManager.changeCellValue(rendererContext.cell, value);
              });
            },
            items: productionLines.keys
                .toList()
                .map<DropdownMenuItem<String>>((String key) {
              return DropdownMenuItem<String>(
                value: key,
                child: Text(productionLines[key] ?? 'Unknown'),
              );
            }).toList(),
          );
        },
      ),
      PlutoColumn(
        width: 300,
        title: 'System Name',
        field: 'description',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        width: 250,
        title: 'Safety',
        field: 'safety',
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
                child: Text('$value: ${systemSafety[value]}'),
              );
            }).toList(),
          );
        },
      ),
      PlutoColumn(
        width: 250,
        title: 'Regulatory',
        field: 'regulatory',
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
                child: Text('$value: ${systemRegulatory[value]}'),
              );
            }).toList(),
          );
        },
      ),
      PlutoColumn(
        width: 250,
        title: 'Economic',
        field: 'economic',
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
                child: Text('$value: ${systemEconomic[value]}'),
              );
            }).toList(),
          );
        },
      ),
      PlutoColumn(
        width: 250,
        title: 'Throughput',
        field: 'throughput',
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
                child: Text('$value: ${systemThroughput[value]}'),
              );
            }).toList(),
          );
        },
      ),
      PlutoColumn(
        width: 250,
        title: 'Quality',
        field: 'quality',
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
            items: [0, 1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value: ${systemQuality[value]}'),
              );
            }).toList(),
          );
        },
      ),
      PlutoColumn(
        width: 100,
        title: 'Score',
        field: 'score',
        type: PlutoColumnType.number(
          format: '#.##',
        ),
      ),
      PlutoColumn(
        width: 150,
        title: 'Site',
        field: 'site',
        type: PlutoColumnType.text(),
        readOnly: true,
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
        'line': PlutoCell(value: row.line),
        'site': PlutoCell(value: row.siteid ?? ''),
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
    // populate floating action button
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
            onPressed: () async {
              deleteRow();
              _updateFab();
            },
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

  void deleteRow() async {
    if (stateManager.currentRow != null) {
      final id = stateManager.currentRow!.cells['id']!.value;
      stateManager.removeCurrentRow();
      await database!.deleteSystemCriticalitys(id);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a system to remove'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Criticality'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: fabList,
      ),
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        configuration: PlutoGridConfiguration(
          shortcut: PlutoGridShortcut(actions: {
            ...PlutoGridShortcut.defaultActions,
            // + / - keys should increase / decrease values
            LogicalKeySet(LogicalKeyboardKey.add): CustomAddKeyAction(),
            LogicalKeySet(LogicalKeyboardKey.numpadAdd): CustomAddKeyAction(),
            LogicalKeySet(LogicalKeyboardKey.minus): CustomMinusKeyAction(),
            LogicalKeySet(LogicalKeyboardKey.numpadSubtract):
                CustomMinusKeyAction(),
          }),
          style: context.watch<ThemeManager>().isDark
              ? const PlutoGridStyleConfig.dark()
              : const PlutoGridStyleConfig(),
        ),
        onChanged: (PlutoGridOnChangedEvent event) {
          // score should auto calcualte when values change
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
          debugPrint('$event');
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
        row.cells['line']!.value,
      );
    }
  }
  return id;
}

class CustomAddKeyAction extends PlutoGridShortcutAction {
  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) {
    debugPrint('Pressed add key.');
    if (stateManager.currentColumnField != 'safety' &&
        stateManager.currentColumnField != 'regulatory' &&
        stateManager.currentColumnField != 'economic' &&
        stateManager.currentColumnField != 'throughput' &&
        stateManager.currentColumnField != 'quality') {
      return;
    }
    if (stateManager.currentCell!.value == 10) {
      return;
    }
    if (stateManager.currentCell!.value == 5 &&
        stateManager.currentColumnField == 'quality') {
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
    if (stateManager.currentColumnField != 'safety' &&
        stateManager.currentColumnField != 'regulatory' &&
        stateManager.currentColumnField != 'economic' &&
        stateManager.currentColumnField != 'throughput' &&
        stateManager.currentColumnField != 'quality') {
      return;
    }
    if (stateManager.currentCell!.value == 0) {
      return;
    }
    stateManager.changeCellValue(
        stateManager.currentCell!, stateManager.currentCell!.value - 1);
  }
}
