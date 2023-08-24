import 'package:flutter/widgets.dart';

import '../main.dart';

class SystemsNotifier extends ChangeNotifier {
  Map<int, String> systems = {};

  void updateSystems() async {
    final allSystems = await database!.getSystemCriticalities();
    systems = {0: ''};
    for (var system in allSystems) {
      systems[system.id] = system.description;
    }
    notifyListeners();
  }
}

class RpnCriticalityNotifier extends ChangeNotifier {
  int targetVL = 30;
  int targetL = 25;
  int targetM = 20;
  int targetH = 15;

  int lowLowerLimit = 15;
  int mediumLowerLimit = 100;
  int highLowerLimit = 500;
  int veryHighLowerLimit = 1000;

  int getCriticality(double rpm) {
    if (rpm < lowLowerLimit) {
      return 1;
    }
    if (rpm < mediumLowerLimit) {
      return 3;
    }
    if (rpm < highLowerLimit) {
      return 5;
    }
    if (rpm < veryHighLowerLimit) {
      return 7;
    }
    return 9;
  }
}
