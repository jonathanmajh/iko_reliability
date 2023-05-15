import 'package:flutter/material.dart';

class ThemeManager extends ChangeNotifier {
  ThemeManager(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
  }
  ThemeMode _themeMode = ThemeMode.light;

  get themeMode => _themeMode;

  toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    print(_themeMode.toString());
    notifyListeners();
  }
}
