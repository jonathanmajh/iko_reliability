import 'package:flutter/material.dart';

//states of GUI settings
class AccessibilitySettings extends ChangeNotifier {
  bool darkModeOn = false;

  bool toggleDarkMode() {
    darkModeOn = !darkModeOn;
    notifyListeners();
    return darkModeOn;
  }

}