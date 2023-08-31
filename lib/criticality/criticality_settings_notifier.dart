import 'package:flutter/foundation.dart';

import '../admin/db_drift.dart';
import '../main.dart';

enum WorkOrderFilterBy {
  currentSite('Current Site'),
  similarPlant('Similar Plants (Not Implemented)'),
  allSites('All Sites');

  const WorkOrderFilterBy(this.description);

  final String description;
}

class AssetCriticalitySettingsNotifier extends ChangeNotifier {
  ///The id of the currently viewed site on the plutogrid

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

  double frequencyPeriodYears = 10;

  ///sets [selectedSite] to [site].
  ///Updates settings based on selected values for site.
  ///Notifies listeners
  void setSite(String site) async {
    String selectedSite = site;
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
    final filterByString = settings
        .firstWhere(
          (element) => element.key == '$selectedSite-workOrderFilterBy',
          orElse: () =>
              Setting(key: '', value: WorkOrderFilterBy.currentSite.toString()),
        )
        .value;
    workOrderFilterBy = WorkOrderFilterBy.values.byName(filterByString);
    notifyListeners();
  }

  void setPercentages({
    required String selectedSite,
    int? percentVLow,
    int? percentLow,
    int? percentMedium,
    int? percentHigh,
    int? percentVHigh,
  }) {
    if (percentVLow != null) {
      database!.setSettings(
        newSetting: Setting(
            key: '$selectedSite-percentVLow', value: percentVLow.toString()),
      );
      this.percentVLow = percentVLow;
    }
    if (percentLow != null) {
      database!.setSettings(
        newSetting: Setting(
            key: '$selectedSite-percentLow', value: percentLow.toString()),
      );
      this.percentLow = percentLow;
    }
    if (percentMedium != null) {
      database!.setSettings(
        newSetting: Setting(
            key: '$selectedSite-percentMedium',
            value: percentMedium.toString()),
      );
      this.percentMedium = percentMedium;
    }
    if (percentHigh != null) {
      database!.setSettings(
        newSetting: Setting(
            key: '$selectedSite-percentHigh', value: percentHigh.toString()),
      );
      this.percentHigh = percentHigh;
    }
    if (percentVHigh != null) {
      database!.setSettings(
        newSetting: Setting(
            key: '$selectedSite-percentVHigh', value: percentVHigh.toString()),
      );
      this.percentVHigh = percentVHigh;
    }
    notifyListeners();
  }

  ///function to set the work order settings
  void setWOSettings({
    required String selectedSite,
    DateTime? workOrderCutoffStart,
    DateTime? workOrderCutoffEnd,
    WorkOrderFilterBy? workOrderFilterBy,
  }) {
    if (workOrderCutoffStart != null) {
      this.workOrderCutoffStart = workOrderCutoffStart;
      database!.setSettings(
        newSetting: Setting(
            key: '$selectedSite-workOrderCutoffStart',
            value: workOrderCutoffStart.toString()),
      );
    }
    if (workOrderCutoffEnd != null) {
      this.workOrderCutoffEnd = workOrderCutoffEnd;
      database!.setSettings(
        newSetting: Setting(
            key: '$selectedSite-workOrderCutoffEnd',
            value: workOrderCutoffEnd.toString()),
      );
    }
    if (workOrderFilterBy != null) {
      this.workOrderFilterBy = workOrderFilterBy;
      database!.setSettings(
        newSetting: Setting(
            key: '$selectedSite-workOrderFilterBy',
            value: workOrderFilterBy.toString()),
      );
    }
    frequencyPeriodYears = this
            .workOrderCutoffEnd
            .difference(this.workOrderCutoffStart)
            .inDays
            .toDouble() /
        365;
    notifyListeners();
  }
}
