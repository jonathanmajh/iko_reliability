import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/main.dart';
import '../admin/db_drift.dart';

class SettingsNotifier extends ChangeNotifier {
  late Setting settings;
  late Stream<Setting> settingsStream;
  late StreamSubscription<Setting> settingStreamSubscription;

  SettingsNotifier() {
    settings = const Setting(id: 0, darkmode: false, updateWindowOff: false);
    settingsStream = database!.getSettingsStream();
    settingStreamSubscription = settingsStream.listen(newItemOnStream);
  }

  Future initialize() async {
    try {
      settings = (await database!.getSettings()) ?? settings;
    } catch (e) {
      print(e.toString());
    } finally {
      if (settings.id == 0) {
        //if can't load settings, use default settings
        changeSettings(
          //TODO: add more optional params when [Setting] has more fields
          darkmode: (ThemeMode.system ==
              Brightness.dark), //use OS theme settings by default
          updateWindowOff: false,
        );
      }
    }
  }

  //only notify listeners when there are setting changes
  void newItemOnStream(Setting event) {
    if (settings.toString() != event.toString()) {
      settings = event;
      notifyListeners();
    }
  }

  void changeSettings({
    bool notify = true,
    bool? darkmode,
    bool? updateWindowOff,
  }) {
    settings = Setting(
        id: 1,
        darkmode: darkmode ?? settings.darkmode,
        updateWindowOff: updateWindowOff ?? settings.updateWindowOff);
    if (notify) notifyListeners();
    database!.updateSettings(settings);
  }
}
