import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../main.dart';
import 'consts.dart';
import 'upload_maximo.dart';

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
// cache for assets for performance
// {siteid : {assetnum: Asset}}

void loadHierarchy() async {
  //deprecated
  debugPrint('Picking Files');
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
  debugPrint('Finished Loading');
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
  final box = Hive.box('assets');
  final asset = box.get('$siteid|$assetNum');
  if (asset == null) {
    throw Exception('Asset: $assetNum at site: $siteid cannot be found');
  }
  if (!assetCache.containsKey(siteid)) {
    assetCache[siteid] = {};
  }
  assetCache[siteid]![assetNum] = asset;

  return asset;
}

Future<String> getAssetMaximo(String siteid, String env) async {
  // maybe a return to indicate completion
  final result = await maximoRequest(
      'mxasset?oslc.where=siteid=%22$siteid%22&oslc.select=assetnum,siteid,description,parent',
      'get',
      env);
  final box = Hive.box('assets');
  if (result['rdfs:member'].length > 0) {
    // save once without the hierarchy field then loop through again adding hierarchy
    // because the parent assets might not always come before the child assets
    for (var row in result['rdfs:member'].toList()) {
      var asset = Asset(
        assetNumber: row['spi:assetnum'],
        name: row['spi:description'] ?? 'Asset has NO description in Maximo',
        parent: row['spi:parent'],
        siteid: row['spi:siteid'],
      );
      if (!assetCache.containsKey(asset.siteid)) {
        assetCache[asset.siteid] = {};
      }
      assetCache[asset.siteid]![asset.assetNumber] = asset;
      box.put('${asset.siteid}|${asset.assetNumber}', asset);
    }
    for (var row in result['rdfs:member'].toList()) {
      var asset = Asset(
        assetNumber: row['spi:assetnum'],
        name: row['spi:description'] ?? 'Asset has NO description in Maximo',
        parent: row['spi:parent'],
        siteid: row['spi:siteid'],
      );
      asset.hierarchy = findParent(asset);
      assetCache[asset.siteid]![asset.assetNumber] = asset;
      box.put('${asset.siteid}|${asset.assetNumber}', asset);
    }
  }
  return 'Complete';
}

Asset getCommonParent(List<String> assets, String siteID) {
  if (assets.length == 1) {
    return getAsset(siteID, assets[0]);
  }
  String commonHierarchy = getAsset(siteID, assets[0]).hierarchy!;
  for (String asset in assets) {
    var hierarchy = getAsset(siteID, asset).hierarchy!;
    int iterations = ','.allMatches(hierarchy).length;
    for (iterations; iterations >= 0; iterations--) {
      hierarchy = hierarchy.substring(0, iterations * 6 + 5);
      if (commonHierarchy.contains(hierarchy)) {
        commonHierarchy = hierarchy;
        break;
      }
    }
  }
  return getAsset(
      siteID, commonHierarchy.substring(commonHierarchy.length - 5));
}

void maximoAssetCaller(String siteid, BuildContext context) async {
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
      await getAssetMaximo(
          siteid,
          Provider.of<MaximoServerNotifier>(context, listen: false)
              .maximoServerSelected);
    } catch (e) {
      messages.add('Fail to update $siteid: ${e.toString()}');
      continue;
    }
    messages.add('Updated $siteid');
  }
  showDataAlert(messages, 'Site Assets Loaded');
}
