import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import './connections/connection.dart' as impl;
import '../main.dart';
import 'consts.dart';
import 'upload_maximo.dart';

part 'db_drift.g.dart';

class Settings extends Table {
  // ENV_USERID,ENV_PASS,ENV_APIKEY
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
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
  List<Observation> observations;
  Meter(
    meter,
    inspect,
    description,
    frequency,
    freqUnit,
    condition,
    craft,
    this.observations,
  ) : super(
          meter: meter,
          inspect: inspect,
          description: description,
          frequency: frequency,
          freqUnit: freqUnit,
          condition: condition,
          craft: craft,
        );
}

class Assets extends Table {
  TextColumn get assetnum => text()();
  TextColumn get description => text()();
  TextColumn get status => text()();
  TextColumn get siteid => text()();
  TextColumn get changedate => text()();
  TextColumn get hierarchy => text().nullable()();
  TextColumn? get parent => text().nullable()();

  @override
  Set<Column> get primaryKey => {siteid, assetnum};
}

Map<String, Map<String, Asset>> assetCache = {};

@DriftDatabase(tables: [Settings, MeterDBs, Observations, Assets])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super.connect(impl.connect());

  MyDatabase.forTesting(DatabaseConnection connection)
      : super.connect(connection);
  // you should bump this number whenever you change or add a table definition.
  @override
  int get schemaVersion => 1;

  void clearMeters() {
    delete(meterDBs).go();
    delete(observations).go();
  }

  Future<void> addUpdateSettings(String key, String value) async {
    into(settings).insertOnConflictUpdate(Setting(key: key, value: value));
  }

  Future<Setting> getSettings(String key) async {
    final result = await (select(settings)..where((tbl) => tbl.key.equals(key)))
        .getSingleOrNull();
    if (result == null) {
      return Setting(key: key, value: '');
    }
    return result;
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

  Future getAssetMaximo(String siteid, String env) async {
    // maybe a return to indicate completion
    List<String> messages = [];
    final result = await maximoRequest(
        'mxasset?oslc.where=siteid=%22$siteid%22&oslc.select=assetnum,siteid,description,parent,status,changedate',
        'get',
        env);
    if (result['rdfs:member'].length > 0) {
      List<AssetsCompanion> assetInserts = [];
      // save once without the hierarchy field then loop through again adding hierarchy
      // because the parent assets might not always come before the child assets
      for (var row in result['rdfs:member'].toList()) {
        assetInserts.add(
          AssetsCompanion.insert(
            assetnum: row['spi:assetnum'],
            description:
                row['spi:description'] ?? 'Asset has NO description in Maximo',
            parent: Value(row['spi:parent']),
            siteid: row['spi:siteid'],
            status: row['spi:status'],
            changedate: row['spi:changedate'],
          ),
        );
      }
      try {
        await (delete(assets)..where((tbl) => tbl.siteid.equals(siteid))).go();
        await batch((batch) {
          batch.insertAll(assets, assetInserts);
        });
      } catch (e) {
        messages.add('Error inserting Meters\n${e.toString()}');
      }
      var siteAssets = await getSiteAssets(siteid);
      assetCache[siteid] = {};
      for (var a in siteAssets) {
        assetCache[a.siteid]![a.assetnum] = (await (update(assets)
              ..where((tbl) =>
                  tbl.assetnum.equals(a.assetnum) &
                  tbl.siteid.equals(a.siteid)))
            .writeReturning(AssetsCompanion(
          hierarchy: Value(await findParent(a)),
        )))[0];
      }
    }
  }

  Future<List<Asset>> getSiteAssets(String siteid) async {
    return (select(assets)..where((tbl) => tbl.siteid.equals(siteid))).get();
  }

  Future<Asset> getAsset(String siteid, String assetNum) async {
    var result = await (select(assets)
          ..where((t) => t.siteid.equals(siteid) & t.assetnum.equals(assetNum)))
        .getSingleOrNull();
    if (result == null) {
      throw Exception('Asset: "$assetNum" at site: "$siteid" does not exist');
    }
    var assetObj = result;
    if (!assetCache.containsKey(siteid)) {
      assetCache[siteid] = {};
    }
    assetCache[siteid]![assetNum] = assetObj;

    return assetObj;
  }
}

Future<String> findParent(Asset asset) async {
  if (asset.hierarchy != null) {
    return asset.hierarchy!;
  }
  if (asset.parent == null || asset.parent == 'NULL') {
    return asset.assetnum;
  }
  final parent = await getParent(asset);
  return '${await findParent(parent)},${asset.assetnum}';
}

Future<Asset> getParent(Asset asset) async {
  if (!assetCache.containsKey(asset.siteid)) {
    return await database!.getAsset(asset.siteid, asset.parent!);
  }
  final parent = assetCache[asset.siteid];
  if (!parent!.containsKey(asset.parent)) {
    return await database!.getAsset(asset.siteid, asset.parent!);
  }
  return parent[asset.parent]!;
}

String generateHierarchy(
    String assetnum, Map<String, Map<String, String?>> assets) {
  if (assets[assetnum]?['parent'] == null) {
    return assetnum;
  }
  return '${generateHierarchy(assets[assetnum]!['parent']!, assets)},$assetnum';
}

Future<Asset> getCommonParent(List<String> assets, String siteID) async {
  if (assets.length == 1) {
    return await database!.getAsset(siteID, assets[0]);
  }
  String commonHierarchy =
      (await database!.getAsset(siteID, assets[0])).hierarchy!;
  for (String asset in assets) {
    var hierarchy = (await database!.getAsset(siteID, asset)).hierarchy!;
    int iterations = ','.allMatches(hierarchy).length;
    for (iterations; iterations >= 0; iterations--) {
      hierarchy = hierarchy.substring(0, iterations * 6 + 5);
      if (commonHierarchy.contains(hierarchy)) {
        commonHierarchy = hierarchy;
        break;
      }
    }
  }
  return database!
      .getAsset(siteID, commonHierarchy.substring(commonHierarchy.length - 5));
}

void maximoAssetCaller(String siteid, String server) async {
  // some logic to update assets depending on what is selected
  List<String> siteids = [];
  List<String> messages = [];
  if (siteid == 'All') {
    siteids = siteIDAndDescription.keys.toList();
  } else if (siteid == '') {
    return;
  } else {
    siteids = [siteid];
  }
  for (final siteid in siteids) {
    try {
      await database!.getAssetMaximo(siteid, server);
    } catch (e) {
      messages.add('Fail to update $siteid: ${e.toString()}');
      continue;
    }
    messages.add('Updated $siteid');
  }
  showDataAlert(messages, 'Site Assets Loaded');
}
