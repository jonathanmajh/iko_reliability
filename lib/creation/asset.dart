import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/admin/db_drift.dart';
import 'package:iko_reliability_flutter/admin/end_drawer.dart';
import 'package:iko_reliability_flutter/creation/asset_creation_notifier.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import '../settings/theme_manager.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../main.dart';

void toast(context, msg, [int? time]) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    duration: Duration(seconds: (time ?? 2)),
  ));
}

class AssetPage extends StatefulWidget {
  const AssetPage({Key? key}) : super(key: key);

  @override
  State<AssetPage> createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage>
    with SingleTickerProviderStateMixin {
  List<PlutoColumn> columns = [];
  List<PlutoRow> rows = [];

  late PlutoGridStateManager assetStateManager;
  //late PlutoGridStateManager uploadStateManager;
  late TabController _tabController;

  @override
  void initState() {
    print('init assetpage');
    _tabController = TabController(vsync: this, length: 2);

    super.initState();

    final assetCreationNotifier =
        Provider.of<AssetCreationNotifier>(context, listen: false);

    columns.addAll([
      PlutoColumn(
        width: 350,
        title: 'Hierarchy',
        readOnly: true,
        field: 'hierarchy',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Description',
        readOnly: true,
        field: 'description',
        type: PlutoColumnType.text(),
        width: 900,
      ),
      PlutoColumn(
        width: 100,
        readOnly: true,
        enableAutoEditing: false,
        title: 'Priority',
        field: 'priority',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        width: 100,
        readOnly: true,
        enableAutoEditing: false,
        title: 'Site',
        field: 'site',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        hide: true,
        width: 200,
        readOnly: true,
        enableAutoEditing: false,
        title: 'Status',
        field: 'status',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'ID',
        field: 'id',
        type: PlutoColumnType.number(),
        readOnly: true,
        //hide: true,
      ),
      PlutoColumn(
          title: 'Actions',
          field: 'actions',
          type: PlutoColumnType.text(),
          readOnly: true,
          renderer: (rendererContext) {
            //if asset is uploading, display a loading animation
            if (assetCreationNotifier.loading
                .contains(rendererContext.row.cells['hierarchy']!.value)) {
              return Center(
                child: LoadingAnimationWidget.twoRotatingArc(
                    color: Colors.green, size: 18),
              );
            }

            //if asset is new, display a delete button
            if (rendererContext.cell.value == "new") {
              return IconButton(
                icon: const Icon(
                  Icons.delete,
                ),
                onPressed: () async {
                  var assetNum = rendererContext.row.cells['hierarchy']!.value;
                  try {
                    var id = await assetCreationNotifier.deleteAsset(
                        assetNum, assetCreationNotifier.selectedSite);
                    assetStateManager
                        .removeRows([rendererContext.row], notify: true);
                    toast(context, 'Deleted Asset $assetNum');
                  } catch (err) {
                    toast(context, '$err');
                  }
                },
                iconSize: 18,
                color: Colors.red,
                padding: const EdgeInsets.all(0),
              );
            }

            //If not new asset, then just display a checkmark
            return const Icon(
              Icons.done,
              color: Colors.grey,
              size: 18,
            );
          }),
    ]);
    _changeSite('AA'); //TODO: get user's default site
  }

  @override
  void dispose() {
    //TODO: dispose all controllers
    print('disposed');
    assetStateManager.dispose();

    _tabController.dispose();
    super.dispose();
  }

  /// Changes the site displayed on the plutogrid
  /// based on site id. If the site id is
  /// 'NONE' function will not change the site, and table will
  /// retain its current state.
  Future<void> _changeSite(String site) async {
    print('changing site to $site');
    final assetCreationNotifier =
        Provider.of<AssetCreationNotifier>(context, listen: false);

    await assetCreationNotifier.setSite(site, false);

    print('site changed to $site');

    var fetchedRows = _getChildRows('Top', assetCreationNotifier.parentAssets);
    var value =
        await PlutoGridStateManager.initializeRowsAsync(columns, fetchedRows);
    assetStateManager.refRows.clear();
    assetStateManager.refRows.addAll(value);
    assetStateManager.setShowLoading(false);
    assetStateManager.notifyListeners();
    //workaround since setting the group as expanded does not expand first row
    assetStateManager.toggleExpandedRowGroup(
        rowGroup: assetStateManager.rows.first);
    assetStateManager.toggleExpandedRowGroup(
        rowGroup: assetStateManager.rows.first);
    return;
  }

  /// Returns a list of pluto rows that are children of the parent given
  /// the parent's asset number.
  List<PlutoRow> _getChildRows(
      String parent, Map<String, List<Asset>> parentAssets) {
    List<PlutoRow> rows = [];
    if (parentAssets.containsKey(parent)) {
      for (var child in parentAssets[parent]!) {
        rows.add(PlutoRow(
          cells: {
            'description': PlutoCell(value: child.description),
            'priority': PlutoCell(value: child.priority),
            'hierarchy': PlutoCell(value: child.assetnum),
            'id': PlutoCell(value: child.id),
            'site': PlutoCell(value: child.siteid),
            'status': PlutoCell(
                value: child.newAsset ? 'PENDING UPLOAD' : child.status),
            'actions': PlutoCell(value: child.newAsset ? 'new' : ''),
          },
          type: PlutoRowType.group(
              expanded: true,
              children: FilteredList<PlutoRow>(
                  initialList: _getChildRows(child.assetnum, parentAssets))),
        ));
      }
    }
    return rows;
  }



  int _getAssetIdx(String assetNum) {
    for (PlutoRow plutoRow in assetStateManager.refRows) {
      if (plutoRow.cells['hierarchy']!.value == assetNum) {
        return assetStateManager.refRows.indexOf(plutoRow);
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager themeManager = Provider.of<ThemeManager>(context);
    return Consumer<AssetCreationNotifier>(
        builder: (context, assetCreationNotifier, child) {
      _changeSite(assetCreationNotifier.selectedSite);
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 100,
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(//apply style to all
                    children: [
                  const TextSpan(
                      text: 'Maximo Asset Creator\n',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
                  TextSpan(
                      text: assetCreationNotifier.getSiteDescription(),
                      style: const TextStyle(fontSize: 20)),
                ])),
          ),
          bottom: TabBar(
            controller: _tabController,
            onTap: (value) {
              if (!assetStateManager.rows.first.type.group.expanded &&
                  _tabController.index == 0) {
                assetStateManager.toggleExpandedRowGroup(
                    rowGroup: assetStateManager.rows.first);
              } else if (assetStateManager.rows.first.type.group.expanded &&
                  _tabController.index != 0) {
                assetStateManager.toggleExpandedRowGroup(
                    rowGroup: assetStateManager.rows.first);
              }
            },
            tabs: const <Widget>[
              Padding(padding: EdgeInsets.all(6.0), child: Icon(Icons.home)),
              Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Icon(Icons.cloud_upload)),
            ],
            //title: const Text("Maximo Asset Creator"),
          ),
        ),
        endDrawer: const EndDrawer(),
        body: TabBarView(
          controller: _tabController,
          children: [
            Column(
              children: <Widget>[
                ElevatedButton(
                  child: const Text('print pending'),
                  onPressed: () {
                    for (var asset in assetCreationNotifier.pendingAssets.values
                        .toList()) {
                      print("${asset.toString()}\n\n");
                    }
                  },
                ),
                ElevatedButton(
                  child: const Text('print assets'),
                  onPressed: () async {
                    final assets = await database!
                        .getSiteAssets(assetCreationNotifier.selectedSite);
                    for (var asset in assets) {
                      print(asset.toString() + "\n \n");
                    }
                  },
                ),
                Expanded(
                  //color: const Color.fromARGB(55, 0, 0, 0),
                  //height: 800,
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: PlutoGrid(
                      rowColorCallback: (rowColorContext) {
                        if (rowColorContext.row.cells['status']!.value ==
                            'PENDING UPLOAD') {
                          return (themeManager.isDark
                              ? const Color.fromARGB(255, 18, 92, 3)
                              : const Color.fromARGB(255, 133, 252, 133));
                        } else {
                          return (themeManager.isDark
                              ? const Color.fromARGB(255, 17, 17, 17)
                              : Colors.white);
                        }
                      },
                      columns: columns,
                      rows: rows,
                      onLoaded: (PlutoGridOnLoadedEvent event) {
                        assetStateManager = event.stateManager;
                        event.stateManager.addListener(() {
                          if (assetStateManager.currentRow == null) {
                            return;
                          }
                        });
                        assetStateManager.setShowColumnFilter(true);
                        assetStateManager.setRowGroup(PlutoRowGroupTreeDelegate(
                          resolveColumnDepth: (column) =>
                              assetStateManager.columnIndex(column),
                          showText: (cell) => true,
                          showCount: false,
                          showFirstExpandableIcon: true,
                        ));
                      },
                      configuration: PlutoGridConfiguration(
                          style: themeManager.isDark
                              ? const PlutoGridStyleConfig.dark()
                              : const PlutoGridStyleConfig()),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                //PlutoGrid(columns: columns, rows: rows)
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (assetCreationNotifier.selectedSite == 'NONE') {
              toast(context, 'Please select a site');
              return;
            }
            showDialog<String>(
                context: context,
                builder: (BuildContext context) =>
                    AssetCreationDialog(assetStateManager));
          },
          label: const Text('Create Asset'),
        ),
      );
    });
  }
}

class AssetCreationDialog extends StatefulWidget {
  final PlutoGridStateManager assetStateManager;

  const AssetCreationDialog(this.assetStateManager, {Key? key});

  @override
  State<AssetCreationDialog> createState() => _AssetCreationDialogState(assetStateManager);
}

class _AssetCreationDialogState extends State<AssetCreationDialog> {
  PlutoGridStateManager assetStateManager;

  _AssetCreationDialogState(this.assetStateManager);

  final _formKey = GlobalKey<FormState>();
  final descriptionTextController = TextEditingController();
  final assetNumTextController = TextEditingController();
  final _dropDownKey = GlobalKey<DropdownSearchState<String>>();

  Widget build(BuildContext context) {
    return Consumer<AssetCreationNotifier>(
        builder: (context, assetCreationNotifier, child) {
      return AlertDialog(
        title: const Text('Create Asset'),
        content: Container(
          height: 300,
          width: 300,
          child: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              Card(
                //color: Theme.of(context).colorScheme.,
                elevation: 0,
                child: SizedBox(
                  height: 40,
                  width: 300,
                  child: Center(
                    //padding: const EdgeInsets.all(8.0),
                    child: Text(
                      ('Current Site: ' + assetCreationNotifier.selectedSite),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              DropdownSearch<String>(
                key: _dropDownKey,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a parent asset';
                  }
                  return null;
                },
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                  showSelectedItems: true,
                  searchFieldProps: TextFieldProps(
                    autofocus: true,
                  ),
                ),
                items: assetStateManager.refRows.map((PlutoRow e) {
                  return e.cells['hierarchy']!.value
                      .toString(); //get the first cell value of each row so that the dropdown is in order
                }).toList(),
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Parent Asset",
                    hintText: "Select Parent Asset",
                  ),
                ),
              ),
              TextFormField(
                controller: assetNumTextController,
                decoration: const InputDecoration(
                  hintText: 'New Asset Number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Asset Number must be 5 characters long';
                  }
                  if (value.length != 5) {
                    return 'Asset Number must be 5 characters long';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: descriptionTextController,
                decoration: const InputDecoration(
                  hintText: 'Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description cannot be empty';
                  }
                  return null;
                },
              ),
            ]),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'Cancel');
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              try {
                var assetNum = assetNumTextController.text.toUpperCase();

                var id = await assetCreationNotifier.addAsset(
                    assetNum,
                    descriptionTextController.text,
                    _dropDownKey.currentState!.getSelectedItem!);

                await assetCreationNotifier.setSite(
                    assetCreationNotifier.selectedSite, true);

                assetStateManager.moveScrollByRow(PlutoMoveDirection.up, 0);

                toast(context, 'Created Asset $assetNum, id: $id');

                for (int i = 0; i < assetStateManager.refRows.length; i++) {
                  //when asset is found, scroll to it
                  if (assetStateManager.refRows[i].cells['hierarchy']!.value ==
                      assetNum) {
                    assetStateManager.moveScrollByRow(
                        PlutoMoveDirection.down, i);
                    break;
                  }
                }
              } catch (err) {
                toast(context, '$err');
              }

              Navigator.pop(context, 'OK');
            },
            child: const Text('OK'),
          ),
        ],
      );
    });
  }
}
