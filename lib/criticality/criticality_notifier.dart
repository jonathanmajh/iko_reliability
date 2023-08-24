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
