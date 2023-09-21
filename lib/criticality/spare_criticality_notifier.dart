import 'package:flutter/widgets.dart';

import 'asset_criticality_notifier.dart';

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
