import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppConsoleOutput extends LogOutput {
  AppConsoleOutput();

  @override
  void output(OutputEvent event) async {
    for (var line in event.lines) {
      debugPrint(line); //print to console as well
    }
  }
}
