import 'dart:io';
import 'dart:async';
import 'package:iko_reliability_flutter/bin/fetch_remote_db.dart';
import 'package:intl/intl.dart';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
// import 'package:drift_dev/api/migrations.dart';
// import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<File> databaseFile({required String name}) async {
  // We use `path_provider` to find a suitable path to store our data in.
  final appDir = await getApplicationDocumentsDirectory();
  String dbPath = p.join(appDir.path, 'ReliabilityApp', name);
  dbPath = '$dbPath.db';
  final file = File(dbPath);
  // auto-backup function, runs every 10 minutes
  if (name == 'item') {
    if (!file.existsSync()) {
      // copy prepopulated database
      final bytes = await fetchAndUnzipDb(
          'https://raw.githubusercontent.com/jonathanmajh/iko_proxy/refs/heads/main/program.zip',
          'program.db');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
    }
  }
  if (name == 'reliability') {
    Timer.periodic(const Duration(minutes: 5), (arg) async {
      (File(dbPath)).copy(
          '$dbPath-${DateFormat('yyyyMMddHHmmSS').format(DateTime.now())}.db');
      // remove backups past 100
      final myDir = Directory(p.join(appDir.path, 'ReliabilityApp'));
      final files = myDir.listSync();
      if (files.length > 101) {
        files[1].delete();
      }
    });
  }
  return file;
}

/// Obtains a database connection for running drift in a Dart VM.
DatabaseConnection connect({required String name}) {
  return DatabaseConnection.delayed(Future(() async {
    return NativeDatabase.createBackgroundConnection(
        await databaseFile(name: name));
  }));
}

// Future<void> validateDatabaseSchema(GeneratedDatabase database) async {
//   // This method validates that the actual schema of the opened database matches
//   // the tables, views, triggers and indices for which drift_dev has generated
//   // code.
//   // Validating the database's schema after opening it is generally a good idea,
//   // since it allows us to get an early warning if we change a table definition
//   // without writing a schema migration for it.
//   //
//   // For details, see: https://drift.simonbinder.eu/docs/advanced-features/migrations/#verifying-a-database-schema-at-runtime
//   if (kDebugMode) {
//     await VerifySelf(database).validateDatabaseSchema();
//   }
// }
