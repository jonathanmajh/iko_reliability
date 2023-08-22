import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';

import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/admin/consts.dart';
import 'package:iko_reliability_flutter/admin/db_drift.dart';
import 'package:iko_reliability_flutter/admin/end_drawer.dart';
import 'package:iko_reliability_flutter/creation/asset_creation_notifier.dart';
import 'package:iko_reliability_flutter/creation/site_change_notifier.dart';
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

@RoutePage()
class AssetPage extends StatefulWidget {
  const AssetPage({Key? key}) : super(key: key);

  @override
  State<AssetPage> createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage>
    with SingleTickerProviderStateMixin {
  List<PlutoColumn> columns = [];
  List<PlutoRow> rows = [];

  int fabIndex = 0;
  List fabList = [
    //pairs of icons and alert dialogs
    [const Icon(Icons.add), const AssetCreationDialog()],
    [const Icon(Icons.upload), const AssetUploadDialog()],
  ];

  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(_updateFab);

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _updateFab() {
    setState(() {
      fabIndex = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // toolbarHeight: 100,
        title: Text(
            'Maximo Asset Creator - ${siteIDAndDescription[context.watch<SiteChangeNotifier>().selectedSite] ?? 'No Site Selected'}'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (value) {},
          tabs: const <Widget>[
            Padding(padding: EdgeInsets.all(6.0), child: Icon(Icons.home)),
            Padding(
                padding: EdgeInsets.all(6.0), child: Icon(Icons.cloud_upload)),
          ],
        ),
      ),
      endDrawer: const EndDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: AssetCreationGrid(),
                ),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: AssetUploadGrid(),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.indexIsChanging) {
            toast(context, 'Please wait for tab to load');
            return;
          }

          if (context.read<AssetCreationNotifier>().selectedSite == 'NONE') {
            toast(context, 'Please select a site');
            return;
          }

          showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                return fabList[fabIndex][1];
              });
        },
        child: fabList[fabIndex][0],
      ),
    );
  }
}

class AssetCreationGrid extends StatefulWidget {
  const AssetCreationGrid({Key? key}) : super(key: key);

  @override
  State<AssetCreationGrid> createState() => _AssetCreationGridState();
}

class _AssetCreationGridState extends State<AssetCreationGrid> {
  late PlutoGridStateManager stateManager;

  List<PlutoColumn> columns = [];
  List<PlutoRow> rows = [];

  @override
  void dispose() {
    //stateManager.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    columns.addAll([
      PlutoColumn(
        width: 350,
        title: 'Hierarchy',
        readOnly: true,
        field: 'hierarchy',
        type: PlutoColumnType.text(),
        //sort: PlutoColumnSort.ascending,
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
        title: 'Site',
        field: 'site',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
          title: 'Actions',
          field: 'actions',
          type: PlutoColumnType.text(),
          readOnly: true,
          renderer: (rendererContext) {
            //if asset is new, display a delete button
            var assetStatus = context
                .read<AssetCreationNotifier>()
                .pendingAssets[rendererContext.row.cells['hierarchy']!.value];
            if (assetStatus == "new") {
              return IconButton(
                icon: const Icon(
                  Icons.delete,
                ),
                onPressed: () async {
                  var assetNum = rendererContext.row.cells['hierarchy']!.value;
                  try {
                    await context.read<AssetCreationNotifier>().deleteAsset(
                        assetNum,
                        context.read<AssetCreationNotifier>().selectedSite);
                    stateManager
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

            if (assetStatus == "warning") {
              return IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AssetErrorMessageDialog(
                              assetNum: rendererContext
                                  .row.cells['hierarchy']!.value);
                        });
                  },
                  icon: const Icon(
                    Icons.warning,
                    color: Colors.yellow,
                    size: 18,
                  ));
            }

            if (assetStatus == 'fail') {
              return const Icon(
                Icons.close,
                color: Colors.red,
                size: 18,
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
  }

  Future<void> _loadGrid(String site) async {
    print('load grid');
    final assetCreationNotifier =
        Provider.of<AssetCreationNotifier>(context, listen: false);

    var fetchedRows = _getChildRows('Top', assetCreationNotifier.parentAssets);
    var value =
        await PlutoGridStateManager.initializeRowsAsync(columns, fetchedRows);
    stateManager.refRows.clear();
    stateManager.refRows.addAll(value);
    stateManager.setShowLoading(false);
    stateManager.notifyListeners();
    //workaround since setting the group as expanded does not expand first row
    stateManager.toggleExpandedRowGroup(rowGroup: stateManager.rows.first);
    stateManager.toggleExpandedRowGroup(rowGroup: stateManager.rows.first);
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
            'hierarchy': PlutoCell(value: child.assetnum),
            'site': PlutoCell(value: child.siteid),
            'actions': PlutoCell(value: ''),
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

  /// Returns the index of the row with the given asset number
  int _getAssetIdx(String assetNum) {
    for (PlutoRow plutoRow in stateManager.refRows) {
      if (plutoRow.cells['hierarchy']!.value == assetNum) {
        return stateManager.refRows.indexOf(plutoRow);
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager themeManager =
        Provider.of<ThemeManager>(context, listen: true);

    return Consumer<AssetCreationNotifier>(
        builder: (context, assetCreationNotifier, child) {
      _loadGrid(assetCreationNotifier.selectedSite);
      return PlutoGrid(
        rowColorCallback: (rowColorContext) {
          var assetStatus = context
              .read<AssetCreationNotifier>()
              .pendingAssets[rowColorContext.row.cells['hierarchy']!.value];
          if (assetStatus == 'new') {
            return (themeManager.isDark
                ? const Color.fromARGB(255, 18, 92, 3)
                : const Color.fromARGB(255, 133, 252, 133));
          } else if (assetStatus == 'warning' || assetStatus == 'fail') {
            return (themeManager.isDark
                ? const Color.fromARGB(255, 94, 15, 15)
                : const Color.fromARGB(255, 221, 93, 93));
          } else {
            return (themeManager.isDark
                ? const Color.fromARGB(255, 17, 17, 17)
                : Colors.white);
          }
        },
        columns: columns,
        rows: rows,
        onLoaded: (PlutoGridOnLoadedEvent event) {
          stateManager = event.stateManager;
          stateManager.setShowColumnFilter(true);
          stateManager.setRowGroup(PlutoRowGroupTreeDelegate(
            resolveColumnDepth: (column) => stateManager.columnIndex(column),
            showText: (cell) => true,
            showCount: false,
            showFirstExpandableIcon: true,
          ));
        },
        configuration: PlutoGridConfiguration(
            style: themeManager.isDark
                ? const PlutoGridStyleConfig.dark()
                : const PlutoGridStyleConfig()),
      );
    });
  }
}

class AssetCreationDialog extends StatefulWidget {
  const AssetCreationDialog({Key? key}) : super(key: key);

  @override
  State<AssetCreationDialog> createState() => _AssetCreationDialogState();
}

class _AssetCreationDialogState extends State<AssetCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final descriptionTextController = TextEditingController();
  final assetNumTextController = TextEditingController();
  final _dropDownKey = GlobalKey<DropdownSearchState<String>>();
  final sjpTextController = TextEditingController();
  final installationDateTextController = TextEditingController();
  final vendorTextController = TextEditingController();
  final manufacturerTextController = TextEditingController();
  final modelNumTextController = TextEditingController();
  int? assetCriticalityValue;

  @override
  void dispose() {
    descriptionTextController.dispose();
    assetNumTextController.dispose();
    sjpTextController.dispose();
    vendorTextController.dispose();
    manufacturerTextController.dispose();
    installationDateTextController.dispose();
    modelNumTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          'Create Asset - Current Site: ${context.read<AssetCreationNotifier>().selectedSite}'),
      content: SizedBox(
        height: 400,
        width: 600,
        child: Form(
          key: _formKey,
          child: Column(children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 275,
                  child: DropdownSearch<String>(
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
                    items: context
                        .watch<AssetCreationNotifier>()
                        .siteAssets
                        .keys
                        .toList(),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Parent Asset",
                        hintText: "Select Parent Asset",
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 275,
                  child: TextFormField(
                    controller: assetNumTextController,
                    decoration: const InputDecoration(
                        labelText: 'New Asset Number', hintText: 'X####'),
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
                ),
              ],
            ),
            TextFormField(
              controller: descriptionTextController,
              decoration: const InputDecoration(
                labelText: 'Asset Description',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Description cannot be empty';
                }
                return null;
              },
              inputFormatters: [
                LengthLimitingTextInputFormatter(
                    55), // to limit total description to 55 characters
              ],
            ),
            TextFormField(
              controller: sjpTextController,
              decoration: const InputDecoration(
                  labelText: 'Standard Job Plan Description (Optional)',
                  hintText: 'Will use Asset Description if empty'),
              inputFormatters: [
                LengthLimitingTextInputFormatter(
                    55), // to limit total description to 55 characters
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 275,
                  child: DropdownButtonFormField(
                    items: assetCriticality.keys
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(assetCriticality[value] ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        assetCriticalityValue = value;
                      });
                    },
                    hint: const Text('Asset Criticality (Optional)'),
                  ),
                ),
                SizedBox(
                  width: 275,
                  child: TextFormField(
                    controller: vendorTextController,
                    decoration: const InputDecoration(
                      labelText: 'Vendor Number  (Optional)',
                      hintText: 'V######: Please refer to Company Master',
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(
                          7), // to limit total description to 55 characters
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 275,
                  child: TextFormField(
                    controller: manufacturerTextController,
                    decoration: const InputDecoration(
                        labelText: 'Manufacturer Code (Optional)',
                        hintText: 'Please refer to Company Master'),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(
                          15), // to limit total description to 55 characters
                    ],
                  ),
                ),
                SizedBox(
                  width: 275,
                  child: TextFormField(
                    controller: modelNumTextController,
                    decoration: const InputDecoration(
                      labelText: 'Model Number (Optional)',
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(
                          30), // to limit total description to 55 characters
                    ],
                  ),
                ),
              ],
            ),
            TextFormField(
                controller: installationDateTextController,
                decoration: const InputDecoration(
                  labelText: 'Installation Date (Optional)',
                ),
                onTap: () async {
                  DateTime? newDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime(DateTime.now().year + 5),
                  );
                  if (newDate != null) {
                    setState(() {
                      installationDateTextController.text =
                          DateFormat('yyyy-MM-dd').format(newDate);
                    });
                  }
                }),
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
              var id = await context.read<AssetCreationNotifier>().addAsset(
                    assetNum,
                    descriptionTextController.text,
                    _dropDownKey.currentState!.getSelectedItem!,
                    sjpDescription: sjpTextController.text,
                    installationDate: installationDateTextController.text,
                    vendor: vendorTextController.text,
                    manufacturer: manufacturerTextController.text,
                    modelNum: modelNumTextController.text,
                    assetCriticality: assetCriticalityValue,
                  );
              toast(context, 'Created Asset $assetNum, id: $id');
            } catch (err) {
              toast(context, '$err');
            }

            Navigator.pop(context, 'OK');
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class AssetUploadGrid extends StatefulWidget {
  const AssetUploadGrid({Key? key}) : super(key: key);

  @override
  State<AssetUploadGrid> createState() => _AssetUploadGridState();
}

class _AssetUploadGridState extends State<AssetUploadGrid> {
  late PlutoGridStateManager stateManager;

  List<PlutoColumn> columns = [];
  List<PlutoRow> rows = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    columns.addAll([
      PlutoColumn(
        width: 350,
        title: 'Hierarchy',
        readOnly: true,
        field: 'hierarchy',
        type: PlutoColumnType.text(),
        //sort: PlutoColumnSort.ascending,
      ),
      PlutoColumn(
          title: 'Actions',
          field: 'actions',
          type: PlutoColumnType.text(),
          readOnly: true,
          renderer: (rendererContext) {
            var assetStatus = context
                .read<AssetCreationNotifier>()
                .pendingAssets[rendererContext.row.cells['hierarchy']!.value];
            //if asset is new, display a delete button
            if (assetStatus == "new") {
              return IconButton(
                icon: const Icon(
                  Icons.delete,
                ),
                onPressed: () async {
                  var assetNum = rendererContext.row.cells['hierarchy']!.value;
                  try {
                    await context.read<AssetCreationNotifier>().deleteAsset(
                        assetNum,
                        context.read<AssetCreationNotifier>().selectedSite);
                    stateManager
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

            if (assetStatus == "pending") {
              return LoadingAnimationWidget.fourRotatingDots(
                size: 18,
                color: Colors.blue,
              );
            }

            if (assetStatus == "success") {
              return const Icon(
                Icons.done,
                color: Colors.green,
                size: 18,
              );
            }

            if (assetStatus == "fail") {
              return const Icon(
                Icons.close,
                color: Colors.red,
                size: 18,
              );
            }

            if (assetStatus == "duplicate") {
              return const Tooltip(
                  message: "Asset has already been uploaded.",
                  child: Icon(
                    Icons.error,
                    color: Colors.grey,
                    size: 18,
                  ));
            }

            if (assetStatus == "warning") {
              return IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AssetErrorMessageDialog(
                              assetNum: rendererContext
                                  .row.cells['hierarchy']!.value);
                        });
                  },
                  icon: const Icon(
                    Icons.warning,
                    color: Colors.yellow,
                    size: 18,
                  ));
            }

            //If not new asset, then just display a checkmark
            return const Icon(
              Icons.done,
              color: Colors.grey,
              size: 18,
            );
          }),
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
        title: 'Site',
        field: 'site',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        width: 100,
        readOnly: true,
        enableAutoEditing: false,
        title: 'Standard Description',
        field: 'sjpDescription',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        width: 100,
        readOnly: true,
        enableAutoEditing: false,
        title: 'Installation Date',
        field: 'installationDate',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        width: 100,
        readOnly: true,
        enableAutoEditing: false,
        title: 'Vendor Number',
        field: 'vendor',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        width: 100,
        readOnly: true,
        enableAutoEditing: false,
        title: 'Manufacturer',
        field: 'manufacturer',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        width: 100,
        readOnly: true,
        enableAutoEditing: false,
        title: 'Model Number',
        field: 'modelNum',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        width: 100,
        readOnly: true,
        enableAutoEditing: false,
        title: 'Asset Criticality',
        field: 'assetCriticality',
        type: PlutoColumnType.number(),
      ),
    ]);
  }

  Future<void> _loadGrid() async {
    final assetCreationNotifier =
        Provider.of<AssetCreationNotifier>(context, listen: false);

    var fetchedRows = getRows(assetCreationNotifier.siteAssets.values.toList());
    var value =
        await PlutoGridStateManager.initializeRowsAsync(columns, fetchedRows);
    stateManager.refRows.clear();
    stateManager.refRows.addAll(value);
    stateManager.setShowLoading(false);
    stateManager.notifyListeners();
    return;
  }

  List<PlutoRow> getRows(List<AssetWithUpload> siteAssets) {
    List<PlutoRow> rows = [];

    for (AssetWithUpload asset in siteAssets) {
      if (asset.asset.newAsset != 0) {
        rows.add(PlutoRow(
          cells: {
            'description': PlutoCell(value: asset.asset.description),
            'hierarchy': PlutoCell(value: asset.asset.assetnum),
            'site': PlutoCell(value: asset.asset.siteid),
            'actions': PlutoCell(value: ''),
          },
        ));
      }
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager themeManager =
        Provider.of<ThemeManager>(context, listen: true);

    return Consumer<AssetCreationNotifier>(
        builder: (context, assetCreationNotifier, child) {
      _loadGrid();
      return PlutoGrid(
        columns: columns,
        rows: rows,
        onLoaded: (event) {
          stateManager = event.stateManager;
          stateManager.setShowColumnFilter(true);
        },
        configuration: PlutoGridConfiguration(
            style: themeManager.isDark
                ? const PlutoGridStyleConfig.dark()
                : const PlutoGridStyleConfig()),
      );
    });
  }
}

class AssetUploadDialog extends StatefulWidget {
  const AssetUploadDialog({Key? key}) : super(key: key);

  @override
  State<AssetUploadDialog> createState() => _AssetUploadDialogState();
}

class _AssetUploadDialogState extends State<AssetUploadDialog> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Upload Assets'),
        content: const Text('Are you sure you want to upload these assets?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context, 'Cancel');
            },
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              context.read<AssetCreationNotifier>().uploadAssets(
                  context.read<MaximoServerNotifier>().maximoServerSelected);
              Navigator.pop(context, 'OK');
            },
          )
        ]);
  }
}

class AssetErrorMessageDialog extends StatefulWidget {
  const AssetErrorMessageDialog({Key? key, required this.assetNum})
      : super(key: key);

  final String assetNum;

  @override
  State<AssetErrorMessageDialog> createState() =>
      _AssetErrorMessageDialogState();
}

class _AssetErrorMessageDialogState extends State<AssetErrorMessageDialog> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssetCreationNotifier>(
        builder: (context, assetCreationNotifier, child) {
      return AlertDialog(
          insetPadding: const EdgeInsets.fromLTRB(400, 0, 400, 0),
          title: const Text('Asset Upload Failed!'),
          content: Text(
              '${assetCreationNotifier.failedAssets[widget.assetNum]!}\n\nPlease use maximo to fix this error, or try uploading again.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.pop(context, 'Ok');
              },
            ),
          ]);
    });
  }
}
