import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/admin/db_drift.dart';
import 'package:iko_reliability_flutter/criticality/functions.dart';
import 'package:iko_reliability_flutter/main.dart';

class Cache extends ChangeNotifier {
  ///for system criticality scores. key is the system id and value is the score
  Map<int, double> systemScores = {};

  ///null safe way to get system scores from map.
  ///Returns null if id is null
  double? getSystemScore(int? id) {
    return (id != null) ? systemScores[id] : null;
  }

  ///calulates the system scores from system_criticalitys of the database. Caches the scores into {systemScores}
  Future<Map<int, double>> calculateSystemScores() async {
    final dbrows = await database!.getSystemCriticalities();

    for (SystemCriticality row in dbrows) {
      systemScores[row.id] = systemScoreFunc(row.safety, row.regulatory,
          row.economic, row.throughput, row.quality);
    }
    return systemScores;
  }
}
