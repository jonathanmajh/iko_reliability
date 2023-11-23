import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/main.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppFileOutput extends LogOutput {
  AppFileOutput();

  late File file;

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
    final appDir = await getApplicationDocumentsDirectory();
    final path = p.join(appDir.path, 'ReliabilityApp', 'iko_reliability.log');
    late File file = File(path);

    for (var line in event.lines) {
      await file.writeAsString("${line.toString()}\n",
          mode: FileMode.writeOnlyAppend);
      debugPrint(line); //print to console as well
    }
  }
}
