import 'dart:async';
import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:iko_reliability_flutter/admin/db_drift.dart';
import 'package:iko_reliability_flutter/admin/end_drawer.dart';
import 'package:iko_reliability_flutter/admin/upload_maximo.dart';
import 'package:iko_reliability_flutter/creation/asset_creation_notifier.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import '../settings/theme_manager.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../main.dart';

class AssetPage extends StatefulWidget {
  const AssetPage({Key? key}) : super(key: key);
  @override
  State<AssetPage> createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage>
    with SingleTickerProviderStateMixin {
  Key? currentRowKey;
  List<PlutoColumn> columns = [];
  List<PlutoRow> rows = [];
  Map<String, Asset> siteAssets = {};
  Map<String, Asset> pendingAssets = {};
  Map<String, List<Asset>> parentAssets = {};

  late PlutoGridStateManager assetStateManager;
  late PlutoGridStateManager uploadStateManager;
  late TabController _tabController;

  final assetParentTextController = TextEditingController();
  final descriptionTextController = TextEditingController();
  final assetNumTextController = TextEditingController();
  final assetSiteTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _dropDownKey = GlobalKey<DropdownSearchState<String>>();

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    super.initState();
    final assetCreationNotifier =
        Provider.of<AssetCreationNotifier>(context, listen: false);
    columns.addAll([
      PlutoColumn(
        width: 300,
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
        width: 500,
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

            //if asset is new, display a publish button
            if (rendererContext.cell.value == "new") {
              return IconButton(
                icon: const Icon(
                  Icons.delete,
                ),
                onPressed: () async {
                  var assetNum = rendererContext.row.cells['hierarchy']!.value;
                  try {
                    if (!siteAssets.containsKey(
                        assetNum)) {
                      throw 'Asset ${assetNumTextController.text} does not exist';
                    }
                    if (parentAssets.containsKey(
                        assetNum)) {
                      throw 'Asset ${assetNumTextController.text} has children';
                    }
                    if (!siteAssets[assetNum]!
                        .newAsset) {
                      throw 'Asset already exists in Maximo, cannot delete';
                    }

                    var id = await database!.deleteAsset(
                        assetNum,
                        assetCreationNotifier.selectedSite);
                    assetStateManager
                        .removeRows([rendererContext.row], notify: true);
                    toast(context,
                        'Deleted Asset ${assetNum}');
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
    changeSite('NONE');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Changes the site displayed on the plutogrid
  /// based on site id. If the site id is
  /// 'NONE' function will not change the site, and table will
  /// retain its current state.
  Future<void> changeSite(String site) async {
    print('site changed');
    if (site == 'NONE') {
      return;
    }

    var fetchedRows = await _loadData(site);
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

  /// Loads the data from the database and returns a list of pluto rows
  Future<List<PlutoRow>> _loadData(String site) async {
    siteAssets.clear();
    parentAssets.clear();
    pendingAssets.clear();
    //uploadingAssets.clear();
    final dbrows = await database!
        .getSiteAssets(site); //todo make it able to load other sites
    for (var row in dbrows) {
      if (row.newAsset) {
        pendingAssets[row.assetnum] = row;
      }
      siteAssets[row.assetnum] = row;
      if (parentAssets.containsKey(row.parent)) {
        parentAssets[row.parent]!.add(row);
      } else {
        parentAssets[row.parent ?? "Top"] = [row];
      }
    }
    return getChilds('Top');
  }

  /// Returns a list of pluto rows that are children of the parent given
  /// the parent's asset number.
  List<PlutoRow> getChilds(String parent) {
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
                  initialList: getChilds(child.assetnum))),
        ));
      }
    }
    return rows;
  }

  void toast(context, msg, [int? time]) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: Duration(seconds: (time ?? 2)),
    ));
  }

  int getAssetIdx(String assetNum) {
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
      changeSite(assetCreationNotifier.selectedSite);
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
              'Maximo Asset Creator: ${assetCreationNotifier.selectedSite}'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const <Widget>[
              Icon(Icons.home),
              Icon(Icons.cloud_upload),
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
                    for (var asset in pendingAssets.values.toList()) {
                      print(asset.toString() + "\n \n");
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
                    //print(stateManager.refRows);
                    //print(assetCreationNotifier.selectedSite);
                  },
                ),
                ElevatedButton(
                  child: const Text('Clear assets'),
                  onPressed: () {
                    assetCreationNotifier.clearLoading();
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
                builder: (BuildContext context) => AlertDialog(
                      title: const Text('Create Asset'),
                      content: Container(
                        height: 250,
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
                                    ('Current Site: ' +
                                        assetCreationNotifier.selectedSite),
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
                              items: siteAssets.keys.toList(),
                              dropdownDecoratorProps:
                                  const DropDownDecoratorProps(
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
                            if (_formKey.currentState!.validate()) {
                              //check if asset already exists
                              if (assetStateManager.refRows.any((element) =>
                                  element.cells['hierarchy']!.value ==
                                  assetNumTextController.text.toUpperCase())) {
                                toast(context,
                                    'Asset ${assetNumTextController.text.toUpperCase()} already exists');
                                return;
                              }

                              var id = await database!.addNewAsset(
                                  assetNumTextController.text.toUpperCase(),
                                  assetCreationNotifier.selectedSite,
                                  descriptionTextController.text,
                                  (_dropDownKey.currentState!.getSelectedItem ??
                                      ''));
                              print(id);
                              await changeSite(
                                  assetCreationNotifier.selectedSite);
                              //scroll all the way up
                              assetStateManager.moveScrollByRow(
                                  PlutoMoveDirection.up, 0);
                              for (int i = 0;
                                  i < assetStateManager.refRows.length;
                                  i++) {
                                if (assetStateManager
                                        .refRows[i].cells['hierarchy']!.value ==
                                    assetNumTextController.text.toUpperCase()) {
                                  //scroll down to new asset
                                  assetStateManager.moveScrollByRow(
                                      PlutoMoveDirection.down, i);
                                  break;
                                }
                              }
                              toast(context,
                                  'Created Asset ${assetNumTextController.text.toUpperCase()}, id: $id');
                              Navigator.pop(context, 'OK');
                            }
                          },
                          child: const Text('OK'),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              if (!siteAssets.containsKey(
                                  assetNumTextController.text.toUpperCase())) {
                                throw 'Asset ${assetNumTextController.text} does not exist';
                              }
                              if (parentAssets.containsKey(
                                  assetNumTextController.text.toUpperCase())) {
                                throw 'Asset ${assetNumTextController.text} has children';
                              }
                              if (!siteAssets[assetNumTextController.text
                                      .toUpperCase()]!
                                  .newAsset) {
                                throw 'Asset already exists in Maximo, cannot delete';
                              }

                              var id = await database!.deleteAsset(
                                  assetNumTextController.text.toUpperCase(),
                                  assetCreationNotifier.selectedSite);
                              toast(context,
                                  'Deleted Asset ${assetNumTextController.text.toUpperCase()}');
                              changeSite(assetCreationNotifier.selectedSite);
                            } catch (err) {
                              toast(context, '$err');
                            }
                          },
                          child: const Text('Delete'),
                        )
                      ],
                    ));
          },
          label: const Text('Create Asset'),
        ),
      );
    });
  }
}
