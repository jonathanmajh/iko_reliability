//for widgets in the right-side drawer
import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/bin/common.dart';
import 'package:iko_reliability_flutter/criticality/file_export.dart';
import 'package:iko_reliability_flutter/bin/process_state_notifier.dart';
import 'package:iko_reliability_flutter/admin/settings.dart';
import 'package:iko_reliability_flutter/criticality/asset_criticality.dart';
import 'package:iko_reliability_flutter/criticality/asset_criticality_notifier.dart';
import 'package:iko_reliability_flutter/settings/settings_notifier.dart';
import 'package:iko_reliability_flutter/settings/theme_manager.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import '../criticality/criticality_db_export_import.dart';
import '../criticality/spare_criticality.dart';
import '../criticality/spare_criticality_notifier.dart';
import '../main.dart';
import 'consts.dart';
import 'db_drift.dart';

///Widget for the right-side drawer of the app
class EndDrawer extends StatefulWidget {
  const EndDrawer({super.key});

  @override
  State<EndDrawer> createState() => _EndDrawerState();
}

class _EndDrawerState extends State<EndDrawer> {
  String siteid = '';
  TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var themeManager = Provider.of<ThemeManager>(context);
    if (ModalRoute.of(context)!.settings.name == 'AssetCriticalityRoute') {
      return assetCriticalityEndDrawer(context, themeManager);
    } else if (ModalRoute.of(context)!.settings.name == 'HomeRoute') {
      return homeRouteEndDrawer(context, themeManager);
    } else if (ModalRoute.of(context)!.settings.name == 'PmCheckRoute') {
      return pmCheckRouteEndDrawer(context, themeManager);
    } else if (ModalRoute.of(context)!.settings.name ==
        'SpareCriticalityRoute') {
      return spareCriticalityEndDrawer(context, themeManager);
    } else {
      return defaultEndDrawer(context, themeManager);
    }
  }
  // Add HomeRoute

  Widget pmCheckRouteEndDrawer(
      BuildContext context, ThemeManager themeManager) {
    return Drawer(
        child: ListView(
      children: <Widget>[
        const ThemeToggle(),
        ListTile(
          //load observation from spreadsheet/excel
          title: const Text('Load Observation'),
          subtitle:
              const Text('Clear and Load Observation list from spreadsheet'),
          trailing: IconButton(
            //load button
            onPressed: () {
              database!.clearMeters();
              database!.addMeters();
            },
            icon: const Icon(Icons.input),
          ),
        ),
      ],
    ));
  }

  ///Widget for default end drawer. Could not extract widget due to _passVisibility error
  Widget homeRouteEndDrawer(BuildContext context, ThemeManager themeManager) {
    return Drawer(
      width: 300,
      child: ListView(
        children: <Widget>[
          const ThemeToggle(),
          ListTile(
              //environment selection
              title: const Text('Select Maximo Environment'),
              subtitle: Consumer<MaximoServerNotifier>(
                  builder: (context, value, child) {
                return DropdownButton(
                  isExpanded: true,
                  hint: const Text('Select an environment to work with'),
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
                    passwordController.text = snapshot.data?.password ?? '';
                  }
                  return ListTile(
                    title: const Text('Maximo API Key'),
                    subtitle: TextField(
                      obscureText: !_passwordVisible,
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'API Key',
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            // color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
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
                }));
          }),
          ListTile(
              //asset/site loading
              title: const Text('Load Assets From Maximo'),
              subtitle: DropdownButton(
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    siteid = newValue ?? '';
                  });
                },
                value: siteid,
                items: [
                  '',
                  ...siteIDAndDescription.keys,
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                        siteIDAndDescription[value] ?? 'Please Select a Site'),
                  );
                }).toList(),
              ),
              trailing: Consumer<MaximoServerNotifier>(
                builder: (context, maximo, child) {
                  //asset load button
                  return IconButton(
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
                          processNotifier.popProcessingDialog(
                              navigatorKey.currentContext!);
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
                    icon: const Icon(Icons.download),
                  );
                },
              )),
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

  Widget spareCriticalityEndDrawer(
      BuildContext context, ThemeManager themeManager) {
    return Drawer(
      child: Column(children: <Widget>[
        // force everything outside of this Expanded to bottom
        Expanded(
            child: Column(
          children: <Widget>[
            const ThemeToggle(),
            const SiteToggle(),
            ListTile(
              title: const Text('Configure ABC Percentages'),
              trailing: ElevatedButton(
                child: const Icon(Icons.settings),
                onPressed: () {
                  showDataAlert(
                    [],
                    'Enter Desired Precentages',
                    [const SpareCriticalityConfig()],
                  );
                },
              ),
            ),
            ListTile(
              title: const Text('Configure Purchases Filter Settings'),
              trailing: ElevatedButton(
                child: const Icon(Icons.settings),
                onPressed: () {
                  showDataAlert(
                    [
                      'Please use the "Refresh Data from Maximo" button in the side bar after changing settings',
                    ],
                    'Purchase History Calculation Settings',
                    [const PurchaseHistorySettingDialog()],
                  );
                },
              ),
            ),
            ListTile(
              title: const Text('Refresh Data from Maximo'),
              trailing: ElevatedButton(
                child: const Icon(Icons.refresh),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          title: Text('Loading...'),
                          content:
                              SparePartsLoadingIndicator(forceUpdate: true),
                        );
                      });
                },
              ),
            ),
            ListTile(
              title: const Text('Calculate ABC from RPN'),
              trailing: ElevatedButton(
                child: const Icon(Icons.calculate),
                onPressed: () => calculateRPNDistributionSpares(context),
              ),
            ),
            ListTile(
              title: const Text('Export to CSV'),
              trailing: ElevatedButton(
                child: const Text('Export'),
                onPressed: () async {
                  PlutoGridStateManager? stateManager =
                      context.read<SpareCriticalityNotifier>().stateManager;
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
              title: const Text('Export Settings'),
              trailing: ElevatedButton(
                  child: const Text('Export'),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(await exportCriticalityDB(
                        database!,
                        context.read<SelectedSiteNotifier>().selectedSite,
                      )),
                    ));
                    Navigator.of(navigatorKey.currentContext!).pop();
                  }),
            ),
            ListTile(
              title: const Text('Import Settings'),
              trailing: ElevatedButton(
                  child: const Text('Import'),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(await importCriticalityDB(
                        database!,
                      )),
                    ));
                    Navigator.of(navigatorKey.currentContext!).pop();
                  }),
            ),
          ],
        )),
        Consumer<SelectedSiteNotifier>(builder: (context, selectedSite, child) {
          return FutureBuilder<CriticalityCompletion>(
              future: database!
                  .getSpareCompletion(siteid: selectedSite.selectedSite),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  return ListTile(
                      title: const Text('Completion Percentage'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Items: ${snapshot.data!.total}'),
                          Text('Completed Items: ${snapshot.data!.complete}'),
                          Text(
                              'Completed: ${(snapshot.data!.complete * 100 / (snapshot.data!.total)).toStringAsPrecision(3)}%')
                        ],
                      ));
                }
                return const ListTile(
                  title: Text('Completion Percentage'),
                  subtitle: Text('Calculating...'),
                );
              }));
        }),
      ]),
    );
  }

  ///Widget for asset criticality end drawer
  Widget assetCriticalityEndDrawer(
      BuildContext context, ThemeManager themeManager) {
    return Consumer<AssetCriticalityNotifier>(
        builder: (context, assetCriticalityNotifier, child) {
      return Drawer(
        child: Column(children: <Widget>[
          Expanded(
              child: Column(
            children: <Widget>[
              const ThemeToggle(),
              const SiteToggle(),
              ListTile(
                title: const Text('Configure Priority Percentages'),
                trailing: ElevatedButton(
                  child: const Icon(Icons.settings),
                  onPressed: () => showRpnDistDialog(context),
                ),
              ),
              ListTile(
                title: const Text('Work Order Filter Settings'),
                trailing: ElevatedButton(
                  child: const Icon(Icons.settings),
                  onPressed: () => showWOSettingsDialog(context),
                ),
              ),
              ListTile(
                title: const Text('Export to CSV'),
                trailing: ElevatedButton(
                  child: const Text('Export'),
                  onPressed: () async {
                    PlutoGridStateManager? stateManager =
                        context.read<AssetCriticalityNotifier>().stateManager;
                    if (!context
                        .read<AssetCriticalityNotifier>()
                        .priorityRangesUpToDate) {
                      bool value =
                          await assetCriticalityCSVExportWarning(context);
                      if (value != true) {
                        return;
                      }
                    }
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
                title: const Text('Export Settings'),
                trailing: ElevatedButton(
                    child: const Text('Export'),
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(await exportCriticalityDB(
                          database!,
                          context.read<SelectedSiteNotifier>().selectedSite,
                        )),
                      ));
                      Navigator.of(navigatorKey.currentContext!).pop();
                    }),
              ),
              ListTile(
                title: const Text('Import Settings'),
                trailing: ElevatedButton(
                    child: const Text('Import'),
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(await importCriticalityDB(
                          database!,
                        )),
                      ));
                      Navigator.of(navigatorKey.currentContext!).pop();
                    }),
              ),
            ],
          )),
          Consumer<SelectedSiteNotifier>(
              builder: (context, selectedSite, child) {
            return FutureBuilder<CriticalityCompletion>(
                future: database!
                    .getAssetCompletion(siteid: selectedSite.selectedSite),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    return ListTile(
                        title: const Text('Completion Percentage'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Assets: ${snapshot.data!.total}'),
                            Text('Parent Assets: ${snapshot.data!.ignore}'),
                            Text(
                                'Completed Assets: ${snapshot.data!.complete}'),
                            Text(
                                'Completed: ${(snapshot.data!.complete * 100 / (snapshot.data!.total - snapshot.data!.ignore)).toStringAsPrecision(3)}%')
                          ],
                        ));
                  }
                  return const ListTile(
                    title: Text('Completion Percentage'),
                    subtitle: Text('Calculating...'),
                  );
                }));
          }),
        ]),
      );
    });
  }

  Widget defaultEndDrawer(BuildContext context, ThemeManager themeManager) {
    return Drawer(
      child: ListView(
        children: const <Widget>[
          ThemeToggle(),
          SiteToggle(),
        ],
      ),
    );
  }
}

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    var themeManager = Provider.of<ThemeManager>(context);
    return DrawerHeader(
        child: ListTile(
      title: const Text(
        'Settings',
        style: TextStyle(fontSize: 24),
      ),
      trailing: Switch(
          //true => darkmode on
          value: (themeManager.theme == ThemeMode.dark),
          onChanged: (value) {
            themeManager.setDarkTheme(value);
          },
          thumbIcon:
              WidgetStateProperty.resolveWith<Icon?>((Set<WidgetState> states) {
            return (themeManager.theme == ThemeMode.dark)
                ? const Icon(Icons.dark_mode_rounded)
                : const Icon(Icons.light_mode_rounded);
          })),
    ));
  }
}

class SiteToggle extends StatelessWidget {
  const SiteToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Plant Site'),
      trailing: DropdownButton(
        value: context.watch<SelectedSiteNotifier>().selectedSite,
        items: () {
          List<DropdownMenuItem<String>> list = [
            const DropdownMenuItem(value: '', child: Text('Select a site'))
          ];
          List<String> loadedSettings = (context
                  .read<SettingsNotifier>()
                  .getSetting(ApplicationSetting.loadedSites) as Set<String>)
              .toList();
          loadedSettings
              .sort((a, b) => a.compareTo(b)); //put them in alphabetical order
          list.addAll(loadedSettings.map((e) => DropdownMenuItem(
              value: e, child: Text(siteIDAndDescription[e] ?? ''))));
          return list;
        }(),
        onChanged: (newValue) {
          context.read<SelectedSiteNotifier>().setSite(newValue!);
        },
      ),
    );
  }
}
