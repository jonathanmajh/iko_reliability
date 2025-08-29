//
//https://github.com/simolus3/drift/blob/develop/examples/app/lib/database/connection/web.dart
import 'dart:async';
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';
import 'package:iko_reliability_flutter/bin/fetch_remote_db.dart';

/// Obtains a database connection for running drift on the web.
DatabaseConnection connect({required String name}) {
  return DatabaseConnection.delayed(Future(() async {
    WasmDatabaseResult db = await WasmDatabase.open(
      databaseName: name,
      sqlite3Uri: Uri.parse('/sqlite3.wasm'),
      driftWorkerUri: Uri.parse('/drift_worker.js'),
    );

    if (db.missingFeatures.isNotEmpty) {
      debugPrint('Using ${db.chosenImplementation} due to unsupported '
          'browser features: ${db.missingFeatures}');
    }

    if (name == 'item') {
      debugPrint('Checking for local DB tables');
      // TODO checking of tables exist doesn't work
      // TODO also no results are returned even after db is imported
      // final executor = db.resolvedExecutor;
      // final result = await executor
      //     .runSelect('select description from itemCache limit 1;', []);
      // if (result.isEmpty) {
      //   // No tables found, so fetch and import the remote DB
      //   debugPrint('No local DB found, fetching remote DB');
      final dbBytes = await fetchAndUnzipDb(
          'https://raw.githubusercontent.com/jonathanmajh/iko_proxy/refs/heads/main/program.zip',
          'program.db');

      // Import the database file into IndexedDB
      debugPrint('Importing remote DB');
      db = await WasmDatabase.open(
        databaseName: name,
        sqlite3Uri: Uri.parse('/sqlite3.wasm'),
        driftWorkerUri: Uri.parse('/drift_worker.js'),
        initializeDatabase: () async {
          final data = dbBytes;
          return data.buffer.asUint8List();
        },
      );
      debugPrint('Complete item DB');
    }
    // }

    return db.resolvedExecutor;
  }));
}

Future<void> validateDatabaseSchema(GeneratedDatabase database) async {
  // Unfortunately, validating database schemas only works for native platforms
  // right now.
  // As we also have migration tests (see the `Testing migrations` section in
  // the readme of this example), this is not a huge issue.
}
