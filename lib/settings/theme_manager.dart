import 'package:flutter/material.dart';

import '../bin/db_drift.dart';
import '../main.dart';

///ChangeNotifier for application themes. Used for darkmode and lightmode
class ThemeManager extends ChangeNotifier {
  ThemeMode theme = ThemeMode.light;

  ///controls darkmode/lightmode for the application. Set [isDark] to [true] for darkmode. Notifies all listeners
  setDarkTheme(bool isDark) {
    theme = isDark ? ThemeMode.dark : ThemeMode.light;
    database!.setSettings(
      newSetting: Setting(key: 'darkMode', value: isDark.toString()),
    );
    notifyListeners();
  }
}
