import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/admin/settings.dart'
    show Credentials, getLoginMaximo, getUserMaximo;
import 'package:iko_reliability_flutter/main.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bin/drawer.dart';
import 'bin/end_drawer.dart';
import 'bin/process_state_notifier.dart';
import 'notifiers/maximo_server_notifier.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  /// Constructs the home page.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// If update window should be hidden.
  bool hideUpdateWindow = false;

  /// If an alert dialog is showing.
  bool _alertShowing = false;

  @override
  void initState() {
    super.initState();
    //closing confirmation prompt
    if (!kIsWeb) {
      FlutterWindowClose.setWindowShouldCloseHandler(() async {
        if (_alertShowing) {
          //don't create another prompt if one already exists
          return false;
        }
        //check if there are any processes running
        var processNotifier = Provider.of<ProcessStateNotifier>(
            navigatorKey.currentContext!,
            listen: false);

        if (!processNotifier.processRunning()) {
          return true;
        }
        _alertShowing = true;

        return await showDialog(
            //create confirmation prompt
            context: navigatorKey.currentContext!,
            builder: (context) {
              return AlertDialog(
                  title: const Text('Are you sure you want to quit?'),
                  content: const Text('You may have unsaved changes.'),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          _alertShowing = false;
                        },
                        child: const Text('Quit')),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                          _alertShowing = false;
                        },
                        child: const Text('Cancel'))
                  ]);
            });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Update prompt
      appBar: AppBar(
        title: const Text("IKO Reliability Maximo Tool (beta)"),
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
            ),
          )
        ],
      ),
      drawer: const Drawer(
        //navigation drawer
        child: NavDrawer(),
      ),
      body: SizedBox(
          width: 550,
          child: ListView(children: <Widget>[
            Consumer<MaximoServerNotifier>(
                //login
                builder: (context, maximo, child) {
              return FutureBuilder<Credentials>(
                future: getLoginMaximo(maximo.maximoServerSelected),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data?.password != null &&
                        snapshot.data?.password != '') {
                      return FutureBuilder(
                          future: getUserMaximo(
                              '[APIKEY]',
                              snapshot.data!.password,
                              maximo.maximoServerSelected),
                          builder: ((context, snapshot) {
                            if (snapshot.hasData) {
                              var text = '';
                              if (snapshot.data!['status'] ==
                                  'fail|connection') {
                                text =
                                    'No response from Maximo servers, check internet connection';
                              } else if (snapshot.data!['status'] ==
                                  'fail|account') {
                                text =
                                    'Please check credentials, check internet connection';
                              } else {
                                text =
                                    'Welcome: ${snapshot.data!['displayName']}. Logged into: ${maximo.maximoServerSelected}';
                              }
                              return ListTile(
                                title: Text(text),
                              );
                            } else {
                              return const ListTile(
                                leading: CircularProgressIndicator.adaptive(),
                                title: Text('Logging in...'),
                              );
                            }
                          }));
                    } else {
                      return ListTile(
                        title: const Text('First time using this program?'),
                        subtitle: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Open the Right settings '),
                            Icon(Icons.settings),
                            Text(' menu to login'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            launchUrl(Uri.parse(
                                'https://hssbiz.sharepoint.com/:w:/r/sites/IKOIndustries/Shared%20Documents/Corporate%20Reliability/Asset%20%26%20Spare%20Parts%20Criticality.docx?d=wf2c406fea68f47349cd718ec24a8cee5&csf=1&web=1&e=hYFDFA'));
                          },
                          child: const Text('Documentation'),
                        ),
                      );
                    }
                  } else {
                    return const ListTile(
                      title: Text('Error! Please restart the program'),
                    );
                  }
                }),
              );
            }),
            const ListTile(
              // a spacer
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('To view available module open the left navigation '),
                  Icon(Icons.menu),
                  Text(' menu'),
                ],
              ),
            ),
          ])),
      endDrawer: const EndDrawer(),
    );
  }
}
