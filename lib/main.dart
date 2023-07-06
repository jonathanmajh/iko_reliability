import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/admin/consts.dart';
import 'package:iko_reliability_flutter/routes/route.gr.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iko_reliability_flutter/settings/settings_notifier.dart';
import 'package:iko_reliability_flutter/settings/theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_window_close/flutter_window_close.dart';

import 'admin/cache_notifier.dart';
import 'admin/db_drift.dart';
import 'admin/end_drawer.dart';
import 'admin/template_notifier.dart';
import 'bin/check_update.dart';
import 'criticality/asset_criticality_notifier.dart';
import 'criticality/criticality_notifier.dart';
import 'admin/process_state_notifier.dart';

MyDatabase? database;
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('pmNumber');
  await Hive.openBox('jpNumber');
  await Hive.openBox('routeNumber');
  var box = Hive.box('jpNumber');
  box.clear();
  box = Hive.box('pmNumber');
  box.clear();
  box = Hive.box('routeNumber');
  box.clear();
  database = MyDatabase();
  SettingsNotifier settingsNotifier = SettingsNotifier();
  await settingsNotifier.initialize();
  runApp(
    MyApp(settingsNotifier),
  );
}

///ChangeNotifier for current maximo server/environment
class MaximoServerNotifier extends ChangeNotifier {
  String maximoServerSelected = 'MASTEST';

  void setServer(String server) {
    maximoServerSelected = server;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  MyApp(this.settingsNotifier, {Key? key}) : super(key: key);
  final _appRouter = AppRouter(navigatorKey);
  final SettingsNotifier settingsNotifier;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => TemplateNotifier()),
          ChangeNotifierProvider(create: (context) => UploadNotifier()),
          ChangeNotifierProvider(create: (context) => MaximoServerNotifier()),
          ChangeNotifierProvider(create: (context) => SystemsNotifier()),
          ChangeNotifierProvider(create: (context) => WorkOrderNotifier()),
          ChangeNotifierProvider(create: (context) => RpnCriticalityNotifier()),
          ChangeNotifierProvider(create: (context) => settingsNotifier),
          ChangeNotifierProvider(
              create: (context) => ThemeManager(
                  settingsNotifier.getSetting(ApplicationSetting.darkmodeOn))),
          //set initial brightness according to system settings
          ChangeNotifierProvider(create: (context) => ProcessStateNotifier()),
          ChangeNotifierProvider(create: (context) => Cache()),
          ChangeNotifierProvider(
              create: (context) => AssetCriticalityNotifier()),
        ],
        child: Builder(
          builder: (context) {
            return MaterialApp.router(
              routerDelegate: _appRouter.delegate(),
              routeInformationParser: _appRouter.defaultRouteParser(),
              title: 'IKO Flutter Reliability',
              theme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: const Color(0xFFFF0000),
              ),
              //sets color for theme
              darkTheme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: const Color(0xFFFF0000),
                brightness: Brightness.dark,
              ),
              themeMode: Provider.of<ThemeManager>(context).themeMode,
            );
          },
        ));
  }
}

///Homepage widget (Stateful)
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ///if update window should be hidden
  bool hideUpdateWindow = false;

  ///if an alert dialog is showing
  bool _alertShowing = false;

  @override
  void initState() {
    super.initState();
    //closing confirmation prompt
    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      if (_alertShowing) {
        //don't create another prompt if one already exists
        return false;
      }

      //check if there are any processes running
      var processNotifier =
          Provider.of<ProcessStateNotifier>(context, listen: false);

      if (!processNotifier.processRunning()) {
        return true;
      }
      _alertShowing = true;

      return await showDialog(
          //create confirmation prompt
          context: context,
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

  @override
  Widget build(BuildContext context) {
    SettingsNotifier settings = Provider.of<SettingsNotifier>(context);
    hideUpdateWindow = settings.getSetting(ApplicationSetting.updateWindowOff);

    return Scaffold(
      //Update prompt
      onDrawerChanged: (isOpened) async {
        final update = await checkUpdate();
        if (!hideUpdateWindow && update) {
          showDataAlert(
              ['Update available'],
              'Update Checker',
              [
                StatefulBuilder(builder: (context, setState) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          launchUrl(Uri.parse(
                              'https://github.com/jonathanmajh/iko_reliability/releases/latest'));
                        },
                        child: const Text('Download Update'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                              value: hideUpdateWindow,
                              onChanged: (bool? value) {
                                setState(() {
                                  settings.changeSettings({
                                    ApplicationSetting.updateWindowOff: value!
                                  }, notify: false);
                                  hideUpdateWindow = settings.getSetting(
                                      ApplicationSetting.updateWindowOff);
                                });
                              }),
                          const Text(
                            'Don\'t show again',
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ]);
        }
      },
      appBar: AppBar(
        title: const Text("IKO Reliability Maximo Tool (beta)"),
      ),
      drawer: Drawer(
        //navigation drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'IKO Reliability Maximo',
                  style: TextStyle(
                    // color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const Text(
                  'display name...',
                  style: TextStyle(
                    // color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const Text('userid'),
                const Text('Status'),
                // update notifier when the menu is opened
                Consumer<SystemsNotifier>(builder: (context, systems, child) {
                  systems.updateSystems();
                  return Text(Provider.of<MaximoServerNotifier>(context)
                      .maximoServerSelected);
                }),
              ],
            )),
            const ListTile(
              leading: Icon(Icons.message),
              title: Text('Home'),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Test'),
              onTap: () {
                context.router.pushNamed("/test");
                // change app state...
                Navigator.pop(context); // close the drawer
              },
            ),
            ExpansionTile(
              title: const Text("Assets"),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Create Assets'),
                  onTap: () {
                    context.router.pushNamed("/asset");
                    // change app state...
                    Navigator.pop(context); // close the drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Asset Criticality'),
                  onTap: () {
                    context.router.pushNamed("/asset/criticality");
                    try {
                      context
                          .read<Cache>()
                          .calculateSystemScores(); //load system score data
                    } catch (e) {
                      debugPrint(
                          'Could not load system scores from cache \n${e}');
                    }
                    // change app state...
                    Navigator.pop(context); // close the drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('System Criticality'),
                  onTap: () {
                    context.router.pushNamed("/asset/system-criticality");
                    // change app state...
                    Navigator.pop(context); // close the drawer
                  },
                ),
              ],
            ),
            ExpansionTile(
              title: const Text("Maximo Admin"),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Validate PMs'),
                  onTap: () {
                    context.router.pushNamed("/pm/check");
                    // change app state...
                    Navigator.pop(context); // close the drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Update PM Meters'),
                  onTap: () {
                    context.router.pushNamed("/pm/update-meter");
                    // change app state...
                    Navigator.pop(context); // close the drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Create Assets'),
                  onTap: () {
                    context.router.pushNamed("/asset");
                    // change app state...
                    Navigator.pop(context); // close the drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Create Contractors'),
                  onTap: () {
                    context.router.pushNamed("/contractor");
                    // change app state...
                    Navigator.pop(context); // close the drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Generate Timesheets'),
                  onTap: () {
                    context.router.pushNamed("/timesheet");
                    // change app state...
                    Navigator.pop(context); // close the drawer
                  },
                ),
              ],
            )
          ],
        ),
      ),
      body: ListView(// homepage widgets
          children: const <Widget>[
        ListTile(
          // a spacer
          title: Text(
              'Open the menu on the right, then select a module to get started'),
        ),
        ListTile(
          // a spacer
          title: Text(
              'For Asset Criticality Generator, save the processed breakdown data into sharepoint'),
        )
      ]),
      endDrawer: const EndDrawer(),
    );
  }
}

///shows an alert dialog with [title] as the title and [messages] as the description rows
showDataAlert(List<String> messages, String title,
    [List<Widget> widgets = const []]) {
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              20.0,
            ),
          ),
        ),
        contentPadding: const EdgeInsets.only(
          top: 10.0,
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 24.0),
        ),
        content: SizedBox(
          height: 400,
          width: 400,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ...messageListTile(messages),
                  const Divider(
                    // spacer
                    height: 10,
                    thickness: 0,
                    indent: 0,
                    endIndent: 0,
                    color: Colors.transparent,
                  ),
                  ...widgets,
                  const Divider(
                    // spacer
                    height: 10,
                    thickness: 0,
                    indent: 0,
                    endIndent: 0,
                    color: Colors.transparent,
                  ),
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "OK",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

///creates a list of text widgets from [messages]
List<Widget> messageListTile(List<String> messages) {
  List<Widget> list = [];
  for (final msg in messages) {
    list.add(Text(msg));
  }
  return list;
}
