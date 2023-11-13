import 'package:flutter/foundation.dart';
import 'package:pluto_grid/pluto_grid.dart';

class SystemCriticalityNotifier extends ChangeNotifier {
  bool updateGrid = false;
  PlutoGridStateManager? stateManager;

  void toggleUpdate() {
    updateGrid = true;
    notifyListeners();
  }
}
