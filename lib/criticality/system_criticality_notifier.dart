import 'package:flutter/foundation.dart';
import 'package:trina_grid/trina_grid.dart';

import '../bin/db_drift.dart';

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
