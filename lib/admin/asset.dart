import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class AssetPage extends StatefulWidget {
  const AssetPage({Key? key}) : super(key: key);
  @override
  State<AssetPage> createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  List<String> _sites = [];
  bool showHierarchy = false;

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
        body: Center(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              SizedBox(
                  width: 440,
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
                    onChanged: print,
                  )),
              Switch(value: showHierarchy, onChanged: toggleHierarchy)
            ])));
  }
}
