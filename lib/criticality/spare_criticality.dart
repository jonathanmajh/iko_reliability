import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iko_reliability_flutter/criticality/criticality_settings_notifier.dart';
import 'package:iko_reliability_flutter/settings/settings_notifier.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../bin/consts.dart';
import '../bin/db_drift.dart';
import '../bin/drawer.dart';
import '../bin/end_drawer.dart';
import '../main.dart';
import '../settings/theme_manager.dart';
import 'asset_criticality_notifier.dart';
import 'spare_criticality_notifier.dart';

@RoutePage()
class SpareCriticalityPage extends StatefulWidget {
  const SpareCriticalityPage({super.key});

  @override
  State<SpareCriticalityPage> createState() => _SpareCriticalityPageState();
}

class _SpareCriticalityPageState extends State<SpareCriticalityPage> {
  List<PlutoColumn> columns = [];
  String loadedSite = '';
  // used to track if update event is done by system or manually

  List<PlutoColumn> detailColumns = [];
  List<PlutoRow> detailRows = [];

  Key? currentRowKey;

  late PlutoGridStateManager stateManager;
  late PlutoGridStateManager detailStateManager;

  @override
  void initState() {
    super.initState();

    detailColumns.addAll([
      PlutoColumn(
        title: 'PR Number',
        field: 'prnum',
        type: PlutoColumnType.text(),
        readOnly: true,
      ),
      PlutoColumn(
        title: 'PO Number',
        field: 'ponum',
        type: PlutoColumnType.text(),
        readOnly: true,
      ),
      PlutoColumn(
        title: 'Start Date',
        field: 'startDate',
        type: PlutoColumnType.text(),
        readOnly: true,
      ),
      PlutoColumn(
        title: 'End Date',
        field: 'endDate',
        type: PlutoColumnType.text(),
        readOnly: true,
      ),
      PlutoColumn(
        title: 'Lead Time',
        field: 'leadTime',
        type: PlutoColumnType.text(),
        readOnly: true,
      ),
      PlutoColumn(
        title: 'Unit Cost',
        field: 'unitCost',
        type: PlutoColumnType.text(),
        readOnly: true,
      ),
      PlutoColumn(
        width: 100,
        readOnly: true,
        title: 'Site',
        field: 'site',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Included?',
        field: 'included',
        type: PlutoColumnType.text(),
        readOnly: true,
      ),
    ]);

    columns.addAll([
      PlutoColumn(
        title: 'ID',
        field: 'id',
        type: PlutoColumnType.text(),
        readOnly: true,
        hide: true,
      ),
      PlutoColumn(
        title: 'Item Number',
        field: 'itemnum',
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 100,
      ),
      PlutoColumn(
        title: 'Description',
        field: 'description',
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 600,
      ),
      PlutoColumn(
          title: 'Status',
          field: 'status',
          width: 140,
          type: PlutoColumnType.text(),
          renderer: (rendererContext) {
            return Row(
              children: [
                IconButton(
                  tooltip: 'View assets associated with item',
                  icon: const Icon(
                    Icons.info,
                  ),
                  onPressed: () async {
                    var siteid =
                        context.read<SelectedSiteNotifier>().selectedSite;
                    var assets = await database!
                        .assetsAssociatedWithItem(
                            siteid, rendererContext.row.cells['itemnum']!.value)
                        .get();
                    var data = assets
                        .map((e) => DataRow(cells: [
                              DataCell(Text(e.assetnum)),
                              DataCell(Text(e.description ?? '')),
                              DataCell(Text(e.quantity.toString())),
                              DataCell(Text(e.newRPN.toString()))
                            ]))
                        .toList();
                    showDialog(
                        context: navigatorKey.currentContext!,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: DataTable(columns: const [
                              DataColumn(label: Text('Asset Number')),
                              DataColumn(label: Text('Asset Description')),
                              DataColumn(label: Text('Quantity')),
                              DataColumn(label: Text('Asset RPN')),
                            ], rows: data),
                          );
                        });
                  },
                  iconSize: 18,
                  color: Colors.green,
                  padding: const EdgeInsets.all(0),
                ),
                SparePartStatusIcon(rendererContext: rendererContext),
                IconButton(
                  tooltip: 'Refresh purchasing information from Maximo.',
                  icon: const Icon(
                    Icons.refresh,
                  ),
                  onPressed: () async {
                    String itemnum =
                        rendererContext.row.cells['itemnum']!.value;
                    final result = await database!.updateSparePartCriticality(
                      itemnum: itemnum,
                      siteid: context.read<SelectedSiteNotifier>().selectedSite,
                    );
                    setState(() {
                      rendererContext.row.cells['assetRpn']!.value =
                          result.first.assetRPN.toStringAsPrecision(3);
                    });
                    rendererContext.stateManager.changeCellValue(
                        rendererContext.row.cells['cost']!, result.first.cost);
                    rendererContext.stateManager.changeCellValue(
                        rendererContext.row.cells['leadTime']!,
                        result.first.leadTime);
                    rendererContext.stateManager.changeCellValue(
                        rendererContext.row.cells['usage']!,
                        result.first.usage);
                    rendererContext.stateManager.changeCellValue(
                        rendererContext.row.cells['rpn']!, result.first.newRPN);
                    rendererContext.stateManager.changeCellValue(
                        rendererContext.row.cells['newPriority']!,
                        result.first.newPriority);
                  },
                  iconSize: 18,
                  color: Colors.green,
                  padding: const EdgeInsets.all(0),
                ),
              ],
            );
          }),
      PlutoColumn(
        title: 'Asset RPN',
        field: 'assetRpn',
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 100,
      ),
      PlutoColumn(
        title: 'Usage',
        field: 'usage',
        width: 210,
        type: PlutoColumnType.number(),
        renderer: (rendererContext) {
          // change cell to dropdown button
          return DropdownButton<int>(
            value: rendererContext.cell.value,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            isExpanded: true,
            onChanged: (int? value) async {
              context.read<SpareOverrideNotifier>().updateSpareOverride(
                spares: [rendererContext.row.cells['itemnum']!.value],
                status: AssetOverride.breakdowns,
              );
              await database!.updateSpareCriticality(
                usage: value,
                manual: true,
                spareid: rendererContext.row.cells['id']!.value,
              );
              setState(() {
                stateManager.changeCellValue(rendererContext.cell, value);
              });
            },
            items: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                .map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child:
                    Text('$value: ${usageRating[value]?["description"] ?? ""}'),
              );
            }).toList(),
          );
        },
      ),
      PlutoColumn(
        title: 'Lead Time',
        field: 'leadTime',
        width: 180,
        type: PlutoColumnType.number(),
        renderer: (rendererContext) {
          // change cell to dropdown button
          return DropdownButton<int>(
            value: rendererContext.cell.value,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            isExpanded: true,
            onChanged: (int? value) async {
              context.read<SpareOverrideNotifier>().updateSpareOverride(
                spares: [rendererContext.row.cells['itemnum']!.value],
                status: AssetOverride.breakdowns,
              );
              await database!.updateSpareCriticality(
                leadTime: value,
                manual: true,
                spareid: rendererContext.row.cells['id']!.value,
              );
              setState(() {
                stateManager.changeCellValue(rendererContext.cell, value);
              });
            },
            items: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                .map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(
                    '$value: ${leadTimeRating[value]?["description"] ?? ""}'),
              );
            }).toList(),
          );
        },
      ),
      PlutoColumn(
        title: 'Cost',
        field: 'cost',
        width: 180,
        type: PlutoColumnType.number(),
        renderer: (rendererContext) {
          // change cell to dropdown button
          return DropdownButton<int>(
            value: rendererContext.cell.value,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            isExpanded: true,
            onChanged: (int? value) async {
              context.read<SpareOverrideNotifier>().updateSpareOverride(
                spares: [rendererContext.row.cells['itemnum']!.value],
                status: AssetOverride.breakdowns,
              );
              await database!.updateSpareCriticality(
                cost: value,
                manual: true,
                spareid: rendererContext.row.cells['id']!.value,
              );
              setState(() {
                stateManager.changeCellValue(rendererContext.cell, value);
              });
            },
            items: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                .map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child:
                    Text('$value: ${costRating[value]?["description"] ?? ""}'),
              );
            }).toList(),
          );
        },
      ),
      PlutoColumn(
        title: 'RPN',
        field: 'rpn',
        type: PlutoColumnType.number(),
        readOnly: true,
        width: 75,
      ),
      PlutoColumn(
        title: 'New Priority',
        field: 'newPriority',
        type: PlutoColumnType.number(),
        width: 100,
        renderer: (rendererContext) {
          // change cell to dropdown button
          return DropdownButton<int>(
            value: rendererContext.cell.value,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            isExpanded: true,
            onChanged: (int? value) async {
              context.read<SpareOverrideNotifier>().updateSpareOverride(
                spares: [rendererContext.row.cells['itemnum']!.value],
                status: AssetOverride.priority,
              );
              await database!.updateSpareCriticality(
                newPriority: value,
                manualPriority: true,
                spareid: rendererContext.row.cells['id']!.value,
              );
              setState(() {
                stateManager.changeCellValue(rendererContext.cell, value);
                rendererContext.row.cells['override']!.value =
                    AssetOverride.priority;
              });
            },
            items:
                spareCriticality.keys.map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value: ${spareCriticality[value]}'),
              );
            }).toList(),
          );
        },
      ),
      PlutoColumn(
          width: 100,
          title: 'Override',
          field: 'override',
          type: PlutoColumnType.text(),
          renderer: (rendererContext) {
            return Row(
              children: [
                OverrideSparePartStatusIcon(rendererContext: rendererContext),
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

      fetchPurchaseHistory(
          itemnum: stateManager.currentRow!.cells['itemnum']!.value);
    }
  }

  void fetchPurchaseHistory({required String itemnum}) async {
    final selectedSite = context.read<SelectedSiteNotifier>().selectedSite;
    var itemPurchases = await database!.getItemPurchases(itemnum: itemnum);
    List<PlutoRow> rows = [];
    List<PlutoRow> excludeRows = [];
    for (var itemPurchase in itemPurchases) {
      if (isPurchaseOrderInRange(itemPurchase, selectedSite)) {
        rows.add(PlutoRow(cells: {
          'prnum': PlutoCell(value: itemPurchase.prnum),
          'ponum': PlutoCell(value: itemPurchase.ponum),
          'startDate': PlutoCell(value: itemPurchase.startDate),
          'endDate': PlutoCell(value: itemPurchase.endDate),
          'leadTime': PlutoCell(value: itemPurchase.leadTime),
          'unitCost': PlutoCell(value: itemPurchase.unitCost),
          'site': PlutoCell(value: siteIDAndDescription[itemPurchase.siteid]),
          'included': PlutoCell(value: 'Yes'),
        }));
      } else {
        excludeRows.add(PlutoRow(cells: {
          'prnum': PlutoCell(value: itemPurchase.prnum),
          'ponum': PlutoCell(value: itemPurchase.ponum),
          'startDate': PlutoCell(value: itemPurchase.startDate),
          'endDate': PlutoCell(value: itemPurchase.endDate),
          'leadTime': PlutoCell(value: itemPurchase.leadTime),
          'unitCost': PlutoCell(value: itemPurchase.unitCost),
          'site': PlutoCell(value: siteIDAndDescription[itemPurchase.siteid]),
          'included': PlutoCell(value: 'No'),
        }));
      }
    }
    detailStateManager.removeRows(detailStateManager.rows);
    detailStateManager.resetCurrentState();
    detailStateManager.appendRows([...rows, ...excludeRows]);

    detailStateManager.setShowLoading(false);
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
        title: const Text('Spare Part Criticality'),
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
      body: FutureBuilder<List<SpareCriticalityWithItem>>(
        future: () async {
          return database!.getSpareCriticalities(
              siteid: context.watch<SelectedSiteNotifier>().selectedSite);
        }(),
        builder: (BuildContext context,
            AsyncSnapshot<List<SpareCriticalityWithItem>> snapshot) {
          List<PlutoRow> rows = [];
          debugPrint('SPC - builder');
          if (snapshot.hasData) {
            if (snapshot.data!.isNotEmpty) {
              if (loadedSite != snapshot.data?.first.spareCriticality.siteid ||
                  context.watch<SpareCriticalityNotifier>().updateGrid) {
                loadedSite = snapshot.data!.first.spareCriticality.siteid;
                for (var row in snapshot.data!) {
                  AssetOverride overrideStatus = AssetOverride.none;
                  if (row.spareCriticality.manualPriority) {
                    overrideStatus = AssetOverride.priority;
                  }
                  if (row.spareCriticality.manual) {
                    overrideStatus = AssetOverride.breakdowns;
                  }
                  rows.add(PlutoRow(cells: {
                    'itemnum': PlutoCell(value: row.spareCriticality.itemnum),
                    'description':
                        PlutoCell(value: row.item?.description ?? ''),
                    'assetRpn': PlutoCell(
                        value: row.spareCriticality.assetRPN
                            .toStringAsPrecision(3)),
                    'usage': PlutoCell(value: row.spareCriticality.usage),
                    'leadTime': PlutoCell(value: row.spareCriticality.leadTime),
                    'cost': PlutoCell(value: row.spareCriticality.cost),
                    'rpn': PlutoCell(value: row.spareCriticality.newRPN),
                    'newPriority': PlutoCell(
                        value: row.spareCriticality.newPriority > 0
                            ? row.spareCriticality.newPriority
                            : context
                                .read<SpareCriticalityNotifier>()
                                .rpnFindDistribution(
                                    row.spareCriticality.newRPN)),
                    'id': PlutoCell(value: row.spareCriticality.id),
                    'status': PlutoCell(value: ''),
                    'override': PlutoCell(value: overrideStatus),
                  }));
                }
                stateManager.removeAllRows();
                stateManager.appendRows(rows);
                final settings =
                    context.watch<SpareCriticalitySettingNotifier>();
                if (settings.sortType != null) {
                  switch (settings.sortType) {
                    case PlutoColumnSort.ascending:
                      stateManager.sortAscending(settings.sortColumn!);
                      break;
                    case PlutoColumnSort.descending:
                      stateManager.sortDescending(settings.sortColumn!);
                      break;
                    default:
                  }
                  stateManager.notifyListeners();
                }
                context.watch<SpareCriticalityNotifier>().updateGrid = false;
              }
            }
          } else if (snapshot.hasError) {
            rows.add(PlutoRow(cells: {
              'itemnum': PlutoCell(value: 'Error!'),
              'description': PlutoCell(value: ''),
              'assetRpn': PlutoCell(value: snapshot.error),
              'usage': PlutoCell(value: 0),
              'leadTime': PlutoCell(value: 0),
              'cost': PlutoCell(value: 0),
              'rpn': PlutoCell(value: 0),
              'newPriority': PlutoCell(value: 0),
              'id': PlutoCell(value: 0),
              'status': PlutoCell(value: ''),
              'override': PlutoCell(value: ''),
            }));
          } else {
            rows.add(PlutoRow(cells: {
              'itemnum': PlutoCell(value: ''),
              'description': PlutoCell(value: ''),
              'assetRpn': PlutoCell(value: 'No Site Selected'),
              'usage': PlutoCell(value: 0),
              'leadTime': PlutoCell(value: 0),
              'cost': PlutoCell(value: 0),
              'rpn': PlutoCell(value: 0),
              'newPriority': PlutoCell(value: 0),
              'id': PlutoCell(value: 0),
              'status': PlutoCell(value: ''),
              'override': PlutoCell(value: ''),
            }));
          }
          return PlutoDualGrid(
            isVertical: true,
            display: PlutoDualGridDisplayRatio(ratio: 0.75),
            gridPropsA: PlutoDualGridProps(
              columns: columns,
              rows: rows,
              onLoaded: (PlutoGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                context.read<SpareCriticalityNotifier>().stateManager =
                    stateManager;
                event.stateManager.addListener(gridAHandler);
                stateManager.setShowColumnFilter(true);
              },
              onSorted: (PlutoGridOnSortedEvent event) {
                context.read<SpareCriticalitySettingNotifier>().sortColumn =
                    event.column;
                context.read<SpareCriticalitySettingNotifier>().sortType =
                    event.column.sort;
              },
              onChanged: (PlutoGridOnChangedEvent event) async {
                // recalculate rpn number > nre priority if not overwritten
                if (![4, 5, 6].contains(event.columnIdx)) {
                  // only need to update if changes made to these columns
                  return;
                }
                debugPrint('running grid A on change event');
                final newRpn = rpnFunc(await database!
                    .getSpareCriticality(id: event.row.cells['id']!.value));
                debugPrint(newRpn.toString());
                if (newRpn > 0) {
                  await database!.updateSpareCriticality(
                    newRPN: newRpn,
                    spareid: event.row.cells['id']!.value,
                  );
                  event.row.cells['rpn']!.value = newRpn;
                  if (context.mounted) {
                    final newPriority = context
                        .read<SpareCriticalityNotifier>()
                        .rpnFindDistribution(newRpn);
                    if (event.row.cells['override']!.value !=
                        AssetOverride.priority) {
                      event.row.cells['newPriority']!.value = newPriority;
                      event.row.cells['override']!.value =
                          AssetOverride.breakdowns;
                    }
                  }
                }
              },
              configuration: PlutoGridConfiguration(
                  style: themeManager.theme == ThemeMode.dark
                      ? const PlutoGridStyleConfig.dark()
                      : const PlutoGridStyleConfig(),
                  shortcut: PlutoGridShortcut(actions: {
                    ...PlutoGridShortcut.defaultActions,
                    LogicalKeySet(LogicalKeyboardKey.add): CustomAddKeyAction(),
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
                  style: themeManager.theme == ThemeMode.dark
                      ? const PlutoGridStyleConfig.dark()
                      : const PlutoGridStyleConfig()),
              columns: detailColumns,
              rows: detailRows,
              onLoaded: (PlutoGridOnLoadedEvent event) {
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
                ? PlutoDualGridDivider.dark(
                    indicatorColor: Theme.of(context).colorScheme.onSurface)
                : const PlutoDualGridDivider(),
          );
        },
      ),
    );
  }
}

class CustomAddKeyAction extends PlutoGridShortcutAction {
  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) async {
    debugPrint('Pressed add key.');
    if (stateManager.currentColumnField != 'usage' &&
        stateManager.currentColumnField != 'leadTime' &&
        stateManager.currentColumnField != 'cost') {
      return;
    }
    if (stateManager.currentCell!.value == 10) {
      return;
    }
    switch (stateManager.currentColumnField) {
      case 'usage':
        await database!.updateSpareCriticality(
          usage: stateManager.currentCell!.value + 1,
          manual: true,
          spareid: stateManager.currentRow!.cells['id']!.value,
        );
      case 'leadTime':
        await database!.updateSpareCriticality(
          leadTime: stateManager.currentCell!.value + 1,
          manual: true,
          spareid: stateManager.currentRow!.cells['id']!.value,
        );
      case 'cost':
        await database!.updateSpareCriticality(
          cost: stateManager.currentCell!.value + 1,
          manual: true,
          spareid: stateManager.currentRow!.cells['id']!.value,
        );
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
  }) async {
    debugPrint('Pressed minus key.');
    if (stateManager.currentColumnField != 'usage' &&
        stateManager.currentColumnField != 'leadTime' &&
        stateManager.currentColumnField != 'cost') {
      return;
    }
    if (stateManager.currentCell!.value == 0) {
      return;
    }
    switch (stateManager.currentColumnField) {
      case 'usage':
        await database!.updateSpareCriticality(
          usage: stateManager.currentCell!.value - 1,
          manual: true,
          spareid: stateManager.currentRow!.cells['id']!.value,
        );
      case 'leadTime':
        await database!.updateSpareCriticality(
          leadTime: stateManager.currentCell!.value - 1,
          manual: true,
          spareid: stateManager.currentRow!.cells['id']!.value,
        );
      case 'cost':
        await database!.updateSpareCriticality(
          cost: stateManager.currentCell!.value - 1,
          manual: true,
          spareid: stateManager.currentRow!.cells['id']!.value,
        );
    }
    stateManager.changeCellValue(
        stateManager.currentCell!, stateManager.currentCell!.value - 1);
  }
}

class SparePartsLoadingIndicator extends StatefulWidget {
  const SparePartsLoadingIndicator({super.key, this.forceUpdate = false});
  final bool forceUpdate;

  @override
  State<SparePartsLoadingIndicator> createState() =>
      _SparePartsLoadingIndicatorState();
}

class _SparePartsLoadingIndicatorState
    extends State<SparePartsLoadingIndicator> {
  String message = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    if (context.watch<SelectedSiteNotifier>().selectedSite.isEmpty) {
      return const SiteToggle();
    }
    sparePartLoading(
      siteid: context.read<SelectedSiteNotifier>().selectedSite,
      env: context.read<MaximoServerNotifier>().maximoServerSelected,
    );
    return Text(message);
  }

  Future<void> sparePartLoading(
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
      message = 'Checking spare parts information...';
    });
    final dataCached = await database!.checkSpareParts(siteid: siteid);
    if (!dataCached || widget.forceUpdate) {
      try {
        setState(() {
          message = 'Loading item information from Maximo...';
        });
        await database!.getItemDetailsMaximo(
          siteid: siteid,
          env: env,
        );
        setState(() {
          message = 'Loading spare parts information from Maximo...';
        });
        await database!.getSparePartsMaximo(
          siteid: siteid,
          env: env,
        );
        setState(() {
          message = 'Loading purchasing information from Maximo...';
        });
        await database!.getPurchasesMaximo(
          siteid: siteid,
          env: env,
        );
      } catch (e) {
        setState(() {
          message = e.toString();
        });
        return;
      }
      showDataAlert(
        [
          'Please use the "Refresh Data from Maximo" button in the side bar after changing settings',
        ],
        'Purchase History Calculation Settings',
        [const PurchaseHistorySettingDialog()],
      ).then((value) async {
        try {
          setState(() {
            message =
                'Calculating spare part criticality...\nThis step can take significant time';
          });
          await database!.computeSparePartCriticality(siteid: siteid);
          Navigator.pop(navigatorKey.currentContext!);
          navigatorKey.currentContext!.router.pushNamed("/criticality/spare");
          Navigator.pop(navigatorKey.currentContext!); // close the drawer
        } catch (e) {
          setState(() {
            message = e.toString();
          });
          return;
        }
      });
    } else {
      Navigator.pop(navigatorKey.currentContext!);
      navigatorKey.currentContext!.router.pushNamed("/criticality/spare");
      Navigator.pop(navigatorKey.currentContext!); // close the drawer
    }
  }
}

double rpnFunc(SpareCriticality sparePart) {
  try {
    return sparePart.assetRPN *
        sparePart.usage *
        sparePart.leadTime *
        sparePart.cost;
  } catch (e) {
    return -1;
  }
}

class SparePartStatusIcon extends StatefulWidget {
  const SparePartStatusIcon({
    super.key,
    required this.rendererContext,
  });

  final PlutoColumnRendererContext rendererContext;

  @override
  State<SparePartStatusIcon> createState() => _StatusIconState();
}

class _StatusIconState extends State<SparePartStatusIcon> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PlutoGridStateManager stateManager = widget.rendererContext.stateManager;
    var sparePartRpn = widget.rendererContext.row.cells['rpn']!.value;
    Color color = Colors.orange;
    IconData icon = Icons.pending;
    String statusText = 'Please check columns to generate RPN';
    String searchText = 'pending';
    if (sparePartRpn > 0) {
      icon = Icons.check_circle;
      color = Colors.green;
      statusText = 'RPN generated';
      searchText = 'complete';
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

class OverrideSparePartStatusIcon extends StatefulWidget {
  const OverrideSparePartStatusIcon({
    super.key,
    required this.rendererContext,
  });

  final PlutoColumnRendererContext rendererContext;

  @override
  State<OverrideSparePartStatusIcon> createState() =>
      _OverrideStatusIconState();
}

class _OverrideStatusIconState extends State<OverrideSparePartStatusIcon> {
  @override
  Widget build(BuildContext context) {
    PlutoGridStateManager stateManager = widget.rendererContext.stateManager;
    Color color = Colors.green;
    IconData icon = Icons.lock_open;
    String statusText = '';
    switch (widget.rendererContext.row.cells['override']!.value) {
      case AssetOverride.none:
        statusText = 'No Overrides';

      case AssetOverride.priority:
        icon = Icons.lock;
        color = Colors.orange;
        statusText = 'New Priority is overridden';

      case AssetOverride.breakdowns:
        icon = Icons.lock_clock;
        color = Colors.orange;
        statusText = 'Purchasing information overridden';
    }
    return IconButton(
      icon: Icon(
        icon,
        color: color,
      ),
      onPressed: () async {
        stateManager.changeCellValue(
          widget.rendererContext.cell,
          AssetOverride.none,
        );
        await database!.removeSparePartOverride(
            spareid: widget.rendererContext.row.cells['id']!.value);
        widget.rendererContext.stateManager.changeCellValue(
          widget.rendererContext.row.cells['cost']!,
          0,
        );
        widget.rendererContext.stateManager.changeCellValue(
          widget.rendererContext.row.cells['leadTime']!,
          0,
        );
        widget.rendererContext.stateManager.changeCellValue(
          widget.rendererContext.row.cells['usage']!,
          0,
        );
        widget.rendererContext.stateManager.changeCellValue(
          widget.rendererContext.row.cells['newPriority']!,
          0,
        );
        setState(() {
          widget.rendererContext.row.cells['rpn']!.value = 0;
        });
      },
      tooltip: statusText,
    );
  }
}

Future<String> calculateRPNDistributionSpares(BuildContext context) async {
  try {
    SpareCriticalitySettingNotifier spareCritifcalitySettingNotifier =
        context.read<SpareCriticalitySettingNotifier>();
    SpareCriticalityNotifier spareCritifcalityNotifier =
        context.read<SpareCriticalityNotifier>();
    var result = await database!
        .uniqueRpnNumbersSpare(
            context.read<SelectedSiteNotifier>().selectedSite)
        .get();
    Map<double, int> frequencyOfRPNs = {};
    for (var x in result) {
      frequencyOfRPNs[x.newRPN] = x.countitemnum;
    }
    List<double> newCutoffs = calculateRPNCutOffsSpares(
      targetPercentages: spareCritifcalitySettingNotifier.abcCriticality,
      frequencyOfRPNs: frequencyOfRPNs,
    ).ordered();
    spareCritifcalityNotifier.setRpnCutoffs(newCutoffs);
    debugPrint('new rpn cutoffs: ${spareCritifcalityNotifier.rpnCutoffs}');
    if (newCutoffs.toSet().length != newCutoffs.length) {
      return 'Duplicate values in RPN cutoffs\nIncrease percentage of duplicate value, Or ensure RPN values are more spread out';
    }
    spareCritifcalityNotifier.updateGrid = true;
    debugPrint(spareCritifcalityNotifier.updateGrid.toString());
  } catch (e) {
    debugPrint(e.toString());
    return e.toString();
  }
  return 'RPN cutoffs successfully calculated';
}

class SpareCriticalityConfig extends StatefulWidget {
  const SpareCriticalityConfig({super.key});

  @override
  State<SpareCriticalityConfig> createState() => _SpareCriticalityConfigState();
}

class _SpareCriticalityConfigState extends State<SpareCriticalityConfig> {
  TextEditingController percentAController = TextEditingController();
  TextEditingController percentBController = TextEditingController();
  TextEditingController percentCController = TextEditingController();
  TextEditingController sumController = TextEditingController();

  @override
  void dispose() {
    percentAController.dispose();
    percentBController.dispose();
    percentCController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpareCriticalitySettingNotifier>(
      builder: (context, notifier, child) {
        percentAController.text = notifier.percentA.toString();
        percentBController.text = notifier.percentB.toString();
        percentCController.text = notifier.percentC.toString();
        sumController.text =
            (notifier.percentA + notifier.percentB + notifier.percentC)
                .toString();
        final selectedSite = context.read<SelectedSiteNotifier>().selectedSite;
        return Column(children: [
          TextField(
            controller: percentAController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'A%'),
            onChanged: (value) async {
              await notifier.setPercentages(
                  percentA: int.parse(value), selectedSite: selectedSite);
              sumController.text =
                  (notifier.percentA + notifier.percentB + notifier.percentC)
                      .toString();
            },
          ),
          TextField(
            controller: percentBController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'B%'),
            onChanged: (value) async {
              await notifier.setPercentages(
                  percentB: int.parse(value), selectedSite: selectedSite);
              sumController.text =
                  (notifier.percentA + notifier.percentB + notifier.percentC)
                      .toString();
            },
          ),
          TextField(
            controller: percentCController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'C%'),
            onChanged: (value) async {
              await notifier.setPercentages(
                  percentC: int.parse(value), selectedSite: selectedSite);
              sumController.text =
                  (notifier.percentA + notifier.percentB + notifier.percentC)
                      .toString();
            },
          ),
          TextField(
            controller: sumController,
            decoration: const InputDecoration(
                labelText: 'Ensure Percentages add to 100%'),
            readOnly: true,
          ),
        ]);
      },
    );
  }
}

class PurchaseHistorySettingDialog extends StatefulWidget {
  const PurchaseHistorySettingDialog({super.key});

  @override
  State<PurchaseHistorySettingDialog> createState() =>
      _PurchaseHistorySettingDialogState();
}

class _PurchaseHistorySettingDialogState
    extends State<PurchaseHistorySettingDialog> {
  DateTime? startDate;

  DateTime? endDate;

  WorkOrderFilterBy? siteFilterBy;

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController siteFilterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SpareCriticalitySettingNotifier spareCriticalitySettingsNotifier =
        context.read<SpareCriticalitySettingNotifier>();
    startDate = spareCriticalitySettingsNotifier.purchaseCutoffStart;
    endDate = spareCriticalitySettingsNotifier.purchaseCutoffEnd;
    siteFilterBy = spareCriticalitySettingsNotifier.purchaseFilterBy;
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
    return Consumer<SpareCriticalitySettingNotifier>(
        builder: (context, notifier, child) {
      return Column(
        children: [
          TextField(
            controller: startDateController,
            decoration: const InputDecoration(
                icon: Icon(Icons.calendar_month),
                labelText: 'Ignore Purchases Before'),
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
                  context
                      .read<SpareCriticalitySettingNotifier>()
                      .setPurchaseSettings(
                          selectedSite:
                              context.read<SelectedSiteNotifier>().selectedSite,
                          purchaseCutoffStart: pickedDate);
                });
              }
            },
          ),
          TextField(
            controller: endDateController,
            decoration: const InputDecoration(
                icon: Icon(Icons.calendar_month),
                labelText: 'Ignore Purchases After'),
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
                  context
                      .read<SpareCriticalitySettingNotifier>()
                      .setPurchaseSettings(
                          selectedSite:
                              context.read<SelectedSiteNotifier>().selectedSite,
                          purchaseCutoffEnd: pickedDate);
                });
              }
            },
          ),
          ListTile(
              title: const Text('Purchases Site Filter'),
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
                      context
                          .read<SpareCriticalitySettingNotifier>()
                          .setPurchaseSettings(
                              selectedSite: context
                                  .read<SelectedSiteNotifier>()
                                  .selectedSite,
                              purchaseFilterBy: newValue);
                    });
                  })),
        ],
      );
    });
  }
}

bool isPurchaseOrderInRange(
  Purchase purchase,
  String selectedSite,
) {
  final spareCriticalitySetting =
      navigatorKey.currentContext!.read<SpareCriticalitySettingNotifier>();
  if (purchase.endDate == null) {
    return false;
  }
  DateTime startDate = DateTime.parse(purchase.startDate);
  if (startDate.compareTo(spareCriticalitySetting.purchaseCutoffStart) < 0) {
    return false;
  }
  if (startDate.compareTo(spareCriticalitySetting.purchaseCutoffEnd) > 0) {
    return false;
  }
  if (spareCriticalitySetting.purchaseFilterBy ==
      WorkOrderFilterBy.currentSite) {
    if (purchase.siteid != selectedSite) {
      return false;
    }
  }
  return true;
}
