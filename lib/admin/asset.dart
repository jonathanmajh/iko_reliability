import 'dart:async';
import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';

class AssetPage extends StatefulWidget {
  const AssetPage({Key? key}) : super(key: key);
  @override
  State<AssetPage> createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  List<String> _sites = [];
  bool showHierarchy = false;
  dynamic _assets;
  String _stateMessage = 'There is nothing here';
  dynamic gridData;

  Future<void> selectedSite(String? siteid) async {
    if (showHierarchy == false) {
      setState(() {
        _stateMessage = 'showHierarchy not selected';
      });
      return;
    }
    if (siteid == null) {
      setState(() {
        _stateMessage = 'Site Selected was not hillsboro';
      });
      return;
    }
    if (siteid == 'GV: Hillsboro') {
      final String data =
          await rootBundle.loadString('lib\\admin\\GVAssets.json');
      _assets = await compute(jsonDecode, data);
      setState(() {
        _assets = _assets;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _sites = ['GH: Hawkesbury', 'CA: Kankakee', 'GV: Hillsboro'];
  }

  void toggleHierarchy(bool value) {
    if (showHierarchy) {
      setState(() {
        showHierarchy = false;
        // reset table
      });
    } else {
      setState(() {
        showHierarchy = true;
        gridData = Griddata();
        // get table data
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maximo Asset Creator"),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: DropdownSearch<String>(
                  popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      showSelectedItems: true,
                      searchFieldProps: TextFieldProps(
                        autofocus: true,
                        autocorrect: true,
                      )),
                  items: _sites,
                  onChanged: selectedSite,
                )),
            Switch(value: showHierarchy, onChanged: toggleHierarchy)
          ]),
          const Text('_stateMessage'),
          Container(
              child: _assets != null
                  ? ListView.builder(
                      itemCount: _assets.length,
                      itemBuilder: ((context, index) {
                        return ListTile(
                          leading: Text(_assets[index]['assetnum']),
                          title: Text(_assets[index]['description']),
                          subtitle: Text(_assets[index]['parent'] ?? ""),
                        );
                      }),
                    )
                  : Text(_stateMessage) // this is the else statement
              ),
          gridData != null
              ? PlutoGrid(
                  columns: gridData.columns,
                  rows: gridData.rows,
                )
              : Text('no table'),
        ],
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
        title: 'Parent Asset',
        field: 'parent_number',
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
