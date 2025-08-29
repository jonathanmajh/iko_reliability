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
  @override
  String get tableName => 'itemCache';
}

@DriftDatabase(
  tables: [
    ItemCaches,
  ],
  queries: {
    'findItems':
        '''select itemnum from itemCache where search_text like :search''',
    'findItemsExt':
        '''select itemnum from itemCache where ext_search_text like :search''',
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

  Future<String> testCache() async {
    final row = (await (select(itemCaches)..limit(1)).get());
    return row.toString();
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
