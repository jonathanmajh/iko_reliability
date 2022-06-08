import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

part 'asset_storage.g.dart';

@HiveType(typeId: 1)
class Asset {
  @HiveField(0)
  String assetNumber;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? parent;

  @HiveField(3)
  String siteid;

  @HiveField(4)
  String? hierarchy;

  Asset({
    required this.assetNumber,
    this.hierarchy,
    required this.name,
    required this.parent,
    required this.siteid,
  });
}

Map<String, Map<String, Asset>> assetCache = {};
// {siteid : {assetnum: Asset}}

void loadHierarchy() async {
  print('Picking Files');
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(allowMultiple: false, withData: true);
  List<PlatformFile> files = [];
  if (result != null) {
    files = result.files.map((files) => (files)).toList();
    var decoder = SpreadsheetDecoder.decodeBytes(files.first.bytes!);
    var sheet = decoder.tables.values.first;
    final box = Hive.box('assets');
    await box.clear();
    for (var i = 1; i < sheet.maxRows; i++) {
      var row = sheet.rows[i];
      if (!assetCache.containsKey(row[3])) {
        assetCache[row[3]] = {};
      }
      var asset = Asset(
          assetNumber: row[0], name: row[2], parent: row[1], siteid: row[3]);
      asset.hierarchy = findParent(asset);
      assetCache[row[3]]![row[0]] = asset;
      box.put('${asset.siteid}|${asset.assetNumber}', asset);
    }
  }
  print('Finished Loading');
}

String findParent(Asset asset) {
  if (asset.hierarchy != null) {
    return asset.hierarchy!;
  }
  if (asset.parent == null || asset.parent == 'NULL') {
    return asset.assetNumber;
  }
  final parent = getParent(asset);
  return '${findParent(parent)},${asset.assetNumber}';
}

Asset getParent(Asset asset) {
  if (!assetCache.containsKey(asset.siteid)) {
    return getAsset(asset.siteid, asset.parent!);
  }
  final parent = assetCache[asset.siteid];
  if (!parent!.containsKey(asset.parent)) {
    return getAsset(asset.siteid, asset.parent!);
  }
  return parent[asset.parent]!;
}

Asset getAsset(String siteid, String assetNum) {
  // TODO get from Maximo after DB
  final box = Hive.box('assets');
  final asset = box.get('$siteid|$assetNum',
      defaultValue: Asset(
          assetNumber: assetNum,
          name: '$assetNum-Description',
          parent: null,
          siteid: siteid));
  if (!assetCache.containsKey(siteid)) {
    assetCache[siteid] = {};
  }
  assetCache[siteid]![assetNum] = asset;
  return asset;
}
