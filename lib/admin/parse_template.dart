import 'dart:math';
import 'dart:typed_data';

import 'package:iko_reliability_flutter/bin/consts.dart';
import 'package:excel_plus/excel_plus.dart';

dynamic _excelCellValueToNative(CellValue? value) {
  if (value == null) return null;
  if (value is IntCellValue) return value.value;
  if (value is DoubleCellValue) return value.value;
  if (value is BoolCellValue) return value.value;
  if (value is DateCellValue) return value.asDateTimeUtc();
  if (value is FormulaCellValue) return value.cachedValue ?? value.formula;
  return value.toString();
}

dynamic _toNativeString(dynamic value) {
  return value?.toString();
}

double? _toNativeDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _toNativeInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString());
}

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
  final double quantity;
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
  final int? jptask;
  final String? description;
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
  String nextDueDate;
  String pmNumber;
  String pmName;
  String? pmPackageNumber;
  String? routeCode;
  String? routeName;
  String? pmAsset; // the parent asset specified for the PM
  String? suggestedPmNumber;
  String? suggestedPmName;
  String? replacement;

  ParsedTemplate({
    List<String>? assets,
    this.siteId,
    this.frequencyUnit,
    this.frequency,
    this.workOrderType,
    this.processCondition,
    List<JobCraft>? crafts,
    List<JobMaterial>? materials,
    required this.nextDueDate,
    required this.pmNumber,
    required this.pmName,
    this.pmPackageNumber,
    this.routeCode,
    this.routeName,
    this.replacement,
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

  Map<dynamic, dynamic> fromExcel(FileDetails stuff) {
    Uint8List bytes = stuff.bytes;
    String filename = stuff.name;
    var excel = Excel.decodeBytes(bytes); //Takes a LONG time
    var pmTemplates = {};
    var pmNumber = 0;
    var readTasks = false;
    var readCraft = false;
    var readMaterials = false;
    var readService = false;
    var readRouteAsset = false;
    var errors = [];
    pmTemplates[filename] = {};
    for (var sheetName in excel.tables.keys) {
      if (sheetName != 'Main') {
        continue; //ignore the non template sheets
      }
      final sheet = excel.tables[sheetName]!;
      for (var i = 0; i < sheet.maxRows; i++) {
        //read spreadsheet row by row
        try {
          var row = sheet
              .row(i)
              .map((cell) => _excelCellValueToNative(cell?.value))
              .toList();
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

            var nextRow = sheet
                .row(i + 1)
                .map((cell) => _excelCellValueToNative(cell?.value))
                .toList();
            var nextNextRow = sheet
                .row(i + 2)
                .map((cell) => _excelCellValueToNative(cell?.value))
                .toList();
            pmNumber++;
            //read work order type
            String workOrderType =
                _toNativeString(nextRow[6])?.substring(0, 3) ?? '';
            if (workOrderType == 'LC1') {
              workOrderType = 'LIF';
              //replace work order types of 'LC1' with 'LIF'
            }
            //read next due date for pm
            String nextDate = '';
            if (nextRow[2] != null) {
              if (nextRow[2] is String) {
                String temp = nextRow[2];
                nextDate = temp.substring(0, (min(10, temp.length)));
              } else if (nextRow[2] is DateTime) {
                nextDate = (nextRow[2] as DateTime)
                    .toUtc()
                    .toString()
                    .substring(0, 10);
              } else if (nextRow[2] is num) {
                nextDate = DateTime.fromMillisecondsSinceEpoch(
                        (((nextRow[2] as num) - 25569) * 86400000).toInt(),
                        isUtc: true)
                    .toString()
                    .substring(0, 10);
              }
            }
            //write to template object
            pmTemplates[filename][pmNumber] = ParsedTemplate(
              nextDueDate: nextDate,
              siteId: _toNativeString(nextRow[3])?.toUpperCase(),
              frequencyUnit:
                  _toNativeString(nextRow[4])?.substring(0, 1).toUpperCase(),
              frequency: _toNativeInt(nextRow[5]),
              workOrderType: workOrderType,
              processCondition: _toNativeString(nextRow[7])?.substring(0, 4),
              pmAsset: _toNativeString(nextRow[0])?.toUpperCase(),
              pmName: _toNativeString(nextRow[8]) ?? 'Generating Name...',
              pmNumber:
                  _toNativeString(nextNextRow[8]) ?? 'Generating Number...',
              suggestedPmName: _toNativeString(nextRow[8]),
              suggestedPmNumber: _toNativeString(nextNextRow[8]),
              routeName:
                  (_toNativeString(nextRow[9]) == 'Select Route (Optional)'
                      ? null
                      : _toNativeString(nextRow[9])),
              routeCode:
                  (_toNativeString(nextRow[9]) == 'Select Route (Optional)' ||
                          nextRow[9] == null
                      ? null
                      : _toNativeString(nextNextRow[9])),
            );
          }
          if (row[7] != null && readTasks) {
            //reading job task info of current PM, writing data to [ParsedTemplate] object(s)
            pmTemplates[filename][pmNumber].tasks.add(JobTask(
                jptask: _toNativeInt(row[6]),
                description: _toNativeString(row[7]),
                assetNumber: _toNativeString(row[4])?.toUpperCase(),
                metername: _toNativeString(row[5]),
                longdescription: _toNativeString(row[8])));
            if (row[4] != null) {
              pmTemplates[filename][pmNumber]
                  .assets
                  .add(_toNativeString(row[4])!);
            }
          }
          if (row[3] != null && readRouteAsset) {
            //reading task rout asset data of current PM and write it to [ParsedTemplate] object
            pmTemplates[filename][pmNumber]
                .assets
                .add(_toNativeString(row[3])!.toUpperCase());
          }
          if (row[0] == 'Materials (Mapics Number)') {
            //check if current row has materials/mapics # header for PM. If so, read the data next iteration(s)
            readCraft = false;
            readMaterials = true;
            readService = false;
            continue;
          }
          if (row[0] == 'Services (Mapics Number)') {
            //check if current row has services/mapics # header for PM. If so, read the data next iteration(s)
            readCraft = false;
            readMaterials = false;
            readService = true;
            continue;
          }
          if (row[1] != null && readCraft) {
            //read/write craft data
            //parse craft line
            String str = _toNativeString(row[0]) ?? '';
            String laborType = str.substring(0, 1).toUpperCase();
            // Patch for Production which is code O, but starts with P
            if (laborType == 'P') {
              laborType = 'O';
            }
            String laborCode = '';
            int pos = str.lastIndexOf('@');
            if (pos != -1) {
              //if @ symbol exists, might have labor code
              laborCode = str.substring(pos + 1).trim();
            }

            pmTemplates[filename][pmNumber].crafts.add(JobCraft(
                laborType: laborType,
                quantity: _toNativeInt(row[1]) ?? 0,
                hours: parseTime(row[2]),
                laborCode: laborCode));
          }
          if (row[0] != null && readMaterials) {
            //read/write material data
            pmTemplates[filename][pmNumber].materials.add(JobMaterial(
                itemNumber: _toNativeString(row[0]) ?? '',
                quantity: _toNativeDouble(row[1]) ?? 1.0,
                cost: _toNativeDouble(row[2])));
          }
          if (row[0] != null && readService) {
            //read/write service data
            pmTemplates[filename][pmNumber].services.add(JobService(
                itemNumber: _toNativeString(row[0]) ?? '',
                vendorId: _toNativeString(row[2]) ?? '',
                cost: _toNativeDouble(row[1])));
          }
          if (row[0] == 'Craft @ (Optional) Labour Code' ||
              row[0] == 'Craft (Labour Code(Optional))') {
            //check if current row has craft info header for PM. If so, read the data next iteration
            readTasks = true;
            readCraft = true;
            readMaterials = false;
            readService = false;
            pmTemplates[filename][pmNumber].replacement = row[3].toString();
            continue;
          }

          if (row[3] == 'Route Assets (one per cell):' ||
              row[3] == 'Task Route Assets (one per cell):') {
            //check if current row has task route asset header for PM. If so, read the data next iteration
            readRouteAsset = true;
          }
        } catch (e) {
          errors.add(
              'Error parsing PM Templates\nFile: $filename | Row: ${i + 1}\n$e');
        }
      }
    }
    if (pmTemplates.isEmpty) {
      throw NoPMException();
    }
    if (errors.isNotEmpty) {
      throw Exception(errors.toString());
    }
    return pmTemplates;
  }
}
