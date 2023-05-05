import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/admin/settings.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'consts.dart';
import 'db_drift.dart';

class EndDrawer extends StatefulWidget {
  const EndDrawer({Key? key}) : super(key: key);

  @override
  State<EndDrawer> createState() => _EndDrawerState();
}

class _EndDrawerState extends State<EndDrawer> {
  String siteid = '';
  bool _passVisibility = true;
  TextEditingController useridController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    useridController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

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
          Consumer<MaximoServerNotifier>(builder: (context, maximo, child) {
            return FutureBuilder<Credentials>(
                future: getLoginMaximo(maximo.maximoServerSelected),
                builder: ((context, snapshot) {
                  if(snapshot.data?.login != null && snapshot.data?.login != '') {
                    useridController.text = snapshot.data?.login ?? '';
                  }
                  if(snapshot.data?.login != null && snapshot.data?.login != '') {
                    passwordController.text = snapshot.data?.password ?? '';
                  }
                  if (apiKeys.containsKey(maximo.maximoServerSelected)) {
                    return ListTile(
                      title: const Text('Maximo API Key'),
                      subtitle: TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(labelText: 'API Key'),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.login),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Attempting to Login to: ${maximo.maximoServerSelected}'),
                          ));
                          getUserMaximo(
                              useridController.text,
                              passwordController.text,
                              maximo.maximoServerSelected);
                        },
                      ),
                    );
                  } else {
                    
                    return ListTile(
                      title: const Text('Maximo Login'),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextField(
                            controller: useridController,
                            decoration:
                                const InputDecoration(labelText: 'Login'),
                          ),
                          TextField(
                            controller: passwordController,
                            obscureText: _passVisibility,
                            decoration: InputDecoration(
                                labelText: 'Password',
                                suffixIcon: IconButton(
                                  icon: _passVisibility
                                      ? const Icon(Icons.visibility_off)
                                      : const Icon(Icons.visibility),
                                  onPressed: () {
                                    _passVisibility = !_passVisibility;

                                    setState(() {});
                                  },
                                )),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.login),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Attempting to Login to: ${maximo.maximoServerSelected}'),
                          ));
                          getUserMaximo(
                              useridController.text,
                              passwordController.text,
                              maximo.maximoServerSelected);
                        },
                      ),
                    );
                  }
                }));
          }),
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
                  );
                }).toList(),
              ),
              trailing: Consumer<MaximoServerNotifier>(
                builder: (context, maximo, child) {
                  return ElevatedButton(
                    onPressed: () =>
                        maximoAssetCaller(siteid, maximo.maximoServerSelected),
                    child: const Text('Load'),
                  );
                },
              )),
          ListTile(
            title: const Text('Load Observation'),
            subtitle:
                const Text('Clear and Load Observation list from spreadsheet'),
            trailing: ElevatedButton(
              onPressed: () {
                database!.clearMeters();
                database!.addMeters();
              },
              child: const Text('Load'),
            ),
          ),
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
