import 'package:flutter/cupertino.dart';

/// Status of an extracted PM:
/// 'queued' -> 'fetching' (header lookup) -> 'extracting' (details) -> 'extracted'
/// terminal failure states: 'not found', 'error'
class ExtractStore {
  final String siteid;
  final String pmnum;
  String status;
  String errorMessage;
  Map<String, dynamic> pm; // raw iko_pm record from Maximo
  Map<String, dynamic>? jobplan; // raw iko_jobplan record
  List<dynamic> jobtasks = []; // nested iko_jobtask rows
  List<dynamic> joblabors = []; // nested iko_joblabor rows
  List<dynamic> jobmaterials = []; // nested iko_jobmaterial rows
  List<dynamic> jobservices = []; // nested iko_jobservice rows
  Map<String, dynamic>? route; // raw iko_route record
  List<dynamic> routeStops = []; // nested iko_route_stop rows

  ExtractStore({
    required this.siteid,
    required this.pmnum,
    this.status = 'queued',
    this.errorMessage = '',
    Map<String, dynamic>? pm,
  }) : pm = pm ?? {};

  String get key => '$siteid|$pmnum';

  String? get description => pm.containsKey('description')
      ? pm['description']?.toString()
      : null;
}

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
