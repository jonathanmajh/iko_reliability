//for widgets in the right-side drawer
import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/admin/cache_notifier.dart';
import 'package:iko_reliability_flutter/admin/file_export.dart';
import 'package:iko_reliability_flutter/admin/process_state_notifier.dart';
import 'package:iko_reliability_flutter/admin/settings.dart';
import 'package:iko_reliability_flutter/creation/site_change_notifier.dart';
import 'package:iko_reliability_flutter/criticality/asset_criticality.dart';
import 'package:iko_reliability_flutter/criticality/asset_criticality_notifier.dart';
import 'package:iko_reliability_flutter/settings/settings_notifier.dart';
import 'package:iko_reliability_flutter/settings/theme_manager.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:iko_reliability_flutter/creation/asset_creation_notifier.dart';
import '../criticality/criticality_db_export_import.dart';
import '../criticality/criticality_settings_notifier.dart';
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
    if (ModalRoute.of(context)!.settings.name == 'AssetCriticalityRoute') {
      return assetCriticalityEndDrawer(context, themeManager);
    } else if (ModalRoute.of(context)!.settings.name == 'AssetRoute') {
      return assetCreationEndDrawer(context, themeManager);
    } else {
      return defaultEndDrawer(context, themeManager);
    }
  }

  ///Widget for default end drawer. Could not extract widget due to _passVisibility error
  Widget defaultEndDrawer(BuildContext context, ThemeManager themeManager) {
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
                  themeManager.toggleTheme(value, context);
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
                          getUserMaximo('[APIKEY]', passwordController.text,
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
                                ProcessStates.loginState, true);
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
                                ProcessStates.loginState, false);
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
                              ProcessStates.loadAssetState, true,
                              notifyListeners: false);
                          processNotifier.processingDialog(context);
                          scaffoldMes.showSnackBar(SnackBar(
                            duration:
                                const Duration(days: 1), //some long duration
                            content: Text(
                                'Attempting to Load Assets from : $siteid'),
                          ));
                          List<String> messages = await maximoAssetCaller(
                              siteid, maximo.maximoServerSelected, context);
                          context
                              .read<Cache>()
                              .calculateSystemScores(); //reload system scores
                          processNotifier.popProcessingDialog(context);
                          if (messages.isNotEmpty) {
                            showDataAlert(messages, 'Site Assets Loaded');
                          }
                        } finally {
                          scaffoldMes
                              .hideCurrentSnackBar(); //hide snackbar once asset load is completed
                          processNotifier.setProcessState(
                              ProcessStates.loadAssetState, false,
                              notifyListeners: false);
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

  ///Widget for asset criticality end drawer
  Widget assetCriticalityEndDrawer(
      BuildContext context, ThemeManager themeManager) {
    return Consumer<AssetCriticalityNotifier>(
        builder: (context, assetCriticalityNotifier, child) {
      return Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
                child: ListTile(
              title: const Text(
                'Asset Criticality Settings',
                style: TextStyle(fontSize: 24),
              ),
              trailing: Switch(
                  //true => darkmode on
                  value: (themeManager.themeMode == ThemeMode.dark),
                  onChanged: (value) {
                    themeManager.toggleTheme(value, context);
                  },
                  thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                      (Set<MaterialState> states) {
                    return (themeManager.themeMode == ThemeMode.dark)
                        ? const Icon(Icons.dark_mode_rounded)
                        : const Icon(Icons.light_mode_rounded);
                  })),
            )),
            ListTile(
              title: const Text('Plant Site'),
              trailing: DropdownButton(
                value: context
                    .watch<AssetCriticalitySettingsNotifier>()
                    .selectedSite,
                items: () {
                  List<DropdownMenuItem<String>> list = [
                    const DropdownMenuItem(
                        value: '', child: Text('Select a site'))
                  ];
                  List<String> loadedSettings = (context
                              .read<SettingsNotifier>()
                              .getSetting(ApplicationSetting.loadedSites)
                          as Set<String>)
                      .toList();
                  loadedSettings.sort((a, b) =>
                      a.compareTo(b)); //put them in alphabetical order
                  list.addAll(loadedSettings.map((e) => DropdownMenuItem(
                      value: e, child: Text(siteIDAndDescription[e] ?? ''))));
                  return list;
                }(),
                onChanged: (newValue) {
                  context
                      .read<AssetCriticalitySettingsNotifier>()
                      .setSite(newValue.toString());
                },
              ),
            ),
            ListTile(
              title: const Text('Risk Priority Distributions'),
              trailing: ElevatedButton(
                child: const Text('Configure'),
                onPressed: () => showRpnDistDialog(context),
              ),
            ),
            ListTile(
              title: const Text('Calculate Priority Ranges'),
              trailing: ElevatedButton(
                child: const Text('Calculate'),
                onPressed: () {
                  calculateRPNDistribution(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Export to CSV'),
              trailing: ElevatedButton(
                child: const Text('Export'),
                onPressed: () async {
                  if (!context
                      .read<AssetCriticalityNotifier>()
                      .priorityRangesUpToDate) {
                    bool value =
                        await assetCriticalityCSVExportWarning(context);
                    if (value != true) {
                      return;
                    }
                  }
                  PlutoGridStateManager? stateManager =
                      context.read<AssetCriticalityNotifier>().stateManager;

                  //export as csv
                  if (stateManager != null) {
                    exportAssetCriticalityAsCSV(
                        stateManager: stateManager,
                        context: navigatorKey.currentContext!);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Work Order View Settings'),
              trailing: ElevatedButton(
                child: const Text('Configure'),
                onPressed: () => showWOSettingsDialog(context),
              ),
            ),
            ListTile(
              title: const Text('Export Settings'),
              trailing: ElevatedButton(
                child: const Text('Export'),
                onPressed: () => exportCriticalityDB(database!),
              ),
            ),
            ListTile(
              title: const Text('Import Settings'),
              trailing: ElevatedButton(
                child: const Text('Import'),
                onPressed: () => importCriticalityDB(database!),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget assetCreationEndDrawer(
      BuildContext context, ThemeManager themeManager) {
    return Consumer<AssetCreationNotifier>(
      builder: (context, assetCreationNotifier, child) {
        return Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                  child: ListTile(
                title: const Text(
                  'Asset Creation Settings',
                  style: TextStyle(fontSize: 24),
                ),
                trailing: Switch(
                    //true => darkmode on
                    value: (themeManager.themeMode == ThemeMode.dark),
                    onChanged: (value) {
                      themeManager.toggleTheme(value, context);
                    },
                    thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                        (Set<MaterialState> states) {
                      return (themeManager.themeMode == ThemeMode.dark)
                          ? const Icon(Icons.dark_mode_rounded)
                          : const Icon(Icons.light_mode_rounded);
                    })),
              )),
              ListTile(
                title: const Text('Plant Site'),
                trailing: DropdownButton(
                  value: assetCreationNotifier.selectedSite,
                  items: () {
                    List<DropdownMenuItem<String>> list = [
                      const DropdownMenuItem(
                          value: 'NONE', child: Text('Select a site'))
                    ];
                    List<String> loadedSettings = (context
                                .read<SettingsNotifier>()
                                .getSetting(ApplicationSetting.loadedSites)
                            as Set<String>)
                        .toList();
                    loadedSettings.sort((a, b) =>
                        a.compareTo(b)); //put them in alphabetical order
                    list.addAll(loadedSettings.map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(siteIDAndDescription[e] ?? 'NONE'))));
                    return list;
                  }(),
                  onChanged: (newValue) {
                    assetCreationNotifier.setSite(newValue.toString());
                    context
                        .read<SiteChangeNotifier>()
                        .setSite(newValue.toString());
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
