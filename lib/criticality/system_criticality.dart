import 'dart:async';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iko_reliability_flutter/bin/common.dart';
import 'package:iko_reliability_flutter/bin/consts.dart';
import 'package:iko_reliability_flutter/criticality/system_criticality_notifier.dart';
import 'package:iko_reliability_flutter/notifiers/maximo_server_notifier.dart';
import 'package:iko_reliability_flutter/settings/settings_notifier.dart';
import 'package:iko_reliability_flutter/settings/theme_manager.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:provider/provider.dart';

import '../bin/db_drift.dart';
import '../bin/drawer.dart';
import '../bin/end_drawer.dart';
import '../main.dart';

/// System Criticality page for managing and displaying system criticality data.
@RoutePage()
class SystemCriticalityPage extends StatefulWidget {
  /// Constructs the System Criticality page.
  const SystemCriticalityPage({super.key});

  @override
  State<SystemCriticalityPage> createState() => _SystemCriticalityPageState();
}

/// State for the System Criticality page, manages table data and UI.
class _SystemCriticalityPageState extends State<SystemCriticalityPage> {
  List<TrinaColumn> columns = [];
  List<TrinaRow> rows = [];
  List<Widget> fabList = [];
  late TrinaGridStateManager stateManager;
  String loadedSite = '';

  @override
  void initState() {
    super.initState();

    _updateFab();

// define columns
    columns.addAll([
      TrinaColumn(
        title: '',
        field: 'id',
        type: TrinaColumnType.number(),
        readOnly: true,
        hide: true,
      ),
      TrinaColumn(
        width: 150,
        title: 'Site',
        field: 'site',
        type: TrinaColumnType.text(),
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
            items: siteIDAndDescription.keys
                .toList()
                .map<DropdownMenuItem<String>>((String key) {
              return DropdownMenuItem<String>(
                value: key,
                child: Text(siteIDAndDescription[key] ?? 'Unknown'),
              );
            }).toList(),
          );
        },
      ),
      TrinaColumn(
        width: 150,
        title: 'Production Line',
        field: 'line',
        type: TrinaColumnType.text(),
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
      TrinaColumn(
        width: 300,
        title: 'System Name',
        field: 'description',
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        width: 250,
        title: 'Safety',
        field: 'safety',
        type: TrinaColumnType.number(),
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
      TrinaColumn(
        width: 250,
        title: 'Regulatory',
        field: 'regulatory',
        type: TrinaColumnType.number(),
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
      TrinaColumn(
        width: 250,
        title: 'Economic',
        field: 'economic',
        type: TrinaColumnType.number(),
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
      TrinaColumn(
        width: 250,
        title: 'Throughput',
        field: 'throughput',
        type: TrinaColumnType.number(),
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
      TrinaColumn(
        width: 250,
        title: 'Quality',
        field: 'quality',
        type: TrinaColumnType.number(),
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
      TrinaColumn(
        width: 80,
        title: 'Score',
        field: 'score',
        type: TrinaColumnType.number(
          format: '#.##',
        ),
      ),
      TrinaColumn(
          width: 85,
          title: 'Delete?',
          field: 'delete',
          type: TrinaColumnType.text(),
          renderer: (rendererContext) {
            return Row(
              children: [
                SystemDeleteIcon(rendererContext: rendererContext),
              ],
            );
          }),
    ]);
  }

  void _updateFab() {
    // populate floating action button
    List<Widget> temp = [];
    temp = [
      Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: FloatingActionButton(
            heroTag: UniqueKey(),
            onPressed: () async {
              showDialog(
                  context: context,
                  builder: (context) {
                    return const NewSystemForm();
                  });
            },
            child: const Icon(Icons.add),
          )),
    ];

    setState(() {
      fabList = temp;
    });
  }

  // Future<void> addRow() async {
  //   await database!.addSystemCriticalitys('New!');
  //   // whole table gets reloaded when row is added no extra work needed
  // }

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
      drawer: const Drawer(
        //navigation drawer
        child: NavDrawer(),
      ),
      appBar: AppBar(
        title: const Text('System Criticality'),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: fabList,
      ),
      body: FutureBuilder<List<SystemCriticality>>(
        future: database!.getSystemCriticalitiesFiltered(
            context.watch<SelectedSiteNotifier>().selectedSite),
        builder: (BuildContext context,
            AsyncSnapshot<List<SystemCriticality>> snapshot) {
          List<TrinaRow> rows = [];
          if (snapshot.hasData) {
            if (snapshot.data!.isNotEmpty) {
              debugPrint('Reloading Grid');
              for (var row in snapshot.data!) {
                rows.add(TrinaRow(cells: {
                  'id': TrinaCell(value: row.id),
                  'line': TrinaCell(value: row.line),
                  'site': TrinaCell(value: row.siteid ?? 'All'),
                  'description': TrinaCell(value: row.description),
                  'safety': TrinaCell(value: row.safety),
                  'regulatory': TrinaCell(value: row.regulatory),
                  'economic': TrinaCell(value: row.economic),
                  'throughput': TrinaCell(value: row.throughput),
                  'quality': TrinaCell(value: row.quality),
                  'score': TrinaCell(value: row.score),
                  'delete': TrinaCell(value: ''),
                }));
                stateManager.removeAllRows();
                stateManager.appendRows(rows);
              }
            }
          } else if (snapshot.hasError) {
            rows.add(TrinaRow(cells: {
              'id': TrinaCell(value: 0),
              'line': TrinaCell(value: 'C'),
              'site': TrinaCell(value: 'All'),
              'description': TrinaCell(value: snapshot.error),
              'safety': TrinaCell(value: 0),
              'regulatory': TrinaCell(value: 0),
              'economic': TrinaCell(value: 0),
              'throughput': TrinaCell(value: 0),
              'quality': TrinaCell(value: 0),
              'score': TrinaCell(value: 0),
              'delete': TrinaCell(value: ''),
            }));
          } else {
            rows.add(TrinaRow(cells: {
              'id': TrinaCell(value: 0),
              'line': TrinaCell(value: 'C'),
              'site': TrinaCell(value: 'All'),
              'description': TrinaCell(value: 'No Site Selected'),
              'safety': TrinaCell(value: 0),
              'regulatory': TrinaCell(value: 0),
              'economic': TrinaCell(value: 0),
              'throughput': TrinaCell(value: 0),
              'quality': TrinaCell(value: 0),
              'score': TrinaCell(value: 0),
              'delete': TrinaCell(value: ''),
            }));
          }
          return TrinaGrid(
            columns: columns,
            rows: rows,
            configuration: TrinaGridConfiguration(
              shortcut: TrinaGridShortcut(actions: {
                ...TrinaGridShortcut.defaultActions,
                // + / - keys should increase / decrease values
                LogicalKeySet(LogicalKeyboardKey.add): CustomAddKeyAction(),
                LogicalKeySet(LogicalKeyboardKey.numpadAdd):
                    CustomAddKeyAction(),
                LogicalKeySet(LogicalKeyboardKey.minus): CustomMinusKeyAction(),
                LogicalKeySet(LogicalKeyboardKey.numpadSubtract):
                    CustomMinusKeyAction(),
              }),
              style: context.watch<ThemeManager>().theme == ThemeMode.dark
                  ? const TrinaGridStyleConfig.dark()
                  : const TrinaGridStyleConfig(),
            ),
            onChanged: (TrinaGridOnChangedEvent event) async {
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
              context.read<SystemCriticalityNotifier>().systems =
                  await database!.getSystemCriticalitiesFiltered(
                      context.read<SelectedSiteNotifier>().selectedSite);
              debugPrint('$event');
            },
            onLoaded: (TrinaGridOnLoadedEvent event) {
              event.stateManager.setSelectingMode(TrinaGridSelectingMode.cell);
              stateManager = event.stateManager;
              context.read<SystemCriticalityNotifier>().stateManager =
                  stateManager;
            },
          );
        },
      ),
    );
  }
}

Future<int> updateSystem(TrinaRow row) async {
  var id = -1;

  id = await database!.updateSystemCriticalitys(
    key: row.cells['id']!.value,
    description: row.cells['description']!.value,
    safety: row.cells['safety']!.value,
    regulatory: row.cells['regulatory']!.value,
    economic: row.cells['economic']!.value,
    throughput: row.cells['throughput']!.value,
    quality: row.cells['quality']!.value,
    line: row.cells['line']!.value,
    score: row.cells['score']!.value,
    siteid: row.cells['site']!.value,
  );

  final rows = await database!.updateAssetsRelatedSystem(id);
  toast(navigatorKey.currentContext!,
      'Updated $rows assets assigned to ${row.cells['description']!.value}');
  return id;
}

class CustomAddKeyAction extends TrinaGridShortcutAction {
  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
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

class CustomMinusKeyAction extends TrinaGridShortcutAction {
  @override
  void execute({
    required TrinaKeyManagerEvent keyEvent,
    required TrinaGridStateManager stateManager,
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

class NewSystemForm extends StatefulWidget {
  const NewSystemForm({super.key});

  @override
  State<NewSystemForm> createState() => _NewSystemFormState();
}

class _NewSystemFormState extends State<NewSystemForm> {
  final _formKey = GlobalKey<FormState>();
  String selectedSystem = 'C';
  final descriptionTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Add New System'),
        content: SizedBox(
          height: 400,
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField(
                  decoration:
                      const InputDecoration(labelText: 'Production Line'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a Production Line';
                    }
                    return null;
                  },
                  value: selectedSystem,
                  items: productionLines.keys
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                        value: value,
                        child: Text(productionLines[value] ?? ''));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSystem = newValue!;
                    });
                  },
                ),
                TextFormField(
                  controller: descriptionTextController,
                  decoration: const InputDecoration(labelText: 'System Name'),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a system name';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        final stateManager = context
                            .read<SystemCriticalityNotifier>()
                            .stateManager;
                        for (var row in stateManager!.iterateAllRow) {
                          if (row.cells['description']!.value ==
                              descriptionTextController.text) {
                            ScaffoldMessenger.of(navigatorKey.currentContext!)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                    '"${descriptionTextController.text}" already exists'),
                                duration: const Duration(seconds: 10),
                              ),
                            );
                            Navigator.of(navigatorKey.currentContext!).pop();
                            return;
                          }
                        }
                        final row = await database!.addSystemCriticalitys(
                            descriptionTextController.text,
                            selectedSystem,
                            context.read<SelectedSiteNotifier>().selectedSite);
                        final newRow = stateManager.getNewRow();
                        newRow.cells['id'] = TrinaCell(value: row.id);
                        newRow.cells['line']!.value = row.line;
                        newRow.cells['site']!.value = navigatorKey
                            .currentContext!
                            .read<SelectedSiteNotifier>()
                            .selectedSite;
                        newRow.cells['description']!.value = row.description;
                        stateManager.appendRows([newRow]);
                        ScaffoldMessenger.of(navigatorKey.currentContext!)
                            .showSnackBar(
                          const SnackBar(content: Text('Adding New System')),
                        );
                        Navigator.of(navigatorKey.currentContext!).pop();
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class SystemDeleteIcon extends StatefulWidget {
  const SystemDeleteIcon({super.key, required this.rendererContext});

  final TrinaColumnRendererContext rendererContext;

  @override
  State<SystemDeleteIcon> createState() => _SystemDeleteIconState();
}

class _SystemDeleteIconState extends State<SystemDeleteIcon> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
      onPressed: () async {
        final id = widget.rendererContext.row.cells['id']!.value;
        try {
          await database!.deleteSystemCriticalitys(id);
          widget.rendererContext.stateManager
              .removeRows([widget.rendererContext.row]);
        } catch (e) {
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      },
    );
  }
}

class SystemLoadingIndicator extends StatefulWidget {
  const SystemLoadingIndicator({super.key});

  @override
  State<SystemLoadingIndicator> createState() => _SystemLoadingIndicatorState();
}

class _SystemLoadingIndicatorState extends State<SystemLoadingIndicator> {
  String message = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    if (context.watch<SelectedSiteNotifier>().selectedSite.isEmpty) {
      return const SiteToggle();
    }
    systemLoading(
      siteid: context.read<SelectedSiteNotifier>().selectedSite,
      env: context.read<MaximoServerNotifier>().maximoServerSelected,
    );
    return Text(message);
  }

  Future<void> systemLoading(
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
      message = 'Checking system information...';
    });
    var systems = await database!.getSystemCriticalitiesFiltered(
        context.read<SelectedSiteNotifier>().selectedSite);
    if (systems.isEmpty) {
      if (mounted) {
        await database!
            .loadSystems(context.read<SelectedSiteNotifier>().selectedSite);
      }
    }
    if (!mounted) {
      return;
    }
    Navigator.pop(navigatorKey.currentContext!);
    navigatorKey.currentContext!.router.replacePath("/criticality/system");
    Navigator.pop(navigatorKey.currentContext!);
  }
}
