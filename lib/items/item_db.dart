/// Drift database table and data model definitions for the application.
library;

import 'package:drift/drift.dart';
import '../admin/connections/connection.dart' as impl;

part 'item_db.g.dart';

class ItemCaches extends Table {
  TextColumn get itemnum => text()();
  TextColumn get description => text()();
  TextColumn get details => text().nullable()();
  TextColumn get changedDate => text().nullable()();
  TextColumn get searchText => text().nullable()();
  TextColumn get glClass => text().nullable()();
  TextColumn get uom => text().nullable()();
  TextColumn get commodityGroup => text().nullable()();
  TextColumn get extSearchText => text().nullable()();
  TextColumn get extDescription => text().nullable()();

  @override
  Set<Column> get primaryKey => {itemnum};
  @override
  String get tableName => 'itemCache';
}

class InventoryCaches extends Table {
  TextColumn get itemnum => text()();
  TextColumn get siteid => text()();
  TextColumn get catalogcode => text().nullable()();
  TextColumn get modelnum => text().nullable()();
  TextColumn get vendor => text().nullable()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get companyname => text().nullable()();
  TextColumn get rowstamp => text().nullable()();
  TextColumn get location => text()();
  TextColumn get binnum => text().nullable()();

  @override
  Set<Column> get primaryKey => {itemnum, location};
  @override
  String get tableName => 'inventoryCache';
}

class Manufacturers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fullName => text()();
  TextColumn get shortName => text()();
}

class Abbreviations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get origText => text()();
  TextColumn get replaceText => text()();
}

@DriftDatabase(
  tables: [
    ItemCaches,
    Manufacturers,
    Abbreviations,
  ],
  queries: {
    'findItems':
        '''select itemnum from itemCache where search_text like :search''',
    'findItemsExt':
        '''select itemnum from itemCache where ext_search_text like :search''',
    'getReplacements': '''SELECT upper(orig_text) orig_text
    , upper(replace_text) replace_text
FROM abbreviations
UNION
SELECT upper(full_name) orig_text
    , upper(short_name) replace_text
FROM manufacturers
''',
  },
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

  /// retrive lists of items with phrase in the description
  /// return map with the number of times each item appears across all lists
  Future<Map<int, List<String>>> rankResults(
      {required List<String> phrases, bool extended = false}) async {
    List<List<String>> results = [];
    Map<String, bool> allSet = {};
    // get results for each phrase
    for (String phrase in phrases) {
      var temp = extended
          ? await findItemsExt('%$phrase%').get()
          : await findItems('%$phrase%').get();
      results.add(temp);
      for (var item in temp) {
        allSet[item] = true;
      }
    }
    // rank results by number of appearances
    Map<int, List<String>> ranked = {};
    for (String item in allSet.keys) {
      int count = 0;
      for (var result in results) {
        if (result.contains(item)) {
          count += 1;
        }
      }
      if (ranked[count] == null) {
        ranked[count] = [];
      }
      ranked[count]!.add(item);
    }
    return ranked;
  }

  Future<Map<String, ItemCache>> getItemDetails(
      {required List<String> items}) async {
    final result =
        await (select(itemCaches)..where((a) => a.itemnum.isIn(items))).get();
    Map<String, ItemCache> details = {};
    for (var item in result) {
      details[item.itemnum] = item;
    }
    return details;
  }
}
