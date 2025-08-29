import 'package:flutter/foundation.dart' show PlatformDispatcher, kIsWeb;
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/admin/pm_jp_storage.dart';
import 'package:iko_reliability_flutter/bin/logger_web.dart';
import 'package:iko_reliability_flutter/bin/logger_windows.dart';
import 'package:iko_reliability_flutter/items/item_db.dart';
import 'package:iko_reliability_flutter/items/item_notifier.dart';
import 'package:iko_reliability_flutter/settings/settings_notifier.dart';
import 'package:iko_reliability_flutter/settings/theme_manager.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_size/window_size.dart';

import 'bin/db_drift.dart';
import 'admin/template_notifier.dart';
import 'bin/check_update.dart';
import 'criticality/asset_criticality_notifier.dart';
import 'creation/asset_creation_notifier.dart';
import 'bin/process_state_notifier.dart';
import 'criticality/criticality_settings_notifier.dart';
import 'criticality/spare_criticality_notifier.dart';
import 'criticality/system_criticality_notifier.dart';
import 'routes/route.dart';
import 'notifiers/maximo_server_notifier.dart';
import 'bin/common.dart';

MyDatabase? database;
ItemDatabase? itemDatabase;
final navigatorKey = GlobalKey<NavigatorState>();
Logger? logger;
int connectionPool = 0;
NumberNotifier numberNotifier = NumberNotifier();

/// The main entry point for the IKO Reliability Maximo Tool application.
///
/// Initializes logging, database, settings, and launches the app.
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
        dateTimeFormat: DateTimeFormat.dateAndTime,
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
        dateTimeFormat: DateTimeFormat.dateAndTime,
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
  numberNotifier.clear();
  database = MyDatabase();
  itemDatabase = ItemDatabase();
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
  // Pass context to checkForUpdate via WidgetsBinding
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      checkForUpdate(context);
    }
  });
}

/// The root widget of the IKO Reliability Maximo Tool application.
class MyApp extends StatelessWidget {
  /// Constructs the app with required notifiers and theme manager.
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
          ChangeNotifierProvider(create: (context) => ItemNotifier()),
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

/// Loads application settings from the database and applies them to notifiers.
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
  final isAdmin = bool.parse(settings
      .firstWhere(
        (element) => element.key == 'isAdmin',
        orElse: () => const Setting(key: '', value: 'false'),
      )
      .value);
  settingsNotifier.setAdmin(isAdmin);
}

/// Checks for application updates and shows an alert if an update is available.
Future<void> checkForUpdate(BuildContext context) async {
  final update = await checkUpdate();
  if (update) {
    showDataAlert(
        navigatorKey.currentContext!,
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
