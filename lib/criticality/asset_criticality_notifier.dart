import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../admin/consts.dart';

///ChangeNotifier for data in AssetCriticalityPage
class AssetCriticalityNotifier extends ChangeNotifier {
  ///Map where the keys are the plutogrid row and the values are the rpns
  Map<String, double> rpnMap = {};

  ///List of cutoff rpns for priorites from very low to very high
  List<double> rpnCutoffs = [];

  ///flag if the priority ranges are up to date. Used to show warnings when exporting
  bool priorityRangesUpToDate = true;

  ///the stateManager of the main plutogrid
  PlutoGridStateManager? stateManager;

  ///list of rpns. Not ordered
  List<double> get rpnList => List<double>.of(rpnMap.values);

  ///whether to reload the grid
  bool updateGrid = false;

  ///sets [rpnMap] to a copy of [newMap]. Notifies listeners
  void setRpnMap(Map<String, double> newMap, {bool notify = true}) {
    rpnMap = Map<String, double>.of(newMap);
    if (notify) notifyListeners();
  }

  ///adds [appendMap] to [rpnMap]. Notifies Listeners
  void addToRpnMap(Map<String, double> appendMap, {bool notify = true}) {
    rpnMap.addAll(appendMap);
    if (notify) notifyListeners();
  }

  ///sets the rpnCutoffs to the [newCutoffs] and notifies listeners
  void setRpnCutoffs(List<double> newCutoffs) {
    rpnCutoffs = List.of(newCutoffs);
    notifyListeners();
  }

  ///finds the risk priority for a given rpn
  String rpnFindDistribution(double rpn) {
    try {
      if (rpnCutoffs.length != 5) {
        throw Exception('Unexpected format for List [rpnCutoffs]');
      }
      if (rpn <= 0) throw Exception('Negative RPN');
      for (int i = 0; i < criticalityStrings.length; i++) {
        if (rpn <= rpnCutoffs[i]) return criticalityStrings[i];
      }
      return criticalityStrings[4];
    } catch (e) {
      return '---';
    }
  }
}

class AssetStatusNotifier extends ChangeNotifier {
  Map<String, AssetStatus> assets = {};
  List<String> parentAssets = [];
  //  assetnum:

  void updateAssetStatus({
    required List<String> assets,
    required AssetStatus status,
  }) {
    for (var asset in assets) {
      this.assets[asset] = status;
    }
    notifyListeners();
  }

  AssetStatus getAssetStatus(String assetNum) {
    if (parentAssets.contains(assetNum)) {
      return AssetStatus.parentAsset;
    }
    if (assets.containsKey(assetNum)) {
      return assets[assetNum]!;
    }
    return AssetStatus.incomplete;
  }

  void updateParentAssets(List<String> parentAssets) {
    this.parentAssets = parentAssets;
  }
}

enum AssetStatus {
  complete,
  parentAsset,
  refreshingWorkOrders,
  incomplete,
  refreshError,
}
