import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/main.dart';
import 'package:path/path.dart';
import '../admin/db_drift.dart';
import '../admin/consts.dart';

class SettingsNotifier extends ChangeNotifier {
  //const fields for setting keys
  //TODO: should find a cleaner way to do this
  //HUST:luz2Ua91ay
  static const String darkmodeOn = 'dark mode on';
  static const String updateWindowOff = 'update window off';

  //default settings add entries with new settings
  //HUST:luz2Ua91ay
  static Map<String, dynamic> defaultSettings = {
    darkmodeOn: ThemeMode.system == Brightness.dark,
    updateWindowOff: false
  };

  //Map of current settings
  Map<String, dynamic> currentSettings = {};

  SettingsNotifier() {
    currentSettings = {};
  }

  Future initialize() async {
    try {
      if (!(await loadSettingsFromDatabase())) {
        throw Exception('Could not load settings from database');
      }
    } catch (e) {
      print(e.toString());
      //load default settings
      changeSettings(defaultSettings);
    }
  }

  void changeSettings(
    Map<String, dynamic> newSettings, {
    bool notify = true,
  }) {
    //update settings obj
    currentSettings.addAll(newSettings);
    //for updating settings database
    List<Setting> listSettings = [];
    newSettings.forEach((key, value) {
      listSettings.add(Setting(key: key, value: value.toString()));
    });

    if (notify) notifyListeners();
    database!.updateSettings(newSettings: listSettings);
  }

  ///loads settings from the database. Returns true if managed, else returns false
  Future<bool> loadSettingsFromDatabase() async {
    try {
      List<Setting> databaseSettings = (await database!.getSettings());
      //get a list of settings keys in database
      List<String> databaseKeys =
          List<String>.filled(databaseSettings.length, '');
      for (int i = 0; i < databaseKeys.length; i++) {
        databaseKeys[i] = databaseSettings[i].key;
      }

      for (String key in applicationSettingKeys.keys) {
        int index = databaseKeys.indexOf(key);

        if (index == -1) {
          //database is in improper format if does not contain all settings
          return false;
        }

        Setting tempSetting = databaseSettings[index];
        //convert saved string value in database to specified data types
        switch (applicationSettingKeys[key]) {
          case 'bool':
            if (tempSetting.value == 'TRUE') {
              currentSettings[key] = true;
            } else if (tempSetting.value == 'FALSE') {
              currentSettings[key] = 'FALSE';
            } else {
              throw Exception(
                  'Unexpected value for setting $key. Should be of type ${applicationSettingKeys[key]}');
            }
            break;
          case 'bool?':
            if (tempSetting.value == 'TRUE') {
              currentSettings[key] = true;
            } else if (tempSetting.value == 'FALSE') {
              currentSettings[key] = 'FALSE';
            } else if (tempSetting.value == 'null') {
              currentSettings[key] = null;
            } else {
              throw Exception(
                  'Unexpected value for setting $key. Should be of type ${applicationSettingKeys[key]}');
            }
            break;
          case 'String':
            currentSettings[key] = tempSetting.value;
            break;
          case 'int':
            currentSettings[key] = int.parse(tempSetting.value);
            break;
          case 'int?':
            if (tempSetting.value == '' || tempSetting.value == 'null') {
              currentSettings[key] = null;
            } else {
              currentSettings[key] = int.parse(tempSetting.value);
            }
            break;
          case 'DateTime':
            currentSettings[key] = DateTime.parse(tempSetting.value);
            break;
          case 'DateTime?':
            if (tempSetting.value == '' || tempSetting.value == 'null') {
              currentSettings[key] = null;
            } else {
              currentSettings[key] = DateTime.parse(tempSetting.value);
            }
            break;
          default:
            throw Exception(
                'Unexpected type [${applicationSettingKeys[key]}] for setting [$key]');
        }
      }
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  dynamic getSetting(String settingKey) {
    return currentSettings[settingKey];
  }
}
