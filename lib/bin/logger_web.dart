import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../main.dart';

class AppConsoleOutput extends LogOutput {
  AppConsoleOutput();

  @override
  void output(OutputEvent event) async {
    if (navigatorKey.currentContext != null) {
      showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content:
                  Text(event.lines.toString().replaceAll(RegExp(r','), '\r\n')),
            );
          });
    }
    for (var line in event.lines) {
      debugPrint(line); //print to console as well
    }
  }
}
