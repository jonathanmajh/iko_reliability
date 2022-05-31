import 'dart:typed_data';

import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

const ignoreSheets = [
  'List of Assets',
  'Observation List',
  'Option List',
];

const siteIds = [];

const frequencyUnits = ['D', 'W', 'M', 'Y'];

// TODO way more consts for value checking

class JobCraft {
  final String laborType;
  final int quantity;
  final double hours;

  const JobCraft({
    required this.laborType,
    required this.quantity,
    required this.hours,
  });
}

class JobMaterial {
  final String itemNumber;
  final int quantity;
  final double cost;

  const JobMaterial({
    required this.itemNumber,
    required this.quantity,
    this.cost = 0.0,
  });
}

class JobService {
  final String itemNumber;
  final String vendorId;
  final double? cost;

  const JobService({
    required this.itemNumber,
    required this.vendorId,
    this.cost,
  });
}

class JobTask {
  final int jptask;
  final String description;
  final String assetNumber;
  final String? metername;
  final String? longdescription;

  const JobTask({
    required this.jptask,
    required this.description,
    required this.assetNumber,
    this.metername,
    this.longdescription,
  });
}

class PreventiveMaintenance {
  final List<String>? assets;
  final String? siteId;
  final String? frequencyUnit;
  final int? frequency;
  final String? workOrderType;
  final String? processCondition;
  final List<JobCraft>? crafts;
  final List<JobMaterial>? materials;
  final DateTime? nextDueDate;
  final String? pmNumber;
  final String? pmName;
  final String? pmPackageNumber;
  final String? routeNumber;

  const PreventiveMaintenance({
    this.assets,
    this.siteId,
    this.frequencyUnit,
    this.frequency,
    this.workOrderType,
    this.processCondition,
    this.crafts,
    this.materials,
    this.nextDueDate,
    this.pmNumber,
    this.pmName,
    this.pmPackageNumber,
    this.routeNumber,
  });

  factory PreventiveMaintenance.fromExcel(Uint8List bytes) {
    var decoder = SpreadsheetDecoder.decodeBytes(bytes);
    var pm_templates = {};
    var pm_number = 0;
    for (var sheet in decoder.tables.keys) {
      if (ignoreSheets.contains(sheet)) {
        continue; //ignore the non template sheets
      }
      for (var i = 0; i < decoder.tables[sheet]!.maxRows; i++) {
        var row = decoder.tables[sheet]!.rows[i];
        if (row[0] == "DON’T REMOVE THIS LINE") {
          continue;
        }
        if (row[0] == 'PM Asset/ Parent (Route)*:') {
          var row = decoder.tables[sheet]!.rows[i + 1];
          pm_number++;
          pm_templates[pm_number] = PreventiveMaintenance(
              nextDueDate: row[2],
              siteId: row[3],
              frequencyUnit: frequencyUnits.contains(row[4]) ? row[4] : null,
              frequency: row[5],
              workOrderType: row[6],
              processCondition: row[7]);
        }
      }
    }

    return PreventiveMaintenance(
        assets: ["assets"],
        siteId: "siteId",
        frequencyUnit: "frequencyUnit",
        frequency: 1,
        workOrderType: "workOrderType",
        processCondition: "processCondition",
        pmNumber: "pmNumber",
        pmName: "pmName");
  }
}
