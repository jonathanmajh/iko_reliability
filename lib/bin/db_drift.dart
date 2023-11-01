//handling local database (drift)
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:http/http.dart' as http;
import 'package:iko_reliability_flutter/criticality/functions.dart';
import 'package:iko_reliability_flutter/settings/settings_notifier.dart';
import 'package:provider/provider.dart' as prov;
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import '../admin/connections/connection.dart' as impl;
import '../main.dart';
import 'consts.dart';
import '../admin/upload_maximo.dart';

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
  TextColumn get id => text()();
  IntColumn get newAsset => integer().withDefault(const Constant(0))();
  // 0 = existing asset
  //1 = new asset
  //-1 = asset that failed upload (e.g. location and asset were uploaded, but job plan failed)

  @override
  List<Set<Column>> get uniqueKeys => [
        {siteid, assetnum}
      ];

  @override
  Set<Column> get primaryKey => {id};
}

class AssetUploads extends Table {
  TextColumn get asset => text().references(Assets, #id)();
  TextColumn get sjpDescription => text().nullable()();
  TextColumn get installationDate => text().nullable()();
  TextColumn get vendor => text().nullable()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get modelNum => text().nullable()();
  IntColumn get assetCriticality => integer().nullable()();

  @override
  Set<Column> get primaryKey => {asset};
}

class AssetWithUpload {
  final Asset asset;
  final AssetUpload? uploads;
  AssetWithUpload(
    this.asset,
    this.uploads,
  );
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
  TextColumn get line => text()();
  RealColumn get score => real().withDefault(const Constant(0))();
}

class AssetCriticalitys extends Table {
  TextColumn get asset => text().references(Assets, #id)();
  IntColumn get system => integer().references(SystemCriticalitys, #id)();
  TextColumn get type => text()(); // production / non-production
  IntColumn get frequency => integer()();
  IntColumn get downtime => integer()();
  BoolColumn get manual => boolean().withDefault(const Constant(false))();
  IntColumn get newPriority => integer().nullable()();
  RealColumn get newRPN => real().withDefault(const Constant(0))();

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
    this.systemCriticality,
  );

  final Asset asset;
  final AssetCriticality? assetCriticality;
  final SystemCriticality? systemCriticality;
}

class SpareParts extends Table {
  TextColumn get itemnum => text()();
  TextColumn get assetnum => text()();
  TextColumn get siteid => text()();
  RealColumn get quantity => real()();
  IntColumn get sparepartid => integer()();

  @override
  Set<Column> get primaryKey => {sparepartid};
}

class Purchases extends Table {
  TextColumn get prnum => text()();
  TextColumn get prDescription => text()();
  TextColumn get poDescription => text()();
  TextColumn get ponum => text().nullable()();
  TextColumn get startDate => text()();
  TextColumn get siteid => text()();
  TextColumn get endDate => text().nullable()();
  RealColumn get leadTime => real()();
  TextColumn get itemnum => text()();
  RealColumn get unitCost => real()();
  BoolColumn get poStatus => boolean()();
  IntColumn get prlineid => integer()();

  @override
  Set<Column> get primaryKey => {prlineid};
}

class Items extends Table {
  TextColumn get itemnum => text()();
  TextColumn get description => text()();
  TextColumn get status => text()();
  TextColumn get commodityGroup => text()();
  TextColumn get glClass => text()();

  @override
  Set<Column> get primaryKey => {itemnum};
}

class SpareCriticalitys extends Table {
  TextColumn get id => text()();
  IntColumn get usage => integer()();
  IntColumn get leadTime => integer()();
  IntColumn get cost => integer()();
  RealColumn get assetRPN => real()();
  BoolColumn get manual => boolean()();
  IntColumn get newPriority => integer()();
  RealColumn get newRPN => real()();
  TextColumn get siteid => text()();
  TextColumn get itemnum => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class SpareCriticalityWithItem {
  SpareCriticalityWithItem(
    this.spareCriticality,
    this.item,
  );

  final SpareCriticality spareCriticality;
  final Item? item;
}

@DriftDatabase(
  tables: [
    Settings,
    LoginSettings,
    MeterDBs,
    Observations,
    Assets,
    Workorders,
    SystemCriticalitys,
    AssetCriticalitys,
    AssetUploads,
    SpareParts,
    Purchases,
    Items,
    SpareCriticalitys,
  ],
  queries: {
    'systemsFilteredBySite': '''
SELECT * FROM system_criticalitys
WHERE line IN (
		SELECT substr(assetnum, 1, 1)
		FROM assets
		WHERE siteid = :siteid
		)
''',
    'maxSystemID': '''
select max(id) from system_criticalitys
''',
    'uniqueRpnNumbers': '''
SELECT new_r_p_n
	,count(asset)
FROM asset_criticalitys
WHERE new_r_p_n > 0
	AND asset LIKE :siteid
GROUP BY new_r_p_n
''',
    'uniqueRpnNumbersSpare': '''
SELECT new_r_p_n
	,count(itemnum)
FROM spare_criticalitys
WHERE new_r_p_n > 0
	AND siteid = :siteid
GROUP BY new_r_p_n
''',
    'spareCriticalityAutoCalculation': '''
SELECT DISTINCT (sp.itemnum) itemnum
	,(
		SELECT sum(quantity)
		FROM spare_parts s1
		WHERE s1.itemnum = sp.itemnum
			AND s1.siteid = sp.siteid
		) quantity
	,(
		SELECT ifnull(avg(pr.unit_cost), -1)
		FROM purchases pr
		WHERE pr.itemnum = sp.itemnum
			AND pr.siteid = sp.siteid
			AND pr.po_status = 1
		) unitCost
	,(
		SELECT ifnull(avg(pr.lead_time), -1)
		FROM purchases pr
		WHERE pr.itemnum = sp.itemnum
			AND pr.siteid = sp.siteid
			AND pr.po_status = 1
		) leadTime
	,(
		SELECT max(new_r_p_n)
		FROM asset_criticalitys
		WHERE asset IN (
				SELECT sp.siteid || s2.assetnum
				FROM spare_parts s2
				WHERE s2.itemnum = sp.itemnum
					AND s2.siteid = sp.siteid
				)
		) assetRPN
FROM spare_parts sp
WHERE sp.siteid = :siteid
''',
    'spareCriticalityAutoCalculationItem': '''
SELECT DISTINCT (sp.itemnum) itemnum
	,(
		SELECT sum(quantity)
		FROM spare_parts s1
		WHERE s1.itemnum = sp.itemnum
			AND s1.siteid = sp.siteid
		) quantity
	,(
		SELECT ifnull(avg(pr.unit_cost), -1)
		FROM purchases pr
		WHERE pr.itemnum = sp.itemnum
			AND pr.siteid = sp.siteid
			AND pr.po_status = 1
		) unitCost
	,(
		SELECT ifnull(avg(pr.lead_time), -1)
		FROM purchases pr
		WHERE pr.itemnum = sp.itemnum
			AND pr.siteid = sp.siteid
			AND pr.po_status = 1
		) leadTime
	,(
		SELECT max(new_r_p_n)
		FROM asset_criticalitys
		WHERE asset IN (
				SELECT sp.siteid || s2.assetnum
				FROM spare_parts s2
				WHERE s2.itemnum = sp.itemnum
					AND s2.siteid = sp.siteid
				)
		) assetRPN
FROM spare_parts sp
WHERE sp.siteid = :siteid
AND sp.itemnum = :itemnum
''',
    'assetsAssociatedWithItem': '''
SELECT sp.assetnum
	,a.description
	,ac.new_r_p_n
	,sp.quantity
FROM spare_parts sp
LEFT JOIN assets a ON sp.assetnum = a.assetnum
	AND sp.siteid = a.siteid
LEFT JOIN asset_criticalitys ac ON sp.siteid || sp.assetnum = ac.asset
WHERE sp.siteid = :siteid
	AND sp.itemnum = :itemnum
'''
  },
)
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
  Future<void> setSettings(
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

  Future<int> addSystemCriticalitys(String description) async {
    final row = await into(systemCriticalitys)
        .insertReturning(SystemCriticalitysCompanion.insert(
      description: description,
      line: 'C',
    ));
    return row.id;
  }

  Future<void> importCriticality({
    required List<Setting> setting,
    required List<AssetCriticality> criticality,
    required List<SystemCriticality> system,
    required String siteid,
  }) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(settings, setting);
    });
    await (delete(systemCriticalitys)..where((t) => t.siteid.equals(siteid)))
        .go();
    await batch((batch) {
      batch.insertAll(systemCriticalitys, system);
    });
    await batch((batch) {
      batch.insertAllOnConflictUpdate(assetCriticalitys, criticality);
    });
  }

  Future<AssetWithUpload> addNewAsset(
    String assetnum,
    String siteid,
    String description,
    String parent,
    String? sjpDescription,
    String? installationDate,
    String? vendor,
    String? manufacturer,
    String? modelNum,
    int? assetCriticality,
  ) async {
    final parentAsset = await (select(assets)
          ..where((t) => t.assetnum.equals(parent))
          ..where((t) => t.siteid.equals(siteid)))
        .getSingle();
    final hierarchy = '${parentAsset.hierarchy},$assetnum';

    final row = await into(assets).insertReturning(AssetsCompanion.insert(
      description: description,
      hierarchy: Value(hierarchy),
      assetnum: assetnum,
      siteid: siteid,
      parent: Value(parent),
      priority: 0,
      status: 'Planning',
      changedate: 'N/A',
      newAsset: const Value(1),
      id: '$siteid$assetnum',
    ));

    final row2 =
        await into(assetUploads).insertReturning(AssetUploadsCompanion.insert(
      asset: '$siteid$assetnum',
      sjpDescription: Value(sjpDescription ?? description),
      installationDate: Value(installationDate),
      vendor: Value(vendor),
      manufacturer: Value(manufacturer),
      modelNum: Value(modelNum),
      assetCriticality: Value(assetCriticality),
    ));

    return AssetWithUpload(row, row2);
  }

  Future<String> deleteAsset(String assetNum, String siteId) async {
    final row = await (delete(assets)
          ..where((t) => t.assetnum.equals(assetNum))
          ..where((t) => t.siteid.equals(siteId)))
        .goAndReturn();
    return row.first.id;
  }

  ///0 = existing asset
  ///
  ///1 = new asset
  ///
  ///-1 = asset that failed upload (e.g. location and asset were uploaded, but job plan failed)
  Future<String> setAssetStatus(
      String assetNum, String siteId, int assetStatus) async {
    var res = await (update(assets)
          ..where((t) => t.siteid.equals(siteId) & t.assetnum.equals(assetNum)))
        .writeReturning(AssetsCompanion(newAsset: Value(assetStatus)));

    if (res.length > 1) {
      throw Exception(
          'More than one asset was updated, database is most likely corrupt');
    }

    return res[0].id;
  }

  Future<int> deleteSystemCriticalitys(int value) async {
    final row = await (delete(systemCriticalitys)
          ..where((t) => t.id.equals(value)))
        .goAndReturn();
    return row.first.id;
  }

  Future<int> updateSystemCriticalitys({
    required int key,
    required String description,
    required int safety,
    required int regulatory,
    required int economic,
    required int throughput,
    required int quality,
    required String line,
    required double score,
  }) async {
    final row = await (update(systemCriticalitys)
          ..where((tbl) => tbl.id.equals(key)))
        .writeReturning(SystemCriticalitysCompanion(
      description: Value(description),
      safety: Value(safety),
      regulatory: Value(regulatory),
      economic: Value(economic),
      throughput: Value(throughput),
      quality: Value(quality),
      line: Value(line),
      score: Value(sqrt((pow(safety, 2) +
              pow(regulatory, 2) +
              pow(economic, 2) +
              pow(throughput, 2) +
              pow(quality, 2)) /
          5)),
    ));
    return row.first.id;
  }

  Future<void> updateSpareCriticality({
    required String spareid,
    int? usage,
    int? leadTime,
    int? cost,
    int? newPriority,
    double? newRPN,
    bool? manual,
    double? assetRpn,
  }) async {
    await (update(spareCriticalitys)..where((tbl) => tbl.id.equals(spareid)))
        .writeReturning(SpareCriticalitysCompanion(
      usage: usage != null ? Value(usage) : const Value.absent(),
      leadTime: leadTime != null ? Value(leadTime) : const Value.absent(),
      cost: cost != null ? Value(cost) : const Value.absent(),
      newPriority:
          newPriority != null ? Value(newPriority) : const Value.absent(),
      newRPN: newRPN != null ? Value(newRPN) : const Value.absent(),
      manual: manual != null ? Value(manual) : const Value.absent(),
      assetRPN: assetRpn != null ? Value(assetRpn) : const Value.absent(),
    ));
  }

  Future<void> updateAssetCriticality({
    required String assetid,
    int? system,
    int? frequency,
    int? downtime,
    bool? manual,
    int? newPriority,
    double? newRPN,
  }) async {
    String type = 'type';
    await (into(assetCriticalitys)
        .insertOnConflictUpdate(AssetCriticalitysCompanion(
      asset: Value(assetid),
      system: system != null ? Value(system) : const Value.absent(),
      type: Value(type),
      frequency: frequency != null ? Value(frequency) : const Value.absent(),
      downtime: downtime != null ? Value(downtime) : const Value.absent(),
      manual: manual != null ? Value(manual) : const Value.absent(),
      newPriority:
          newPriority != null ? Value(newPriority) : const Value.absent(),
      newRPN: newRPN != null ? Value(newRPN) : const Value.absent(),
    )));
  }

  Future<void> removeAssetOverride({
    required String assetid,
  }) async {
    (update(assetCriticalitys)..where((tbl) => tbl.asset.equals(assetid)))
        .write(AssetCriticalitysCompanion(
      asset: Value(assetid),
      manual: const Value(false),
      newPriority: const Value(null),
      frequency: const Value(0),
      downtime: const Value(0),
    ));
  }

  Future<AssetCriticalityWithAsset> getAssetCriticality({
    required String assetid,
  }) async {
    var stuff = await (select(assets).join([
      leftOuterJoin(
          assetCriticalitys, assetCriticalitys.asset.equalsExp(assets.id)),
      leftOuterJoin(systemCriticalitys,
          systemCriticalitys.id.equalsExp(assetCriticalitys.system))
    ])
          ..where(assets.id.equals(assetid)))
        .getSingle();
    return AssetCriticalityWithAsset(
      stuff.readTable(assets),
      stuff.readTableOrNull(assetCriticalitys),
      stuff.readTableOrNull(systemCriticalitys),
    );
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
    http.Response response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/jonathanmajh/iko_reliability/master/lib/criticality/CriticalityData.xlsx'));
    final decoder = SpreadsheetDecoder.decodeBytes(response.bodyBytes);
    final sheet = decoder.tables.values.first;
    List<SystemCriticalitysCompanion> inserts = [];
    for (var i = 2; i < sheet.maxRows; i++) {
      var row = sheet.rows[i];
      if (row[1] != null) {
        inserts.add(
          SystemCriticalitysCompanion.insert(
              description: row[1],
              safety: Value(row[2]),
              regulatory: Value(row[3]),
              economic: Value(row[4]),
              throughput: Value(row[5]),
              quality: Value(row[6]),
              line: row[0],
              score: Value(sqrt((pow(row[2], 2) +
                      pow(row[3], 2) +
                      pow(row[4], 2) +
                      pow(row[5], 2) +
                      pow(row[6], 2)) /
                  5))),
        );
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
    final result = await maximoRequest(
        'iko_wo?oslc.select=wonum,siteid,description,status,reportdate,IKO_DOWNTIME,WORKTYPE,assetnum&oslc.where=assetnum="$assetnum" and IKO_DOWNTIME>0',
        'get',
        env);
    if (result['member'].length > 0) {
      List<WorkordersCompanion> woInserts = [];
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

      await batch((batch) {
        batch.insertAllOnConflictUpdate(workorders, woInserts);
      });
    }
  }

  Future<List<AssetCriticalityWithAsset>> getAssetCriticalities(
      String siteid) async {
    var stuff = await (select(assets).join([
      leftOuterJoin(
          assetCriticalitys, assetCriticalitys.asset.equalsExp(assets.id)),
      leftOuterJoin(systemCriticalitys,
          systemCriticalitys.id.equalsExp(assetCriticalitys.system))
    ])
          ..where(assets.siteid.equals(siteid)))
        .get();

    return stuff.map((row) {
      return AssetCriticalityWithAsset(
        row.readTable(assets),
        row.readTableOrNull(assetCriticalitys),
        row.readTableOrNull(systemCriticalitys),
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

  Future<List<SystemCriticality>> getSystemCriticalitiesFiltered(
      String siteid) async {
    var systems = await (select(systemCriticalitys)
          ..where((tbl) => tbl.siteid.equals(siteid)))
        .get();
    if (siteid == '') {
      return systems;
    }
    if (systems.isNotEmpty) {
      return systems;
    }
    systems = await systemsFilteredBySite(siteid).get();
    if (systems.isNotEmpty) {
      return systems;
    }
    // if there are no systems in DB load systems from Excel
    debugPrint('Loading all Systems');
    await loadSystems();
    systems = await systemsFilteredBySite(siteid).get();
    return systems;
  }

  Future<List<AssetCriticality>> getAllAssetCriticalities() async {
    var criticalities = await (select(assetCriticalitys)).get();
    return criticalities;
  }

  Future<List<SystemCriticality>> getSystemCriticality(int id) async {
    var systems =
        await (select(systemCriticalitys)..where((t) => t.id.equals(id))).get();
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
              id: '${row['siteid']}${row['assetnum']}'),
        );
      }
      try {
        await (delete(assets)..where((tbl) => tbl.siteid.equals(siteid))).go();
        await batch((batch) {
          batch.insertAllOnConflictUpdate(assets, assetInserts);
        });
      } catch (e) {
        messages.add('Error getting assets from Maximo\n${e.toString()}');
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

  Future<List<AssetWithUpload>> getSiteAssetUploads(String siteid) async {
    var result = await (select(assets).join([
      leftOuterJoin(assetUploads, assetUploads.asset.equalsExp(assets.id)),
    ])
          ..where(assets.siteid.equals(siteid)))
        .get();

    return result.map((row) {
      return AssetWithUpload(
        row.readTable(assets),
        row.readTableOrNull(assetUploads),
      );
    }).toList();
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

  Future<bool> checkSpareParts({required String siteid}) async {
    var result =
        await (select(spareParts)..where((t) => t.siteid.equals(siteid))).get();
    if (result.isEmpty) {
      return false;
    }
    var result2 =
        await (select(purchases)..where((t) => t.siteid.equals(siteid))).get();
    if (result2.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> getSparePartsMaximo(
      {required String siteid, required String env}) async {
    final url = 'IKO_API_ASSETSPAREPARTS?site=$siteid';
    final result = await maximoRequest(url, 'api', env);
    List<SparePartsCompanion> inserts = [];
    if (!result.containsKey('info')) {
      return;
    }
    for (final sparepart in result['info']) {
      inserts.add(SparePartsCompanion.insert(
        itemnum: sparepart['itemnum'],
        assetnum: sparepart['assetnum'],
        siteid: sparepart['siteid'],
        quantity: sparepart['quantity'] * 1.0,
        sparepartid: Value(sparepart['sparepartid']),
      ));
    }
    try {
      await batch((batch) {
        batch.insertAllOnConflictUpdate(spareParts, inserts);
      });
    } catch (e) {
      debugPrint('Error inserting System Criticality\n${e.toString()}');
    }
  }

  Future<void> getItemDetailsMaximo(
      {required String siteid, required String env}) async {
    final url = 'IKO_API_SITE_ITEMS?site=$siteid';
    final result = await maximoRequest(url, 'api', env);
    List<ItemsCompanion> inserts = [];
    if (!result.containsKey('info')) {
      return;
    }
    for (final item in result['info']) {
      inserts.add(ItemsCompanion.insert(
        description: item['description'] ?? '',
        glClass: item['glClass'] ?? '',
        commodityGroup: item['commodityGroup'] ?? '',
        status: item['status'] ?? '',
        itemnum: item['itemnum'],
      ));
    }
    try {
      await batch((batch) {
        batch.insertAllOnConflictUpdate(items, inserts);
      });
    } catch (e) {
      debugPrint('Error inserting Item Details\n${e.toString()}');
    }
  }

  Future<void> getPurchasesMaximo(
      {required String siteid, required String env}) async {
    final url = 'IKO_API_ITEMPURCHASES?site=$siteid';
    final result = await maximoRequest(url, 'api', env);
    List<PurchasesCompanion> inserts = [];
    if (!result.containsKey('info')) {
      return;
    }
    for (final purchase in result['info']) {
      final enterdate = DateTime.parse(purchase['enterdate']);
      final endDate = DateTime.tryParse(purchase['transdate'] ?? '');
      int leadTime = 0;
      if (endDate != null) {
        leadTime = endDate.difference(enterdate).inDays;
      }
      bool status = purchase['receiptscomplete'] == '1' ? true : false;
      if (leadTime == 0) {
        status = false;
      }
      if (purchase['currencyunitcost'] == null) {
        status = false;
      }
      inserts.add(PurchasesCompanion.insert(
        prnum: purchase['prnum'],
        prDescription: '',
        poDescription: '',
        ponum: Value(purchase['ponum']),
        startDate: purchase['enterdate'],
        siteid: purchase['siteid'],
        endDate: Value(purchase['transdate']),
        leadTime: leadTime.toDouble(),
        itemnum: purchase['itemnum'],
        unitCost: (purchase['currencyunitcost'] ?? 0) * 1.0,
        poStatus: status,
        prlineid: Value(purchase['prlineid']),
      ));
    }
    try {
      await batch((batch) {
        batch.insertAllOnConflictUpdate(purchases, inserts);
      });
    } catch (e) {
      debugPrint('Error inserting System Criticality\n${e.toString()}');
    }
  }

  Future<List<SpareCriticality>> updateSparePartCriticality(
      {required String siteid, required String itemnum}) async {
    final result =
        await spareCriticalityAutoCalculationItem(siteid, itemnum).getSingle();
    final temp = [
      ratingFromValue(result.quantity, usageRating),
      ratingFromValue(result.leadTime, leadTimeRating),
      ratingFromValue(result.unitCost, costRating),
    ];
    return await (update(spareCriticalitys)
          ..where((tbl) => tbl.id.equals('$siteid$itemnum')))
        .writeReturning(SpareCriticalitysCompanion(
      id: Value('$siteid$itemnum'),
      newPriority: const Value(0),
      usage: Value(temp[0]),
      leadTime: Value(temp[1]),
      cost: Value(temp[2]),
      newRPN: Value((result.assetRPN ?? 0) * temp[0] * temp[1] * temp[2]),
    ));
  }

  Future<void> computeSparePartCriticality({required String siteid}) async {
    final results = await spareCriticalityAutoCalculation(siteid).get();
    final skips = await (select(spareCriticalitys)
          ..where((tbl) =>
              tbl.manual.equals(true) | tbl.newPriority.isBiggerThanValue(0)))
        .get();
    final skip = skips.map((e) {
      return e.id;
    }).toList();
    List<SpareCriticalitysCompanion> results2 = [];
    for (var e in results) {
      final temp = [
        ratingFromValue(e.quantity, usageRating),
        ratingFromValue(e.leadTime, leadTimeRating),
        ratingFromValue(e.unitCost, costRating),
      ];
      if (!skip.contains('$siteid${e.itemnum}')) {
        results2.add(SpareCriticalitysCompanion.insert(
          id: '$siteid${e.itemnum}',
          usage: temp[0],
          leadTime: temp[1],
          cost: temp[2],
          assetRPN: e.assetRPN ?? 0,
          manual: false,
          newPriority: 0,
          newRPN: (e.assetRPN ?? 0) * temp[0] * temp[1] * temp[2],
          siteid: siteid,
          itemnum: e.itemnum,
        ));
      }
    }
    await batch((batch) {
      batch.insertAllOnConflictUpdate(spareCriticalitys, results2);
    });
    return;
  }

  Future<List<SpareCriticalityWithItem>> getSpareCriticalities(
      {required String siteid}) async {
    var criticalities = await (select(spareCriticalitys).join([
      leftOuterJoin(items, items.itemnum.equalsExp(spareCriticalitys.itemnum)),
    ])
          ..where(spareCriticalitys.siteid.equals(siteid)))
        .get();
    return criticalities.map((row) {
      return SpareCriticalityWithItem(
        row.readTable(spareCriticalitys),
        row.readTableOrNull(items),
      );
    }).toList();
  }

  Future<SpareCriticality> getSpareCriticality({required String id}) async {
    var criticalities = await (select(spareCriticalitys)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingle();
    return criticalities;
  }

  Future<void> removeSparePartOverride({
    required String spareid,
  }) async {
    (update(spareCriticalitys)..where((tbl) => tbl.id.equals(spareid)))
        .write(SpareCriticalitysCompanion(
      id: Value(spareid),
      manual: const Value(false),
      newPriority: const Value(0),
      usage: const Value(0),
      cost: const Value(0),
      leadTime: const Value(0),
    ));
  }

  Future<List<Purchase>> getItemPurchases(
      {required String itemnum, required String siteId}) async {
    var purchase = await (select(purchases)
          ..where((tbl) => tbl.itemnum.equals(itemnum))
          ..where((t) => t.siteid.equals(siteId)))
        .get();
    return purchase;
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
  prov.Provider.of<SettingsNotifier>(navigatorKey.currentContext!,
          listen: false)
      .addLoadedSites(loadedSiteIds);
  return messages;
}
