import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:iko_reliability_flutter/bin/consts.dart';

import '../bin/db_drift.dart';
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

  FiveCriticality get fiveCriticality => FiveCriticality(
        veryLow: percentVLow.toDouble(),
        low: percentLow.toDouble(),
        medium: percentMedium.toDouble(),
        high: percentHigh.toDouble(),
        veryHigh: percentVHigh.toDouble(),
      );

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
          orElse: () => Setting(
              key: '', value: WorkOrderFilterBy.currentSite.name.toString()),
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
    frequencyPeriodYears =
        workOrderCutoffEnd.difference(workOrderCutoffStart).inDays.toDouble() /
            365;
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
            value: workOrderFilterBy.name.toString()),
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

class FiveCriticality {
  double veryLow;
  double low;
  double medium;
  double high;
  double veryHigh;

  FiveCriticality({
    required this.veryLow,
    required this.low,
    required this.medium,
    required this.high,
    required this.veryHigh,
  });

  double getOrdered(int i) {
    switch (i) {
      case 0:
        return veryLow;
      case 1:
        return low;
      case 2:
        return medium;
      case 3:
        return high;
      case 4:
        return veryHigh;
      default:
        throw Exception('$i is not defined for FiveCriticality');
    }
  }

  List<double> ordered() {
    return [
      veryLow,
      low,
      medium,
      high,
      veryHigh,
    ];
  }
}

FiveCriticality calculateRPNCutOffs({
  required FiveCriticality targetPercentages,
  required Map<double, int> frequencyOfRPNs,
}) {
  if (frequencyOfRPNs.keys.length < 5) {
    throw Exception(
        'At least 5 unique values required to calculate Criticality from RPN\nCurrent values ${frequencyOfRPNs.keys.toList()}');
  }
  List<double> sortedUniqueRPNs = frequencyOfRPNs.keys.toList();
  sortedUniqueRPNs.sort();
  final totalRPNCount = frequencyOfRPNs.values.toList().sum;
  List<double> results = [];
  List<double> result = [0, 0];
  List<double> results2 = [];
  int cumulativePercentage = 0;
  // calculations
  for (int i = 0; i < 5; i++) {
    try {
      cumulativePercentage += targetPercentages.getOrdered(i).toInt();
      result = calculateSingleCutoff(
        target: cumulativePercentage,
        sortedUniqueRPNs: sortedUniqueRPNs,
        frequencyOfRPNs: frequencyOfRPNs,
        totalRPNCount: totalRPNCount,
      );
      results.add(result[1]);
      results2.add(result[2]);
    } catch (e) {
      throw Exception(
          'RPN calculation failed: ${criticalityStrings[i]} target of ${targetPercentages.getOrdered(i)}% cannot be achieved');
    }
  }
  debugPrint(
      'Number of assets in each group: $results2, Total: $totalRPNCount');
  return FiveCriticality(
    veryLow: results[0],
    low: results[1],
    medium: results[2],
    high: results[3],
    veryHigh: results[4],
  );
}

/// returns index of next rpn, largets rpn in range, total assets in range
List<double> calculateSingleCutoff({
  required int target,
  required List<double> sortedUniqueRPNs,
  required Map<double, int> frequencyOfRPNs,
  required int totalRPNCount,
}) {
  // since the last group encompases all of the elements we can just pass the full set back
  if (target == 100) {
    return [0, sortedUniqueRPNs.last, totalRPNCount.toDouble()];
  }
  int i = 1;
  double currentPercent = 0;
  double previousPercent = 0;
  // calculation for very low
  while (i <= sortedUniqueRPNs.length) {
    int sumRPNs = 0;
    sortedUniqueRPNs.sublist(0, i).forEach((element) {
      sumRPNs = sumRPNs + frequencyOfRPNs[element]!;
    });
    currentPercent = sumRPNs / totalRPNCount * 100;
    // keep going to the next value until the new percentage is larger than previous percentage
    if ((currentPercent - target).abs() > (previousPercent - target).abs()) {
      return [previousPercent, sortedUniqueRPNs[i - 1], sumRPNs.toDouble()];
    } else {
      previousPercent = currentPercent;
      i++;
    }
  }
  throw Exception('RPN Cannot be calculated');
}
