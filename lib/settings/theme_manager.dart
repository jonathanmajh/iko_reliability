import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/settings/settings_notifier.dart';
import 'package:provider/provider.dart';
import '../admin/consts.dart';

///ChangeNotifier for application themes. Used for darkmode and lightmode
class ThemeManager extends ChangeNotifier {
  ThemeManager(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
  }
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => (_themeMode == ThemeMode.dark);

  ///controls darkmode/lightmode for the application. Set [isDark] to [true] for darkmode. Notifies all listeners
  toggleTheme(bool isDark, BuildContext context) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    Provider.of<SettingsNotifier>(context, listen: false)
        .changeSettings({ApplicationSetting.darkmodeOn: isDark}, notify: false);
    notifyListeners();
  }
}
