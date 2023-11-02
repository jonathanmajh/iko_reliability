import 'package:flutter/widgets.dart';
import 'package:collection/collection.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../bin/consts.dart';
import '../bin/db_drift.dart';
import '../main.dart';
import 'asset_criticality_notifier.dart';
import 'criticality_settings_notifier.dart';

class SpareOverrideNotifier extends ChangeNotifier {
  Map<String, AssetOverride> spares = {};

  void updateSpareOverride({
    required List<String> spares,
    required AssetOverride status,
  }) {
    for (var spare in spares) {
      this.spares[spare] = status;
    }
    notifyListeners();
  }

  AssetOverride getSpareStatus(String itemNum) {
    if (spares.containsKey(itemNum)) {
      return spares[itemNum]!;
    }
    return AssetOverride.none;
  }
}

class SpareCriticalitySettingNotifier extends ChangeNotifier {
  int percentC = 60;
  int percentB = 30;
  int percentA = 10;

  AbcCriticality get abcCriticality => AbcCriticality(
        a: percentA.toDouble(),
        b: percentB.toDouble(),
        c: percentC.toDouble(),
      );

  DateTime purchaseCutoffStart =
      DateTime.now().subtract(const Duration(days: 10 * 365));
  DateTime purchaseCutoffEnd = DateTime.now();

  ///Site Filter for work orders used to determine frequency + impact
  ///Currently not used
  WorkOrderFilterBy purchaseFilterBy = WorkOrderFilterBy.currentSite;

  double frequencyPeriodYears = 10;

  void setSite(String site) async {
    String selectedSite = site;
    final settings = await database!.getSettings();
    percentC = int.parse(settings
        .firstWhere(
          (element) => element.key == '$selectedSite-percentC',
          orElse: () => Setting(key: '', value: percentC.toString()),
        )
        .value);
    percentB = int.parse(settings
        .firstWhere(
          (element) => element.key == '$selectedSite-percentB',
          orElse: () => Setting(key: '', value: percentB.toString()),
        )
        .value);
    percentA = int.parse(settings
        .firstWhere(
          (element) => element.key == '$selectedSite-percentA',
          orElse: () => Setting(key: '', value: percentA.toString()),
        )
        .value);
    purchaseCutoffStart = DateTime.parse(settings
        .firstWhere(
          (element) => element.key == '$selectedSite-purchaseCutoffStart',
          orElse: () => Setting(key: '', value: purchaseCutoffStart.toString()),
        )
        .value);
    purchaseCutoffEnd = DateTime.parse(settings
        .firstWhere(
          (element) => element.key == '$selectedSite-purchaseCutoffEnd',
          orElse: () => Setting(key: '', value: purchaseCutoffEnd.toString()),
        )
        .value);
    final filterByString = settings
        .firstWhere(
          (element) => element.key == '$selectedSite-purchaseFilterBy',
          orElse: () => Setting(
              key: '', value: WorkOrderFilterBy.currentSite.name.toString()),
        )
        .value;
    purchaseFilterBy = WorkOrderFilterBy.values.byName(filterByString);
    frequencyPeriodYears =
        purchaseCutoffEnd.difference(purchaseCutoffStart).inDays.toDouble() /
            365;
    notifyListeners();
  }

  void setPurchaseSettings({
    required String selectedSite,
    DateTime? purchaseCutoffStart,
    DateTime? purchaseCutoffEnd,
    WorkOrderFilterBy? purchaseFilterBy,
  }) {
    if (purchaseCutoffStart != null) {
      this.purchaseCutoffStart = purchaseCutoffStart;
      database!.setSettings(
        newSetting: Setting(
            key: '$selectedSite-purchaseCutoffStart',
            value: purchaseCutoffStart.toString()),
      );
    }
    if (purchaseCutoffEnd != null) {
      this.purchaseCutoffEnd = purchaseCutoffEnd;
      database!.setSettings(
        newSetting: Setting(
            key: '$selectedSite-purchaseCutoffEnd',
            value: purchaseCutoffEnd.toString()),
      );
    }
    if (purchaseFilterBy != null) {
      this.purchaseFilterBy = purchaseFilterBy;
      database!.setSettings(
        newSetting: Setting(
            key: '$selectedSite-purchaseFilterBy',
            value: purchaseFilterBy.name.toString()),
      );
    }
    frequencyPeriodYears = this
            .purchaseCutoffEnd
            .difference(this.purchaseCutoffStart)
            .inDays
            .toDouble() /
        365;
    notifyListeners();
  }
}

class AbcCriticality {
  double c;
  double b;
  double a;

  AbcCriticality({
    required this.c,
    required this.b,
    required this.a,
  });

  double getOrdered(int i) {
    switch (i) {
      case 0:
        return c;
      case 1:
        return b;
      case 2:
        return a;
      default:
        throw Exception('$i is not defined for AbcCriticality');
    }
  }

  List<double> ordered() {
    return [
      c,
      b,
      a,
    ];
  }
}

AbcCriticality calculateRPNCutOffsSpares({
  required AbcCriticality targetPercentages,
  required Map<double, int> frequencyOfRPNs,
}) {
  if (frequencyOfRPNs.keys.length < 3) {
    throw Exception(
        'At least 3 unique values required to calculate Criticality from RPN\nCurrent values ${frequencyOfRPNs.keys.toList()}');
  }
  List<double> sortedUniqueRPNs = frequencyOfRPNs.keys.toList();
  sortedUniqueRPNs.sort();
  final totalRPNCount = frequencyOfRPNs.values.toList().sum;
  List<double> results = [];
  List<double> result = [0, 0];
  List<double> results2 = [];
  int cumulativePercentage = 0;
  // calculations
  for (int i = 0; i < 3; i++) {
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
          'RPN calculation failed: ${abcStrings[i]} target of ${targetPercentages.getOrdered(i)}% cannot be achieved');
    }
  }
  debugPrint('Number of items in each group: $results2, Total: $totalRPNCount');
  return AbcCriticality(
    c: results[0],
    b: results[1],
    a: results[2],
  );
}

class SpareCriticalityNotifier extends ChangeNotifier {
  List<double> rpnCutoffs = [];
  bool updateGrid = true;
  PlutoGridStateManager? stateManager;

  ///sets the rpnCutoffs to the [newCutoffs] and notifies listeners
  void setRpnCutoffs(List<double> newCutoffs) {
    rpnCutoffs = List.of(newCutoffs);
    notifyListeners();
  }

  int rpnFindDistribution(double rpn) {
    try {
      if (rpnCutoffs.length != 3) {
        throw Exception('Unexpected format for List [rpnCutoffs]');
      }
      if (rpn <= 0) throw Exception('Negative RPN');
      for (int i = 0; i < spareCriticality.length; i++) {
        if (rpn <= rpnCutoffs[i]) return spareCriticality.keys.elementAt(i);
      }
      return spareCriticality.keys.last;
    } catch (e) {
      return 0;
    }
  }
}
