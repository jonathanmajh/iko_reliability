import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:iko_reliability/admin/upload_maximo.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../main.dart';

class AssetPage extends StatefulWidget {
  const AssetPage({Key? key}) : super(key: key);
  @override
  State<AssetPage> createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  List<String> _sites = [];
  bool showHierarchy = false;
  dynamic _assets;
  List<TreeNode> _treenodes = [];
  String _stateMessage = 'There is nothing here';
  dynamic gridData;
  final TreeController _controller = TreeController(allNodesExpanded: true);

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
    if (siteid == 'GX: MaxiMix') {
      final thing = await generateNodes('A0001', 'GX');
      setState(() {
        _treenodes = thing;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _sites = ['GH: Hawkesbury', 'CA: Kankakee', 'GV: Hillsboro', 'GX: MaxiMix'];
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
          DropdownSearch<String>(
            popupProps: const PopupProps.menu(
                showSearchBox: true,
                showSelectedItems: true,
                searchFieldProps: TextFieldProps(
                  autofocus: true,
                  autocorrect: true,
                )),
            items: _sites,
            onChanged: selectedSite,
          ),
          Switch(value: showHierarchy, onChanged: toggleHierarchy),
          ElevatedButton(
            child: const Text('Load GX Assets'),
            onPressed: () async {
              final result = await maximoRequest(
                  '/maxrest/oslc/os/mxasset?oslc.where=siteid=%22GX%22&oslc.select=assetnum,siteid,description,parent,status,changedate',
                  'get',
                  'TEST');
              Map<String, Map<String, String?>> thing = {};
              if (result['rdfs:member'].length > 0) {
                for (var asset in result['rdfs:member'].toList()) {
                  thing[asset['spi:assetnum']] = {
                    'assetnum': asset['spi:assetnum'],
                    'description': asset['spi:description'],
                    'status': asset['spi:status'],
                    'siteid': asset['spi:siteid'],
                    'changedate': asset['spi:changedate'],
                    'parent': asset['spi:parent'],
                  };
                }
              }
              print('adding assets to db');
              await database!.addAssets(thing);
              print('finished adding assets to DB');
            },
          ),
          ElevatedButton(
              child: const Text('Display GX Assets'),
              onPressed: () async {
                final thing2 = await generateNodes('A0001', 'GX');
                print('generated nodes');
                setState(() {
                  _treenodes = thing2;
                });
              }),
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
              : const Text('no table'),
          TreeView(treeController: _controller, nodes: _treenodes),
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

Future<List<TreeNode>> generateNodes(String assetnum, String siteid) async {
  final children = await database!.getChildAssets(assetnum, siteid);
  List<TreeNode> nodes = [];
  if (children.isEmpty) {
    return [];
  }
  for (final asset in children) {
    nodes.add(TreeNode(
      content: Text(asset.assetnum),
      children: await generateNodes(asset.assetnum, siteid),
    ));
  }
  return nodes;
}
