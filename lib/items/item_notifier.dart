import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class ItemNotifier extends ChangeNotifier {
  Map<int, List<String>> results = {};
  int currentLevel = 0;
  List<String> allItems = [];
  Map<int, String> rankedItems = {};

  void newResults(Map<int, List<String>> ranked) {
    results = ranked;
    for (var item in ranked.entries) {
      allItems.addAll(item.value);
    }
    currentLevel = ranked.keys.max;
    notifyListeners();
  }

  List<String> getResults() {
    if (currentLevel == -1) {
      return [];
    }
    if (results.keys.contains(currentLevel)) {
      return results[currentLevel]!;
    } else {
      currentLevel -= 1;
      return getResults();
    }
  }
}
