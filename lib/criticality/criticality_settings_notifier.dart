import 'package:flutter/foundation.dart';

import '../admin/db_drift.dart';
import '../main.dart';

enum WorkOrderFilterBy {
  currentSite,
  similarPlant,
  allSites,
}

class AssetCriticalitySettingsNotifier extends ChangeNotifier {
  ///The id of the currently viewed site on the plutogrid
  String selectedSite = '';

  ///Target percentages for assign criticality values
  int percentVLow = 30;
  int percentLow = 25;
  int percentMedium = 20;
  int percentHigh = 15;
  int percentVHigh = 10;

  ///Cut off dates for work orders used to determine frequency + impact
  DateTime workOrderCutoffStart =
      DateTime.now().subtract(const Duration(days: 10 * 365));
  DateTime workOrderCutoffEnd = DateTime.now();

  ///Site Filter for work orders used to determine frequency + impact
  ///Currently not used
  WorkOrderFilterBy workOrderFilterBy = WorkOrderFilterBy.currentSite;

  ///sets [selectedSite] to [site].
  ///Updates settings based on selected values for site.
  ///Notifies listeners
  void setSite(String site) async {
    selectedSite = site;
    final settings = await database!.getSettings();
    percentVLow = int.parse(settings
        .firstWhere(
          (element) => element.key == '$selectedSite-percentVLow',
          orElse: () => Setting(key: '', value: percentVLow.toString()),
        )
        .value);
    percentLow = int.parse(settings
        .firstWhere(
          (element) => element.key == '$selectedSite-percentLow',
          orElse: () => Setting(key: '', value: percentLow.toString()),
        )
        .value);
    percentMedium = int.parse(settings
        .firstWhere(
          (element) => element.key == '$selectedSite-percentMedium',
          orElse: () => Setting(key: '', value: percentMedium.toString()),
        )
        .value);
    percentHigh = int.parse(settings
        .firstWhere(
          (element) => element.key == '$selectedSite-percentHigh',
          orElse: () => Setting(key: '', value: percentHigh.toString()),
        )
        .value);
    percentVHigh = int.parse(settings
        .firstWhere(
          (element) => element.key == '$selectedSite-percentVHigh',
          orElse: () => Setting(key: '', value: percentVHigh.toString()),
        )
        .value);
    workOrderCutoffStart = DateTime.parse(settings
        .firstWhere(
          (element) => element.key == '$selectedSite-workOrderCutoffStart',
          orElse: () =>
              Setting(key: '', value: workOrderCutoffStart.toString()),
        )
        .value);
    workOrderCutoffEnd = DateTime.parse(settings
        .firstWhere(
          (element) => element.key == '$selectedSite-workOrderCutoffEnd',
          orElse: () => Setting(key: '', value: workOrderCutoffEnd.toString()),
        )
        .value);

    notifyListeners();
  }

  void setPercentages({
    int? percentVLow,
    int? percentLow,
    int? percentMedium,
    int? percentHigh,
    int? percentVHigh,
  }) {
    if (percentVLow != null) {
      database!.setSettings(
          newSetting: Setting(
              key: '$selectedSite-percentVLow', value: percentVLow.toString()));
      this.percentVLow = percentVLow;
    }
    if (percentLow != null) {
      database!.setSettings(
          newSetting: Setting(
              key: '$selectedSite-percentLow', value: percentLow.toString()));
      this.percentLow = percentLow;
    }
    if (percentMedium != null) {
      database!.setSettings(
          newSetting: Setting(
              key: '$selectedSite-percentMedium',
              value: percentMedium.toString()));
      this.percentMedium = percentMedium;
    }
    if (percentHigh != null) {
      database!.setSettings(
          newSetting: Setting(
              key: '$selectedSite-percentHigh', value: percentHigh.toString()));
      this.percentHigh = percentHigh;
    }
    if (percentVHigh != null) {
      database!.setSettings(
          newSetting: Setting(
              key: '$selectedSite-percentVHigh',
              value: percentVHigh.toString()));
      this.percentVHigh = percentVHigh;
    }
    notifyListeners();
  }

  ///function to set the work order settings
  // void setWOSettings({
  //   required DateTime? beforeDate,
  //   required DateTime? afterDate,
  //   required bool usingBeforeDate,
  //   required bool usingAfterDate,
  //   required bool showAllSites,
  //   bool notify = true,
  // }) {
  //   this.beforeDate = beforeDate;
  //   this.afterDate = afterDate;
  //   this.usingBeforeDate = usingBeforeDate;
  //   this.usingAfterDate = usingAfterDate;
  //   this.showAllSites = showAllSites;

  //   if (notify) notifyListeners();
  // }
}
