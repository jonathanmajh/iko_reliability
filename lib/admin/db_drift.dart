import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'db_drift.g.dart';

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class Assets extends Table {
  TextColumn get assetnum => text()();
  TextColumn get description => text()();
  TextColumn get status => text()();
  TextColumn get siteid => text()();
  TextColumn get changedate => text()();
  TextColumn get hierarchy => text()();
  TextColumn? get parent => text().nullable()();

  @override
  Set<Column> get primaryKey => {siteid, assetnum};
}

class Observations extends Table {
  TextColumn get meter => text()();
  TextColumn get code => text()();
  TextColumn get description => text()();
  TextColumn get action => text().nullable()();

  @override
  Set<Column> get primaryKey => {meter, code};
}

class MeterDBs extends Table {
  TextColumn get meter => text()();
  TextColumn get inspect => text()();
  TextColumn get description => text()();
  IntColumn get frequency => integer()();
  TextColumn get freqUnit => text()();
  TextColumn get condition => text()();
  TextColumn get craft => text()();

  @override
  Set<Column> get primaryKey => {meter};
}

class Meter extends MeterDB {
  Meter(
      String meter,
      String inspect,
      String description,
      int frequency,
      String freqUnit,
      String condition,
      String craft,
      List<Observation> observations)
      : super(
          meter: meter,
          inspect: inspect,
          description: description,
          frequency: frequency,
          freqUnit: freqUnit,
          condition: condition,
          craft: craft,
        );
  List<Observation> observations = [];
}

@DriftDatabase(tables: [Settings, Assets, MeterDBs, Observations])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection());

  // you should bump this number whenever you change or add a table definition.
  @override
  int get schemaVersion => 1;

  Future<void> addAssets(Map<String, Map<String, String?>> assetList) async {
    List<AssetsCompanion> inserts = [];
    for (final asset in assetList.keys) {
      inserts.add(AssetsCompanion.insert(
        assetnum: asset,
        description: assetList[asset]!['description']!,
        status: assetList[asset]!['status']!,
        siteid: assetList[asset]!['siteid']!,
        changedate: assetList[asset]!['changedate']!,
        hierarchy: generateHierarchy(asset, assetList),
        parent: Value(assetList[asset]!['parent']),
      ));
    }
    await batch((batch) {
      batch.insertAll(assets, inserts);
    });
  }

  Future<List<Asset>> getChildAssets(String assetnum, String siteid) {
    return (select(assets)
          ..where((a) => a.parent.equals(assetnum) & a.siteid.equals(siteid)))
        .get();
  }

  Future<Meter> getMeter(String meterCode) async {
    var meterObj =
        await (select(meterDBs)..where((t) => t.meter.equals(meterCode))).get();
    var observation = await (select(observations)
          ..where((t) => t.meter.equals(meterCode)))
        .get();
    return Meter(
        meterObj[0].meter,
        meterObj[0].inspect,
        meterObj[0].description,
        meterObj[0].frequency,
        meterObj[0].freqUnit,
        meterObj[0].condition,
        meterObj[0].craft,
        observation);
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

String generateHierarchy(
    String assetnum, Map<String, Map<String, String?>> assets) {
  if (assets[assetnum]?['parent'] == null) {
    print('generated hierarchy for $assetnum');
    return assetnum;
  }
  return '${generateHierarchy(assets[assetnum]!['parent']!, assets)},$assetnum';
}
