import 'package:flutter/foundation.dart' show PlatformDispatcher, kIsWeb;
import 'dart:io' show Platform;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/bin/consts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iko_reliability_flutter/bin/logger_web.dart';
import 'package:iko_reliability_flutter/bin/logger_windows.dart';
import 'package:iko_reliability_flutter/settings/settings_notifier.dart';
import 'package:iko_reliability_flutter/settings/theme_manager.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:window_size/window_size.dart';

import 'bin/db_drift.dart';
import 'bin/drawer.dart';
import 'bin/end_drawer.dart';
import 'admin/template_notifier.dart';
import 'bin/check_update.dart';
import 'criticality/asset_criticality_notifier.dart';
import 'creation/asset_creation_notifier.dart';
import 'bin/process_state_notifier.dart';
import 'criticality/criticality_settings_notifier.dart';
import 'criticality/spare_criticality_notifier.dart';
import 'criticality/system_criticality_notifier.dart';
import 'routes/route.dart';

MyDatabase? database;
final navigatorKey = GlobalKey<NavigatorState>();
Logger? logger;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    logger = Logger(
      filter: ProductionFilter(),
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 6,
        lineLength: 80,
        colors: false,
        printEmojis: false,
        printTime: true,
      ),
      output: AppConsoleOutput(),
    );
  } else if (Platform.isWindows) {
    setWindowMinSize(const Size(640, 360));
    logger = Logger(
      filter: ProductionFilter(),
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 6,
        lineLength: 80,
        colors: false,
        printEmojis: false,
        printTime: true,
      ),
      output: AppFileOutput(),
    );
  }
  // put flutter errors in the logger
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    logger?.f(
      details.exceptionAsString(),
      error: (details.toDiagnosticsNode().toStringDeep()),
      stackTrace: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (exception, stackTrace) {
    logger?.f(
      "Unhandled Exception",
      error: exception,
      stackTrace: stackTrace,
    );
    return false;
  };
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
  SelectedSiteNotifier selectedSiteNotifier = SelectedSiteNotifier();
  ThemeManager themeManager = ThemeManager();
  await settingsNotifier.initialize();
  await loadAppSettings(selectedSiteNotifier, themeManager, settingsNotifier);
  runApp(
    MyApp(
      settingsNotifier,
      selectedSiteNotifier,
      themeManager,
    ),
  );
  await checkForUpdate();
}

///ChangeNotifier for current maximo server/environment
class MaximoServerNotifier extends ChangeNotifier {
  String maximoServerSelected = 'MASPROD';

  void setServer(String server) {
    maximoServerSelected = server;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  MyApp(this.settingsNotifier, this.selectedSiteNotifier, this.themeManager,
      {super.key});
  final _appRouter = AppRouter(navigatorKey: navigatorKey);
  final SettingsNotifier settingsNotifier;
  final SelectedSiteNotifier selectedSiteNotifier;
  final ThemeManager themeManager;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => TemplateNotifier()),
          ChangeNotifierProvider(create: (context) => UploadNotifier()),
          ChangeNotifierProvider(create: (context) => MaximoServerNotifier()),
          ChangeNotifierProvider(create: (context) => settingsNotifier),
          ChangeNotifierProvider(create: (context) => themeManager),
          //set initial brightness according to system settings
          ChangeNotifierProvider(create: (context) => ProcessStateNotifier()),
          ChangeNotifierProvider(
              create: (context) => AssetCriticalityNotifier()),
          ChangeNotifierProvider(create: (context) => AssetCreationNotifier()),
          ChangeNotifierProvider(
              create: (context) => AssetCriticalitySettingsNotifier()),
          ChangeNotifierProvider(
              create: (context) => SpareCriticalitySettingNotifier()),
          ChangeNotifierProvider(
              create: (context) => SpareCriticalityNotifier()),
          ChangeNotifierProvider(create: (context) => AssetStatusNotifier()),
          ChangeNotifierProvider(create: (context) => selectedSiteNotifier),
          ChangeNotifierProvider(create: (context) => AssetOverrideNotifier()),
          ChangeNotifierProvider(create: (context) => SpareOverrideNotifier()),
          ChangeNotifierProvider(
              create: (context) => SystemCriticalityNotifier()),
        ],
        child: Builder(
          builder: (context) {
            return MaterialApp.router(
              routerConfig: _appRouter.config(),
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
              themeMode: Provider.of<ThemeManager>(context).theme,
            );
          },
        ));
  }
}

Future<void> loadAppSettings(SelectedSiteNotifier selectedSiteNotifier,
    ThemeManager themeManager, SettingsNotifier settingsNotifier) async {
  logger?.d('Loading App Settings Before Start');
  final settings = await database!.getSettings();
  final selectedSite = settings
      .firstWhere(
        (element) => element.key == 'selectedSite',
        orElse: () => const Setting(key: '', value: ''),
      )
      .value;
  selectedSiteNotifier.selectedSite = selectedSite;
  final darkMode = bool.parse(settings
      .firstWhere(
        (element) => element.key == 'darkMode',
        orElse: () => const Setting(key: '', value: 'false'),
      )
      .value);
  themeManager.setDarkTheme(darkMode);
}

Future<void> checkForUpdate() async {
  final update = await checkUpdate();
  if (update) {
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
              ],
            );
          }),
        ]);
  }
}

///Homepage widget (Stateful)
@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
    if (!kIsWeb) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Update prompt
      appBar: AppBar(
        title: const Text("IKO Reliability Maximo Tool (beta)"),
      ),
      drawer: const Drawer(
        //navigation drawer
        child: NavDrawer(),
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
