import 'package:flutter/cupertino.dart';

import 'extract_store.dart';

export 'extract_store.dart';

/// State for the PM Extract page, holds pairs entered by the user and the
/// data extracted from Maximo for each pair.
class ExtractNotifier extends ChangeNotifier {
  List<ExtractStore> extracts = [];
  String? selectedKey;
  bool fetching = false;

  /// Adds pairs to the extract list, skipping duplicates (by siteid|pmnum).
  void addPairs(List<ExtractStore> stores) {
    final keys = extracts.map((e) => e.key).toSet();
    for (final store in stores) {
      if (!keys.contains(store.key)) {
        extracts.add(store);
        keys.add(store.key);
      }
    }
    notifyListeners();
  }

  void removePair(String key) {
    extracts.removeWhere((e) => e.key == key);
    if (selectedKey == key) {
      selectedKey = null;
    }
    notifyListeners();
  }

  void clear() {
    extracts = [];
    selectedKey = null;
    fetching = false;
    notifyListeners();
  }

  void setSelected(String? key) {
    selectedKey = key;
    notifyListeners();
  }

  /// Moves the selection to the next extracted pair (arrow down).
  void selectNext() {
    if (extracts.isEmpty) {
      return;
    }
    if (selectedKey == null) {
      setSelected(extracts.first.key);
      return;
    }
    final index = extracts.indexWhere((e) => e.key == selectedKey);
    if (index == -1 || index == extracts.length - 1) {
      return;
    }
    setSelected(extracts[index + 1].key);
  }

  /// Moves the selection to the previous extracted pair (arrow up).
  void selectPrevious() {
    if (extracts.isEmpty) {
      return;
    }
    if (selectedKey == null) {
      setSelected(extracts.first.key);
      return;
    }
    final index = extracts.indexWhere((e) => e.key == selectedKey);
    if (index <= 0) {
      return;
    }
    setSelected(extracts[index - 1].key);
  }

  ExtractStore? getSelected() {
    if (selectedKey == null) {
      return null;
    }
    for (final store in extracts) {
      if (store.key == selectedKey) {
        return store;
      }
    }
    return null;
  }

  void setFetching(bool value) {
    fetching = value;
    notifyListeners();
  }

  /// Call after mutating a store in place to refresh listeners.
  void update() {
    notifyListeners();
  }
}
