import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class ItemNotifier extends ChangeNotifier {
  Map<int, List<String>> results = {};
  int currentLevel = 0;
  List<String> allItems = [];
  Map<int, String> rankedItems = {};
  List<String> searchTerms = [];

  void newResults({
    required Map<int, List<String>> ranked,
    required List<String> searchTerm,
  }) {
    results = ranked;
    for (var item in ranked.entries) {
      allItems.addAll(item.value);
    }
    if (ranked.isEmpty) {
      currentLevel = -1;
    } else {
      currentLevel = ranked.keys.max;
    }
    searchTerms = searchTerm;
    notifyListeners();
  }

  List<String> getResults() {
    if (currentLevel == -1) {
      return [];
    }

    if (results.keys.contains(currentLevel)) {
      final temp = results[currentLevel];
      currentLevel -= 1;
      return temp!;
    } else {
      currentLevel -= 1;
      return getResults();
    }
  }
}
