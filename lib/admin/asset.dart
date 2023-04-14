import 'dart:async';
import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:iko_reliability_flutter/admin/upload_maximo.dart';

// import '../main.dart';

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
  dynamic gridData;
  final TreeController _controller = TreeController(allNodesExpanded: true);

  Future<void> selectedSite(String? siteid) async {
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
      body: Column(
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
          ElevatedButton(
            child: const Text('Load GX Assets'),
            onPressed: () async {
              final result = await maximoRequest(
                  'mxasset?oslc.where=siteid=%22GX%22&oslc.select=assetnum,siteid,description,parent,status,changedate',
                  'get',
                  'TEST');
              Map<String, Map<String, String?>> thing = {};
              if (result['member'].length > 0) {
                for (var asset in result['member'].toList()) {
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
              debugPrint('adding assets to db');
              // await database!.addAssets(thing);
              debugPrint('finished adding assets to DB');
            },
          ),
          ElevatedButton(
              child: const Text('Display GX Assets'),
              onPressed: () async {
                final thing2 = await generateNodes('A0001', 'GX');
                debugPrint('generated nodes');
                setState(() {
                  _treenodes = thing2;
                });
              }),
          Expanded(
              child: ListView(
            children: [
              TreeView(treeController: _controller, nodes: _treenodes),
            ],
          )),
        ],
      ),
    );
  }
}

Future<List<TreeNode>> generateNodes(String assetnum, String siteid) async {
  // final children = await database!.getChildAssets(assetnum, siteid);
  List<TreeNode> nodes = [];
  // if (children.isEmpty) {
  //   return [];
  // }
  // for (final asset in children) {
  //   nodes.add(TreeNode(
  //     content: Text('${asset.assetnum} - ${asset.description}'),
  //     children: await generateNodes(asset.assetnum, siteid),
  //   ));
  // }
  return nodes;
}
