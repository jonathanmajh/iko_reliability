import 'dart:async';
import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      final String data = await rootBundle.loadString(
          '/home/jonathan/Documents/flutter_application_1/lib/admin/123.txt');
      _assets = await compute(jsonDecode, data);
      setState(() {
        _assets = _assets['assets'];
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
        children: [
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
                  dropdownSearchDecoration: const InputDecoration(
                    labelText: "Site",
                    hintText: "Select Site for Adding Asset",
                  ),
                  onChanged: selectedSite,
                )),
            Switch(value: showHierarchy, onChanged: toggleHierarchy)
          ]),
          Container(
              child: _assets != null
                  ? ListView.builder(
                      itemCount: _assets.length,
                      itemBuilder: ((context, index) {
                        return ListTile(
                          leading: Text(_assets[index]['assetnum']),
                          title: Text(_assets[index]['description']),
                          subtitle: Text(_assets[index]['parent']),
                        );
                      }),
                    )
                  : Text(_stateMessage) // this is the else statement
              )
        ],
      ),
    );
  }
}
