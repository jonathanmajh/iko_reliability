//
//https://github.com/simolus3/drift/blob/develop/examples/app/lib/database/connection/web.dart
import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';
import 'package:iko_reliability_flutter/bin/fetch_remote_db.dart';

/// Obtains a database connection for running drift on the web.
DatabaseConnection connect({required String name}) {
  return DatabaseConnection.delayed(Future(() async {
    if (name == 'item') {
      // Import the database file into IndexedDB
      debugPrint('Importing remote DB');
      WasmDatabaseResult db = await WasmDatabase.open(
        databaseName: name,
        sqlite3Uri: Uri.parse('/flutter/sqlite3.wasm'),
        driftWorkerUri: Uri.parse('/flutter/drift_worker.js'),
        initializeDatabase: () async {
          return await fetchAndUnzipDb(
              'https://raw.githubusercontent.com/jonathanmajh/iko_proxy/refs/heads/main/program.zip',
              'program.db');
        },
      );
      debugPrint('Complete item DB');
      return db.resolvedExecutor;
    } else {
      WasmDatabaseResult db = await WasmDatabase.open(
        databaseName: name,
        sqlite3Uri: Uri.parse('/flutter/sqlite3.wasm'),
        driftWorkerUri: Uri.parse('/flutter/drift_worker.js'),
      );

      if (db.missingFeatures.isNotEmpty) {
        debugPrint('Using ${db.chosenImplementation} due to unsupported '
            'browser features: ${db.missingFeatures}');
      }
      return db.resolvedExecutor;
    }
  }));
}

Future<void> validateDatabaseSchema(GeneratedDatabase database) async {
  // Unfortunately, validating database schemas only works for native platforms
  // right now.
  // As we also have migration tests (see the `Testing migrations` section in
  // the readme of this example), this is not a huge issue.
}
