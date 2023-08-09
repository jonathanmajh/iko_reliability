//handling local database (drift)

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' as material;
import 'package:iko_reliability_flutter/settings/settings_notifier.dart';
import 'package:provider/provider.dart' as prov;
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import './connections/connection.dart' as impl;
import '../main.dart';
import 'consts.dart';
import 'upload_maximo.dart';

part 'db_drift.g.dart';

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

///database table for login credentials
class LoginSettings extends Table {
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
  IntColumn get priority => integer()();
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get newAsset => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {siteid, assetnum}
      ];
}

class SystemCriticalitys extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text()();
  TextColumn get siteid => text().nullable()();
  IntColumn get safety => integer().withDefault(const Constant(0))();
  IntColumn get regulatory => integer().withDefault(const Constant(0))();
  IntColumn get economic => integer().withDefault(const Constant(0))();
  IntColumn get throughput => integer().withDefault(const Constant(0))();
  IntColumn get quality => integer().withDefault(const Constant(0))();
}

class AssetCriticalitys extends Table {
  IntColumn get asset => integer().references(Assets, #id)();
  IntColumn get system => integer().references(SystemCriticalitys, #id)();
  TextColumn get type => text()(); // production / non-production
  IntColumn get frequency => integer()();
  IntColumn get downtime => integer()();

  @override
  Set<Column> get primaryKey => {asset};
}

Map<String, Map<String, Asset>> assetCache = {};

class Workorders extends Table {
  TextColumn get wonum => text()();
  TextColumn get description => text()();
  TextColumn get status => text()();
  TextColumn get siteid => text()();
  TextColumn get reportdate => text()();
  RealColumn get downtime => real()();
  TextColumn get type => text()();
  TextColumn get assetnum => text()();

  @override
  Set<Column> get primaryKey => {siteid, wonum};
}

class AssetCriticalityWithAsset {
  AssetCriticalityWithAsset(
    this.asset,
    this.assetCriticality,
  );

  final Asset? asset;
  final AssetCriticality assetCriticality;
}

@DriftDatabase(tables: [
  Settings,
  LoginSettings,
  MeterDBs,
  Observations,
  Assets,
  Workorders,
  SystemCriticalitys,
  AssetCriticalitys,
])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(impl.connect());

  MyDatabase.forTesting(DatabaseConnection connection) : super(connection);
  // you should bump this number whenever you change or add a table definition.
  @override
  int get schemaVersion => 1;

  void clearMeters() {
    delete(meterDBs).go();
    delete(observations).go();
  }

  ///update settings in database. List of settings has priority
  Future<void> updateSettings(
      {Setting? newSetting, List<Setting>? newSettings}) async {
    if (newSettings != null) {
      for (Setting thing in newSettings) {
        await into(settings).insertOnConflictUpdate(thing);
      }
    } else if (newSetting != null) {
      await into(settings).insertOnConflictUpdate(newSetting);
    }
  }

  Future<void> addUpdateLoginSettings(
    String key,
    String value,
  ) async {
    await into(loginSettings).insertOnConflictUpdate(LoginSetting(
      key: key,
      value: value,
    ));
  }

  Future<int> addSystemCriticalitys(String value) async {
    final row = await into(systemCriticalitys).insertReturning(
        SystemCriticalitysCompanion.insert(description: value));
    return row.id;
  }

  Future<int> addNewAsset(
    String assetnum,
    String siteid,
    String description,
    String parent,
  ) async {
    final row = await into(assets).insertReturning(AssetsCompanion.insert(
      description: description,
      assetnum: assetnum,
      siteid: siteid,
      parent: Value(parent),
      priority: 0,
      status: 'Planning',
      changedate: 'N/A',
    ));
    return row.id;
  }

  Future<int> deleteSystemCriticalitys(int value) async {
    final row = await (delete(systemCriticalitys)
          ..where((t) => t.id.equals(value)))
        .goAndReturn();
    return row.first.id;
  }

  Future<int> updateSystemCriticalitys(
    int key,
    String description,
    int safety,
    int regulatory,
    int economic,
    int throughput,
    int quality,
  ) async {
    final row = await (update(systemCriticalitys)
          ..where((tbl) => tbl.id.equals(key)))
        .writeReturning(SystemCriticalitysCompanion(
      description: Value(description),
      safety: Value(safety),
      regulatory: Value(regulatory),
      economic: Value(economic),
      throughput: Value(throughput),
      quality: Value(quality),
    ));
    return row.first.id;
  }

  Future<void> updateAssetCriticality(
    int assetid,
    int system,
    int frequency,
    int downtime,
    String type,
  ) async {
    await (into(assetCriticalitys).insertOnConflictUpdate(AssetCriticality(
      asset: assetid,
      system: system,
      type: type,
      frequency: frequency,
      downtime: downtime,
    )));
  }

  Future<LoginSetting> getLoginSettings(String key) async {
    final result = await (select(loginSettings)
          ..where((tbl) => tbl.key.equals(key)))
        .getSingleOrNull();

    if (result == null) {
      return LoginSetting(
        key: key,
        value: '',
      );
    }
    return result;
  }

  Future<void> loadSystems() async {
    final bytes =
        File.fromUri(Uri.parse('lib/criticality/CriticalityData.xlsx'))
            .readAsBytesSync();
    final decoder = SpreadsheetDecoder.decodeBytes(bytes);
    final sheet = decoder.tables.values.first;
    List<SystemCriticalitysCompanion> inserts = [];
    for (var i = 2; i < sheet.maxRows; i++) {
      var row = sheet.rows[i];
      if (row[1] != null) {
        inserts.add(SystemCriticalitysCompanion.insert(
          description: row[1],
          safety: Value(row[2]),
          regulatory: Value(row[3]),
          economic: Value(row[4]),
          throughput: Value(row[5]),
          quality: Value(row[6]),
          siteid: Value(row[0]),
        ));
      }
    }
    try {
      await batch((batch) {
        batch.insertAll(systemCriticalitys, inserts);
      });
    } catch (e) {
      material
          .debugPrint('Error inserting System Criticality\n${e.toString()}');
    }
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
            condition: row[12].toString().trim(),
            description: row[4],
            freqUnit: row[10].substring(row[10].length - 1, 1),
            frequency: int.parse(row[10].substring(0, row[10].length - 1)),
            inspect: row[2].toString().trim(),
            meter: row[0].toString().trim(),
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

  Future<List<Setting>> getSettings() async {
    return await select(settings).get();
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

  Future getWorkOrderMaximo(String assetnum, String env) async {
    // maybe a return to indicate completion
    List<String> messages = [];
    final result = await maximoRequest(
        'iko_wo?oslc.select=wonum,siteid,description,status,reportdate,IKO_DOWNTIME,WORKTYPE,assetnum&oslc.where=assetnum="$assetnum" and IKO_DOWNTIME>0',
        'get',
        env);
    if (result['member'].length > 0) {
      List<WorkordersCompanion> woInserts = [];
      // save once without the hierarchy field then loop through again adding hierarchy
      // because the parent assets might not always come before the child assets
      for (var row in result['member'].toList()) {
        woInserts.add(
          WorkordersCompanion.insert(
            wonum: row['wonum'],
            description:
                row['description'] ?? 'WO has NO description in Maximo',
            downtime: row['iko_downtime'],
            siteid: row['siteid'],
            status: row['status'],
            type: row['worktype'],
            reportdate: row['reportdate'],
            assetnum: row['assetnum'],
          ),
        );
      }
      try {
        await batch((batch) {
          batch.insertAllOnConflictUpdate(workorders, woInserts);
        });
      } catch (e) {
        messages.add('Error inserting Meters\n${e.toString()}');
      }
    }
  }

  Future<List<AssetCriticalityWithAsset>> getAssetCriticalities() async {
    var stuff = await (select(assetCriticalitys).join([
      leftOuterJoin(assets, assets.id.equalsExp(assetCriticalitys.asset))
    ])).get();

    return stuff.map((row) {
      return AssetCriticalityWithAsset(
        row.readTableOrNull(assets),
        row.readTable(assetCriticalitys),
      );
    }).toList();
  }

  Future<List<SystemCriticality>> getSystemCriticalities() async {
    var systems = await (select(systemCriticalitys)).get();
    if (systems.isEmpty) {
      material.debugPrint('getting data from excel');
      await loadSystems();
      systems = await (select(systemCriticalitys)).get();
    }
    return systems;
  }

  Future<List<Workorder>> getAssetWorkorders(String assetnum,
      [String? siteid, String? date]) async {
    if (siteid == null) {
      if (date == null) {
        return await (select(workorders)
              ..where((t) => t.assetnum.equals(assetnum)))
            .get();
      } else {
        return await (select(workorders)
              ..where((t) =>
                  t.assetnum.equals(assetnum) &
                  t.reportdate.isBiggerThanValue(date)))
            .get();
      }
    } else {
      if (date == null) {
        return await (select(workorders)
              ..where(
                  (t) => t.assetnum.equals(assetnum) & t.siteid.equals(siteid)))
            .get();
      } else {
        return await (select(workorders)
              ..where((t) =>
                  t.assetnum.equals(assetnum) &
                  t.siteid.equals(siteid) &
                  t.reportdate.isBiggerThanValue(date)))
            .get();
      }
    }
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
          'No meter can be found for the following combination: "$meterName": "$condition": ${e.toString()}');
    }
  }

  Future getAssetMaximo(String siteid, String env) async {
    // maybe a return to indicate completion
    List<String> messages = [];
    final result = await maximoRequest(
        'mxasset?&oslc.where=siteid=%22$siteid%22 and ITEMNUM!="*" and status="OPERATING"&oslc.select=assetnum,siteid,description,parent,status,changedate,priority',
        'get',
        env);
    if (result['Error'] != null) {
      if (result['Error']['message'] != null) {
        throw Exception(result['Error']['message'].toString());
      }
      throw Exception('Failed to load assets from Maximo');
    }
    material.debugPrint(result['member'].length.toString());
    if (result['member'].length > 0) {
      List<AssetsCompanion> assetInserts = [];
      // save once without the hierarchy field then loop through again adding hierarchy
      // because the parent assets might not always come before the child assets
      for (var row in result['member'].toList()) {
        assetInserts.add(
          AssetsCompanion.insert(
            assetnum: row['assetnum'],
            description:
                row['description'] ?? 'Asset has NO description in Maximo',
            parent: Value(row['parent']),
            siteid: row['siteid'],
            status: row['status'],
            changedate: row['changedate'],
            priority: row['priority'] ?? 0,
          ),
        );
      }
      try {
        await (delete(assets)..where((tbl) => tbl.siteid.equals(siteid))).go();
        await batch((batch) {
          batch.insertAllOnConflictUpdate(assets, assetInserts);
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

Future<List<String>> maximoAssetCaller(
    String siteid, String server, material.BuildContext context) async {
  // some logic to update assets depending on what is selected

  List<String> siteids = [];
  List<String> messages = [];
  List<String> loadedSiteIds = [];
  if (siteid == 'All') {
    siteids = siteIDAndDescription.keys.toList();
  } else if (siteid == '') {
    return messages;
  } else {
    siteids = [siteid];
  }
  for (final siteid in siteids) {
    try {
      await database!.getAssetMaximo(siteid, server);
      loadedSiteIds.add(siteid);
    } catch (e) {
      messages.add('Failed to update $siteid: ${e.toString()}');
      continue;
    }
    messages.add('Updated $siteid');
  }
  prov.Provider.of<SettingsNotifier>(context, listen: false)
      .addLoadedSites(loadedSiteIds);
  return messages;
}
