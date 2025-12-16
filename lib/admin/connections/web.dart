//https://github.com/simolus3/drift/blob/develop/examples/app/lib/database/connection/web.dart
import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';
import 'package:iko_reliability_flutter/admin/connections/common.dart';
import 'package:iko_reliability_flutter/bin/fetch_remote_db.dart';

/// Obtains a database connection for running drift on the web.
DatabaseConnection connect({required String name}) {
  return DatabaseConnection.delayed(Future(() async {
    if (name == 'item') {
      // Import the database file into IndexedDB
      var serverVersion = await fetchRemoteVersion();
      debugPrint('Remote DB version: $serverVersion');

      var localVersion = await getDbVersion();
      debugPrint('Local DB version: $localVersion');

      if (localVersion != serverVersion) {
        debugPrint('Updating local version to $serverVersion');
        final probeResult = await WasmDatabase.probe(
            sqlite3Uri: Uri.parse('/flutter/sqlite3.wasm'),
            driftWorkerUri: Uri.parse('/flutter/drift_worker.js'),
            databaseName: name);
        for (var database in probeResult.existingDatabases) {
          if (database.$1 == WebStorageApi.indexedDb && database.$2 == name) {
            probeResult.deleteDatabase(database);
            break;
          }
        }
      } else {
        debugPrint('Local version is up to date');
      }

      WasmDatabaseResult db = await WasmDatabase.open(
        databaseName: name,
        sqlite3Uri: Uri.parse('/flutter/sqlite3.wasm'),
        driftWorkerUri: Uri.parse('/flutter/drift_worker.js'),
        initializeDatabase: () async {
          return await fetchAndUnzipDb(
              'https://iko-proxy.jonathanmajh.workers.dev/program.zip',
              'program.db');
        },
      );
      debugPrint('Complete item DB');
      await saveDbVersion(serverVersion);
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
