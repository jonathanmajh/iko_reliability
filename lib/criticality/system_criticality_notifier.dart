import 'package:flutter/foundation.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../bin/db_drift.dart';

class SystemCriticalityNotifier extends ChangeNotifier {
  bool updateGrid = false;
  PlutoGridStateManager? stateManager;
  String selectedSite = '';
  List<SystemCriticality> systems = [];

  void toggleUpdate() {
    updateGrid = true;
    notifyListeners();
  }
}
