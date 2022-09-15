import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'asset_storage.dart';
import 'maximo_jp_pm.dart';
import 'observation_list_storage.dart';

class EndDrawer extends StatelessWidget {
  const EndDrawer({Key? key}) : super(key: key);

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
              subtitle:
                  const Text('Toggle which environment to apply changes to'),
              trailing: Consumer<MaximoServerNotifier>(
                  builder: (context, value, child) {
                return DropdownButton(
                  value: value.maximoServerSelected,
                  onChanged: (String? newValue) {
                    context.read<MaximoServerNotifier>().setServer(newValue!);
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
          const ListTile(
              leading: Icon(Icons.message),
              title: Text('Load Asset'),
              subtitle: Text('Clear and Load Assets from Spreadsheet'),
              trailing: ElevatedButton(
                onPressed: loadHierarchy,
                child: Text('Load Asset'),
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
