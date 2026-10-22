import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/main.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// LogOutput implementation for writing logs to a file and showing error dialogs on Windows.
class AppFileOutput extends LogOutput {
  AppFileOutput();

  late File file;

  @override
  void output(OutputEvent event) async {
    // "Error" dialogs are reserved for real errors; info/notice level logs
    // only end up in the log file.
    if (event.level >= Level.error && navigatorKey.currentContext != null) {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(
              event.lines.toString().replaceAll(RegExp(r','), '\r\n'),
            ),
          );
        },
      );
    }
    final appDir = await getApplicationDocumentsDirectory();
    final path = p.join(appDir.path, 'ReliabilityApp', 'iko_reliability.log');
    late File file = File(path);

    for (var line in event.lines) {
      await file.writeAsString(
        "${line.toString()}\n",
        mode: FileMode.writeOnlyAppend,
      );
      debugPrint(line); //print to console as well
    }
  }
}
