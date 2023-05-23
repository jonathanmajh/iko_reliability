import 'dart:typed_data';

import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

const frequencyUnits = ['D', 'W', 'M', 'Y', 'J']; // J for job plan

double parseTime(dynamic text) {
  var hour = 0.0;
  if (text is String) {
    var temp = text.split(':');
    hour = double.parse(temp[0]);
    hour = hour + (double.parse(temp[1]) / 60.0);
  } else {
    hour = text * 1.0;
  }
  return hour;
}

class NoPMException implements Exception {
  String errMsg() => 'No PMs detected in the spreadsheet';
}

class JobCraft {
  final String laborType;
  final int quantity;
  final double hours;
  final String laborCode;

  const JobCraft({
    required this.laborType,
    required this.quantity,
    required this.hours,
    required this.laborCode,
  });
}

class JobMaterial {
  final String itemNumber;
  final int quantity;
  final double? cost;

  const JobMaterial({
    required this.itemNumber,
    required this.quantity,
    this.cost,
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
  final String? assetNumber;
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

class ProcessedTemplate {
  String? pmNumber;
  String? pmName;
  String? jpNumber;
  List<String>? replaceable;

  ProcessedTemplate({
    this.pmName,
    this.pmNumber,
    this.jpNumber,
    this.replaceable,
  });
}

class ParsedTemplate {
  List<String> assets;
  String? siteId;
  String? frequencyUnit;
  int? frequency;
  String? workOrderType;
  String? processCondition;
  List<JobCraft> crafts;
  List<JobMaterial> materials;
  List<JobService> services;
  List<JobTask> tasks;
  String? nextDueDate;
  String pmNumber;
  String pmName;
  String? pmPackageNumber;
  String? routeCode;
  String? routeName; // TODO replace this with loaded value list + editor later
  String? pmAsset; // the parent asset specified for the PM
  String? suggestedPmNumber;
  String? suggestedPmName;

  ParsedTemplate({
    List<String>? assets,
    this.siteId,
    this.frequencyUnit,
    this.frequency,
    this.workOrderType,
    this.processCondition,
    List<JobCraft>? crafts,
    List<JobMaterial>? materials,
    this.nextDueDate,
    required this.pmNumber,
    required this.pmName,
    this.pmPackageNumber,
    this.routeCode,
    this.routeName,
    this.suggestedPmName,
    this.pmAsset,
    this.suggestedPmNumber,
    List<JobService>? services,
    List<JobTask>? tasks,
  })  : assets = assets ?? [],
        crafts = crafts ?? [],
        materials = materials ?? [],
        services = services ?? [],
        tasks = tasks ?? [];

  Map<dynamic, dynamic> fromExcel(List<dynamic> stuff) {
    Uint8List bytes = stuff[0];
    String filename = stuff[1];
    var decoder = SpreadsheetDecoder.decodeBytes(bytes);
    var pmTemplates = {};
    var pmNumber = 0;
    var readTasks = false;
    var readCraft = false;
    var readMaterials = false;
    var readService = false;
    var readRouteAsset = false;
    pmTemplates[filename] = {};
    for (var sheet in decoder.tables.keys) {
      if (sheet != 'Main') {
        continue; //ignore the non template sheets
      }
      for (var i = 0; i < decoder.tables[sheet]!.maxRows; i++) {
        //read spreadsheet row by row
        var row = decoder.tables[sheet]!.rows[i];
        if (row[0] == "DON’T REMOVE THIS LINE") {
          continue;
        }
        if (row[0] == 'PM Asset/ Parent (Route)*:') {
          //new PM template header found on spreadsheet, read PM's values and write into new [ParsedTemplate] object
          //flags to read/write data of these category in the next loop iteration(s)
          readTasks = false;
          readCraft = false;
          readMaterials = false;
          readService = false;
          readRouteAsset = false;

          var nextRow = decoder.tables[sheet]!.rows[i + 1];
          var nextNextRow = decoder.tables[sheet]!.rows[i + 2];
          pmNumber++;
          //read work order type
          String workOrderType = nextRow[6].substring(0, 3);
          if (workOrderType == 'LC1') {
            workOrderType = 'LIF';
            //replace work order types of 'LC1' with 'LIF'
          }
          //read next due date for pm
          var nextDate;
          if (nextRow[2] != null) {
            if (nextRow[2] is String) {
              nextDate = nextRow[2].substring(0, 10);
            } else {
              nextDate = DateTime.fromMillisecondsSinceEpoch(
                      (nextRow[2] - 25569) * 86400000,
                      isUtc: true)
                  .toString()
                  .substring(0, 10);
            }
          }
          //write to template object
          pmTemplates[filename][pmNumber] = ParsedTemplate(
            nextDueDate: nextDate,
            siteId: nextRow[3].toString().toUpperCase(),
            frequencyUnit:
                nextRow[4]?.substring(0, 1)?.toString().toUpperCase(),
            frequency: nextRow[5],
            workOrderType: workOrderType,
            processCondition: nextRow[7].substring(0, 4),
            pmAsset: nextRow[0]?.toString().toUpperCase(),
            pmName: nextRow[8] ?? 'Generating Name...',
            pmNumber: nextNextRow[8] ?? 'Generating Number...',
            suggestedPmName: nextRow[8],
            suggestedPmNumber: nextNextRow[8],
            routeName:
                (nextRow[9] == 'Select Route (Optional)' ? null : nextRow[9]),
            routeCode: (nextRow[9] == 'Select Route (Optional)'
                ? null
                : nextNextRow[9]),
          );
        }
        if (row[7] != null && readTasks) {
          //reading job task info of current PM, writing data to [ParsedTemplate] object(s)
          pmTemplates[filename][pmNumber].tasks.add(JobTask(
              jptask: row[6], // TODO show error for missing jptask number
              description: row[7],
              assetNumber: row[4]?.toString().toUpperCase(),
              metername: row[5],
              longdescription: row[8]));
          if (row[4] != null) {
            pmTemplates[filename][pmNumber].assets.add(row[4]);
          }
        }
        if (row[3] != null && readRouteAsset) {
          //reading task rout asset data of current PM and write it to [ParsedTemplate] object
          pmTemplates[filename][pmNumber].assets.add(row[3]);
        }
        if (row[0] == 'Materials (Mapics Number)') {
          //check if current row has materials/mapics # header for PM. If so, read the data next iteration(s)
          readCraft = false;
          readMaterials = true;
          continue;
        }
        if (row[0] == 'Services (Mapics Number)') {
          //check if current row has services/mapics # header for PM. If so, read the data next iteration(s)
          readCraft = false;
          readService = true;
          continue;
        }
        if (row[1] != null && readCraft) {
          //read/write craft data
          //parse craft line
          String str = row[0];
          String laborType;
          String laborCode;
          int pos = str.lastIndexOf('@');
          if (pos != -1) {
            //if @ symbol exists, might have labor code
            laborType = str.substring(0, pos).trim();
            laborType = laborType.substring(laborType.length - 1);
            laborCode = str.substring(pos + 1).trim();
          } else {
            laborType = str.substring(str.length - 1);
            laborCode = '';
          }

          pmTemplates[filename][pmNumber].crafts.add(JobCraft(
              laborType: laborType,
              quantity: row[1],
              hours: parseTime(row[2]),
              laborCode: laborCode));
        }
        if (row[0] != null && readMaterials) {
          //read/write material data
          pmTemplates[filename][pmNumber].materials.add(JobMaterial(
              itemNumber: row[0].toString(),
              quantity: row[1] ?? 1,
              cost: row[2]?.toDouble()));
        }
        if (row[0] != null && readService) {
          //read/write service data
          pmTemplates[filename][pmNumber].services.add(JobService(
              itemNumber: row[0].toString(),
              vendorId: row[2],
              cost: row[1].toDouble()));
        }
        if (row[0] == 'Craft @ (Optional) Labour Code' ||
            row[0] == 'Craft (Labour Code(Optional))') {
          //check if current row has craft info header for PM. If so, read the data next iteration
          readTasks = true;
          readCraft = true;
          continue;
        }

        if (row[3] == 'Route Assets (one per cell):' ||
            row[3] == 'Task Route Assets (one per cell):') {
          //check if current row has task route asset header for PM. If so, read the data next iteration
          readRouteAsset = true;
        }
      }
    }
    if (pmTemplates.isEmpty) {
      throw NoPMException();
    }
    return pmTemplates;
  }
}
