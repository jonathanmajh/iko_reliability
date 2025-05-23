import 'package:flutter/foundation.dart';
import 'package:trina_grid/trina_grid.dart';

import '../bin/db_drift.dart';

/// Notifier for managing and updating system criticality state.
class SystemCriticalityNotifier extends ChangeNotifier {
  bool updateGrid = false;
  TrinaGridStateManager? stateManager;
  String selectedSite = '';
  List<SystemCriticality> systems = [];

  void toggleUpdate() {
    updateGrid = true;
    notifyListeners();
  }
}
