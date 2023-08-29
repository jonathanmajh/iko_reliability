import 'dart:convert';

import 'package:flutter/services.dart';

import '../admin/db_drift.dart';

Future<String> exportCriticalityDB(
    MyDatabase database, String selectedSite) async {
  try {
    String export = '{"selectedSite":"$selectedSite"}';
    var data = await database.getSettings();
    for (Setting setting in data) {
      export = '$export\r\n${jsonEncode(setting)}';
    }
    var data2 = await database.getSystemCriticalitiesFiltered(selectedSite);
    for (SystemCriticality data in data2) {
      export =
          '$export\r\n${jsonEncode(data).replaceAll('"siteid":null', '"siteid":"$selectedSite"')}';
    }
    var data3 = await database.getAllAssetCriticalities();
    for (AssetCriticality data in data3) {
      if (data.asset.substring(0, selectedSite.length) == selectedSite) {
        export = '$export\r\n${jsonEncode(data)}';
      }
    }
    await Clipboard.setData(ClipboardData(text: export));
    return 'Data copied to clipboard';
  } catch (e) {
    return 'Failed to Export Data: ${e.toString()}';
  }
}

void importCriticalityDB(MyDatabase database) async {
  ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
  String? import = cdata!.text;
  List<String> lines = import!.split('\r\n');
  List<Setting> setting = [];
  List<AssetCriticality> criticality = [];
  List<SystemCriticality> system = [];
  for (String line in lines) {
    if (line.startsWith('{"key"')) {
      setting.add(Setting.fromJson(jsonDecode(line)));
    } else if (line.startsWith('{"id"')) {
      system.add(SystemCriticality.fromJson(jsonDecode(line)));
    } else {
      criticality.add(AssetCriticality.fromJson(jsonDecode(line)));
    }
  }
  database.importCriticality(
    setting,
    criticality,
    system,
  );
}
