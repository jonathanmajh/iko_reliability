import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'asset_storage.dart';
import 'consts.dart';
import 'maximo_jp_pm.dart';
import 'observation_list_storage.dart';

class EndDrawer extends StatefulWidget {
  const EndDrawer({Key? key}) : super(key: key);

  @override
  State<EndDrawer> createState() => _EndDrawerState();
}

class _EndDrawerState extends State<EndDrawer> {
  String siteid = '';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
              child: Text(
            'Settings',
            style: TextStyle(fontSize: 24),
          )),
          ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Maximo Environment'),
              subtitle: const Text('Select which environment to work with'),
              trailing: Consumer<MaximoServerNotifier>(
                  builder: (context, value, child) {
                return DropdownButton(
                  value: value.maximoServerSelected,
                  onChanged: (String? newValue) {
                    value.setServer(newValue!);
                  },
                  items: maximoServerDomains.keys
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                );
              })),
          ListTile(
              title: const Text('Load Assets From Maximo'),
              subtitle: DropdownButton(
                onChanged: (String? newValue) {
                  setState(() {
                    siteid = newValue ?? '';
                  });
                },
                value: siteid,
                items: [
                  '',
                  'All',
                  ...siteIDAndDescription.keys,
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(siteIDAndDescription[value] ??
                        (value == '' ? 'Please Select a Site' : 'All Sites')),
                    // ?? value = '' ? 'Please Select a Site' : 'All Sites'
                  );
                }).toList(),
              ),
              trailing: ElevatedButton(
                onPressed: () => maximoAssetCaller(siteid, context),
                child: const Text('Load'),
              )),
          const ListTile(
              leading: Icon(Icons.message),
              title: Text('Load Observation'),
              subtitle:
                  Text('Clear and Load Observation list from spreadsheet'),
              trailing: ElevatedButton(
                onPressed: loadObservationList,
                child: Text('Load Asset'),
              )),
          const ListTile(
            // a spacer
            title: Text(''),
          ),
          Center(
              child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close Drawer'),
          )),
        ],
      ),
    );
  }
}
