//for widgets in the right-side drawer
import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/admin/process_state_notifier.dart';
import 'package:iko_reliability_flutter/admin/settings.dart';
import 'package:iko_reliability_flutter/settings/theme_manager.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'consts.dart';
import 'db_drift.dart';

///Widget for the right-side drawer of the app
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
  Widget build(BuildContext context) {
    var themeManager = Provider.of<ThemeManager>(context);

    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
              child: ListTile(
            title: const Text(
              'Settings',
              style: TextStyle(fontSize: 24),
            ),
            trailing: Switch(
                //true => darkmode on
                value: (themeManager.themeMode == ThemeMode.dark),
                onChanged: (value) {
                  themeManager.toggleTheme(value);
                },
                thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                    (Set<MaterialState> states) {
                  return (themeManager.themeMode == ThemeMode.dark)
                      ? const Icon(Icons.dark_mode_rounded)
                      : const Icon(Icons.light_mode_rounded);
                })),
          )),
          ListTile(
              //environment selection
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
          Consumer<MaximoServerNotifier>(
              //login
              builder: (context, maximo, child) {
            return FutureBuilder<Credentials>(
                future: getLoginMaximo(maximo.maximoServerSelected),
                builder: ((context, snapshot) {
                  if (snapshot.data?.login != null &&
                      snapshot.data?.login != '') {
                    useridController.text = snapshot.data?.login ?? '';
                  }
                  if (snapshot.data?.login != null &&
                      snapshot.data?.login != '') {
                    passwordController.text = snapshot.data?.password ?? '';
                  }
                  if (apiKeys.containsKey(maximo.maximoServerSelected)) {
                    //for username/APIKEY: if APIKEY is used
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
                    //for username/APIKEY: if username is used
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
                            //password field
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
                        //login button
                        icon: const Icon(Icons.login),
                        onPressed: () async {
                          var processNotifier =
                              Provider.of<ProcessStateNotifier>(context,
                                  listen: false);
                          try {
                            processNotifier.setProcessState(
                                ProcessStateNotifier.loginState, true);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              //show login snackbar
                              duration:
                                  const Duration(days: 1), //some long duration
                              content: Text(
                                  'Attempting to Login to: ${maximo.maximoServerSelected}'),
                            ));
                            await getUserMaximo(
                                useridController.text,
                                passwordController.text,
                                maximo.maximoServerSelected);
                          } finally {
                            ScaffoldMessenger.of(context)
                                .hideCurrentSnackBar(); //hide snackbar once process is complete
                            processNotifier.setProcessState(
                                ProcessStateNotifier.loginState, false);
                          }
                        },
                      ),
                    );
                  }
                }));
          }),
          ListTile(
              //asset/site loading
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
                  //asset load button
                  return ElevatedButton(
                    onPressed: () async {
                      if (siteid != '') {
                        var processNotifier = Provider.of<ProcessStateNotifier>(
                            context,
                            listen: false);
                        ScaffoldMessengerState scaffoldMes =
                            ScaffoldMessenger.of(context);
                        try {
                          processNotifier.setProcessState(
                              ProcessStateNotifier.loadAssetState, true,
                              notifyListeners: false,
                              createDialog: true,
                              context: context);
                          scaffoldMes.showSnackBar(SnackBar(
                            duration:
                                const Duration(days: 1), //some long duration
                            content: Text(
                                'Attempting to Load Assets from : $siteid'),
                          ));
                          List<String> messages = await maximoAssetCaller(
                              siteid, maximo.maximoServerSelected);
                          processNotifier.popProcessingDialog(context);
                          if (messages.isNotEmpty) {
                            showDataAlert(messages, 'Site Assets Loaded');
                          }
                        } finally {
                          scaffoldMes
                              .hideCurrentSnackBar(); //hide snackbar once asset load is completed
                          processNotifier.setProcessState(
                              ProcessStateNotifier.loadAssetState, false,
                              notifyListeners: false,
                              closeDialog: true,
                              context: context);
                        }
                      }
                    },
                    child: const Text('Load'),
                  );
                },
              )),
          ListTile(
            //load observation from spreadsheet/excel
            title: const Text('Load Observation'),
            subtitle:
                const Text('Clear and Load Observation list from spreadsheet'),
            trailing: ElevatedButton(
              //load button
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
              //close drawer button
              child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close Drawer'),
          )),
        ],
      ),
    );
  }
}
