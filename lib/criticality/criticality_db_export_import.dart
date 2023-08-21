import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';

import '../admin/db_drift.dart';

const SETTINGS = [
  'RPN percent very low',
  'RPN percent low',
  'RPN percent medium',
  'RPN percent high',
  'RPN percent very high',
  'before date',
  'after date',
];

void exportCriticalityDB(MyDatabase database) async {
  String export = '';
  var data = await database.getSettings();
  for (Setting setting in data) {
    if (SETTINGS.contains(setting.key)) {
      export = '$export\r\n${jsonEncode(setting)}';
    }
  }
  var data2 = await database.getSystemCriticalities();
  for (SystemCriticality data in data2) {
    export = '$export\r\n${jsonEncode(data)}';
  }
  var data3 = await database.getAllAssetCriticalities();
  for (AssetCriticality data in data3) {
    export = '$export\r\n${jsonEncode(data)}';
  }
  Clipboard.setData(ClipboardData(text: export)).then((_) {
    return;
  });
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
