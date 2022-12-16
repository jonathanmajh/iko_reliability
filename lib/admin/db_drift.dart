import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../main.dart';

part 'db_drift.g.dart';

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// class Assets extends Table {
//   TextColumn get assetnum => text()();
//   TextColumn get description => text()();
//   TextColumn get status => text()();
//   TextColumn get siteid => text()();
//   TextColumn get changedate => text()();
//   TextColumn get hierarchy => text()();
//   TextColumn? get parent => text().nullable()();

//   @override
//   Set<Column> get primaryKey => {siteid, assetnum};
// }

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
  List<Observation> observations;
  Meter(meter, inspect, description, frequency, freqUnit, condition, craft,
      this.observations)
      : super(
          meter: meter,
          inspect: inspect,
          description: description,
          frequency: frequency,
          freqUnit: freqUnit,
          condition: condition,
          craft: craft,
        );
}

@DriftDatabase(tables: [Settings, MeterDBs, Observations])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection());

  // you should bump this number whenever you change or add a table definition.
  @override
  int get schemaVersion => 1;

  // Future<void> addAssets(Map<String, Map<String, String?>> assetList) async {
  //   List<AssetsCompanion> inserts = [];
  //   for (final asset in assetList.keys) {
  //     inserts.add(AssetsCompanion.insert(
  //       assetnum: asset,
  //       description: assetList[asset]!['description']!,
  //       status: assetList[asset]!['status']!,
  //       siteid: assetList[asset]!['siteid']!,
  //       changedate: assetList[asset]!['changedate']!,
  //       hierarchy: generateHierarchy(asset, assetList),
  //       parent: Value(assetList[asset]!['parent']),
  //     ));
  //   }
  //   await batch((batch) {
  //     batch.insertAll(assets, inserts);
  //   });
  // }

  // Future<List<Asset>> getChildAssets(String assetnum, String siteid) {
  //   return (select(assets)
  //         ..where((a) => a.parent.equals(assetnum) & a.siteid.equals(siteid)))
  //       .get();
  // }

  void clearMeters() {
    delete(meterDBs).go();
    delete(observations).go();
  }

  Future<void> addMeters() async {
    List<String> messages = [];
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: false, withData: true);
    List<PlatformFile> files = [];
    if (result == null) {
      return;
    }
    files = result.files.map((files) => (files)).toList();
    var decoder = SpreadsheetDecoder.decodeBytes(files.first.bytes!);
    var sheet = decoder.tables.values.first;
    List<MeterDBsCompanion> meterInserts = [];
    List<ObservationsCompanion> observationInserts = [];
    String meterCode = '';
    List<String> meterObservationUnique = [];
    for (var i = 1; i < sheet.maxRows; i++) {
      var row = sheet.rows[i];
      try {
        if (row[0] != null) {
          row[10] = row[10].toString().trim();
          meterCode = row[0];
          meterInserts.add(MeterDBsCompanion.insert(
            condition: row[12],
            description: row[4],
            freqUnit: row[10].substring(row[10].length - 1, 1),
            frequency: int.parse(row[10].substring(0, row[10].length - 1)),
            inspect: row[2],
            meter: row[0],
            craft: row[11].substring(0, 1),
          ));
        }
        if (row[5] != null) {
          observationInserts.add(
            ObservationsCompanion(
                code: Value(row[5]),
                description: Value(row[6]),
                action: Value(row[7]),
                meter: Value(meterCode)),
          );
          if (meterObservationUnique.contains('${row[5]}$meterCode')) {
            messages.add('${row[5]} : $meterCode already exists');
          }
          meterObservationUnique.add('${row[5]}$meterCode');
        }
      } catch (err) {
        messages.add('Row ${i + 1} is problematic\n$err');
      }
    }
    try {
      await batch((batch) {
        batch.insertAll(meterDBs, meterInserts);
      });
    } catch (e) {
      messages.add('Error inserting Meters\n${e.toString()}');
    }
    try {
      await batch((batch) {
        batch.insertAll(observations, observationInserts);
      });
    } catch (e) {
      messages.add('Error inserting Observations\n${e.toString()}');
    }
    messages.add('Finished Loading');
    showDataAlert(messages, 'Observation List Loaded');
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

  Future<Meter> getMeterByDescription(
      String meterName, String condition) async {
    try {
      var meterObj = await (select(meterDBs)
            ..where((t) =>
                t.inspect.equals(meterName) & t.condition.equals(condition)))
          .get();
      var observation = await (select(observations)
            ..where((t) => t.meter.equals(meterObj[0].meter)))
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
    } catch (e) {
      throw Exception(
          'No meter can be found for the following combination: $meterName : $condition : ${e.toString()}');
    }
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file, logStatements: true);
  });
}

String generateHierarchy(
    String assetnum, Map<String, Map<String, String?>> assets) {
  if (assets[assetnum]?['parent'] == null) {
    return assetnum;
  }
  return '${generateHierarchy(assets[assetnum]!['parent']!, assets)},$assetnum';
}
