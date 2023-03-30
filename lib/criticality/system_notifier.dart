import 'dart:math';

import 'package:flutter/widgets.dart';

import '../main.dart';

class SystemsNotifier extends ChangeNotifier {
  Map<int, Map<String, String>> systems = {};

  void updateSystems() async {
    final allSystems = await database!.getSystemCriticalities();
    systems = {
      0: {'description': '', 'score': ''}
    };
    for (var system in allSystems) {
      systems[system.id] = {
        'description': system.description,
        'score': sqrt((system.safety * system.safety +
                    system.regulatory * system.regulatory +
                    system.economic * system.economic +
                    system.throughput * system.throughput +
                    system.quality * system.quality) /
                5)
            .toStringAsFixed(2)
      };
    }
    // print(systems);
    notifyListeners();
  }
}
