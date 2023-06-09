import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/main.dart';
import 'package:path/path.dart';
import '../admin/db_drift.dart';
import '../admin/consts.dart';

class SettingsNotifier extends ChangeNotifier {
  //Map of current settings
  Map<ApplicationSetting, dynamic> currentSettings = {};

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
      changeSettings(ApplicationSetting.defaultSettings);
      await Future.delayed(
          const Duration(seconds: 1)); //to give time for settings to load
    }
  }

  void changeSettings(
    Map<ApplicationSetting, dynamic> newSettings, {
    bool notify = true,
  }) {
    //update settings obj
    currentSettings.addAll(newSettings);
    //for updating settings database
    List<Setting> listSettings = [];
    newSettings.forEach((key, value) {
      listSettings.add(Setting(key: key.toString(), value: value.toString()));
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

      for (ApplicationSetting setting in ApplicationSetting.values) {
        int index = databaseKeys.indexOf(setting.keyString);

        if (index == -1) {
          //database is in improper format if does not contain all settings
          return false;
        }

        Setting tempSetting = databaseSettings[index];
        //convert saved string value in database to specified data types
        switch (setting.dataType) {
          case 'bool':
            if (tempSetting.value == 'true') {
              currentSettings[setting] = true;
            } else if (tempSetting.value == 'false') {
              currentSettings[setting] = false;
            } else {
              throw Exception(
                  'Unexpected value for setting [${setting.keyString}]. Should be of type ${setting.dataType}');
            }
            break;
          case 'bool?':
            if (tempSetting.value == 'true') {
              currentSettings[setting] = true;
            } else if (tempSetting.value == 'false') {
              currentSettings[setting] = false;
            } else if (tempSetting.value == 'null') {
              currentSettings[setting] = null;
            } else {
              throw Exception(
                  'Unexpected value for setting [${setting.keyString}]. Should be of type ${setting.dataType}');
            }
            break;
          case 'String':
            currentSettings[setting] = tempSetting.value;
            break;
          case 'int':
            currentSettings[setting] = int.parse(tempSetting.value);
            break;
          case 'int?':
            if (tempSetting.value == '' || tempSetting.value == 'null') {
              currentSettings[setting] = null;
            } else {
              currentSettings[setting] = int.parse(tempSetting.value);
            }
            break;
          case 'DateTime':
            currentSettings[setting] = DateTime.parse(tempSetting.value);
            break;
          case 'DateTime?':
            if (tempSetting.value == '' || tempSetting.value == 'null') {
              currentSettings[setting] = null;
            } else {
              currentSettings[setting] = DateTime.parse(tempSetting.value
                  .substring(0,
                      tempSetting.value.indexOf(' '))); //remove time component
            }
            break;
          default:
            throw Exception(
                'Unexpected type [${setting.dataType}] for setting [${setting.keyString}]');
        }
      }
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  dynamic getSetting(ApplicationSetting settingKey) {
    return currentSettings[settingKey];
  }
}
