import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../bin/consts.dart';

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
  ///exclude -1 and 0 values from the rpnlist
  List<double> get rpnList =>
      List<double>.of(rpnMap.values.where((element) => element > 0));

  Map<double, int> frequencyOfRPNs() {
    Map<double, int> temp = {};
    for (var x in rpnList) {
      temp[x] = !temp.containsKey(x) ? (1) : (temp[x]! + 1);
    }
    return temp;
  }

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
  int rpnFindDistribution(double rpn) {
    try {
      if (rpnCutoffs.length != 5) {
        throw Exception('Unexpected format for List [rpnCutoffs]');
      }
      if (rpn <= 0) throw Exception('Negative RPN');
      for (int i = 0; i < assetCriticality.length; i++) {
        if (rpn <= rpnCutoffs[i]) return assetCriticality.keys.elementAt(i);
      }
      return assetCriticality.keys.last;
    } catch (e) {
      return 0;
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

class AssetOverrideNotifier extends ChangeNotifier {
  Map<String, AssetOverride> assets = {};

  void updateAssetOverride({
    required List<String> assets,
    required AssetOverride status,
  }) {
    for (var asset in assets) {
      this.assets[asset] = status;
    }
    notifyListeners();
  }

  AssetOverride getAssetStatus(String assetNum) {
    if (assets.containsKey(assetNum)) {
      return assets[assetNum]!;
    }
    return AssetOverride.none;
  }
}

enum AssetOverride {
  none, //lock open
  priority, //lock
  breakdowns, //lock clock
}
