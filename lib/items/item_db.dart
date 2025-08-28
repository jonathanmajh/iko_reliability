/// Drift database table and data model definitions for the application.
library;

import 'package:drift/drift.dart';
import '../admin/connections/connection.dart' as impl;

part 'item_db.g.dart';

class ItemCaches extends Table {
  TextColumn get itemnum => text()();
  TextColumn get description => text()();
  TextColumn get details => text()();
  TextColumn get changedDate => text()();
  TextColumn get searchText => text()();
  TextColumn get glClass => text()();
  TextColumn get uom => text()();
  TextColumn get commodityGroup => text()();
  TextColumn get extSearchText => text()();
  TextColumn get extDescription => text()();

  @override
  Set<Column> get primaryKey => {itemnum};
}

@DriftDatabase(
  tables: [
    ItemCaches,
  ],
)
class ItemDatabase extends _$ItemDatabase {
  ItemDatabase() : super(impl.connect(name: 'item'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
    );
  }

  Future<String> testCache() async {
    final row = (await (select(itemCaches)..limit(1)).get());
    return row.toString();
  }
}
