import 'package:flutter_application_1/admin/maximo_jp_pm.dart';
import 'package:flutter_application_1/admin/pm_jp_storage.dart';

import 'parse_template.dart';

const frequencyUnits = {'D': "Day", 'W': "Week", 'M': "Month", 'Y': "Year"};
const workType = {
  'PPM': 'Preventive Maintenance',
  'CAL': 'Calibration',
  'ENV': 'Environmental',
  'HKG': 'Housekeeping',
  'INR': 'Routine Inspection',
  // 'LC1': 'Life Cycle',
  'LUB': 'Lubrication',
  'PDM': 'Predictive Maintenance',
  'PEM': 'Pre-emptive Maintenance',
  'PRO': 'Process Maintenance',
  'SAF': 'Safety',
};

const crafts = {
  'E': 'Electrical',
  'M': 'Mechanical',
  'O': 'Production',
};

class PMName {
  String? pmNumber;
  String? pmName;
  String? jpNumber;
  List<String>? replaceable;

  PMName({this.pmNumber, this.pmName, this.jpNumber, this.replaceable});

  Future<PMName> generateName(PreventiveMaintenanceTemplate pmdetails,
      String maximoServerSelected) async {
    bool availablePM = false;
    bool availableJP = false;
    String number = '';
    String name = '';
    if (pmdetails.routeNumber != null) {
      number = pmdetails.routeNumber!;
      name = '[RouteName]';
    } else {
      number = getParent();
      name = "Site Operations"; // TODO look up asset description
    }
    final replaceable = [number, name];
    String wotype = pmdetails.workOrderType!.substring(0, 3);

// add frequency details if pm
    if (pmdetails.frequency != null) {
      number = '$number${pmdetails.frequencyUnit}${pmdetails.frequency}';
      if (wotype != 'LC1') {
        name =
            '$name - ${pmdetails.frequency} ${frequencyUnits[pmdetails.frequencyUnit]}';
      }
    }
// add work order type
    number = '$number$wotype';
    if (wotype != 'LC1') {
      name = '$name ${workType[wotype]}';
    } else {
      name = '$name - LC-';
      // properly assign letter after number has been determined
    }
    // add craft
    var craft = pmdetails.crafts[0].laborType;
    craft = craft.substring(craft.length - 1);
    number = '$number$craft';
    if (wotype != 'LC1') {
      name = '$name - ${crafts[craft]}';
    }
    availablePM =
        await checkPMNumber(number, pmdetails.siteId!, maximoServerSelected);
    availableJP = await checkJPNumber(
        '${pmdetails.siteId!}$number', maximoServerSelected);
    int counter = 0;
    String tempNumber = number;
    while (!availablePM && !availableJP) {
      counter++;
      if (wotype != 'LC1') {
        tempNumber = '$number$counter';
      } else {
        tempNumber =
            '${number.substring(0, number.length - 2)}${counter + 1}${number.substring(number.length - 1)}';
      }
      availablePM = await checkPMNumber(
          tempNumber, pmdetails.siteId!, maximoServerSelected);
      availableJP = await checkJPNumber(
          '${pmdetails.siteId!}$tempNumber', maximoServerSelected);
    }
    if (counter > 0) {
      if (wotype != 'LC1') {
        tempNumber = '$number$counter';
      } else {
        tempNumber =
            '${number.substring(0, number.length - 2)}${counter + 1}${number.substring(number.length - 1)}';
        name = '$name${numberToLetter(counter)}';
      }
    } else {}
    return PMName(
        pmNumber: tempNumber,
        pmName: name,
        jpNumber: '${pmdetails.siteId!}$tempNumber',
        replaceable: replaceable);
  }
}

String getParent() {
  return "A0001";
}

Future<bool> checkPMNumber(String number, String siteid, String env) async {
  // check to see if PM number is available, true if available
  var result = existPmNumberCache(number, siteid);
  if (result) {
    return false;
  }
  result = await existPmNumberMaximo(number, siteid, env);
  // check maximo async
  await Future.delayed(const Duration(seconds: 5));
  return true;
}

Future<bool> checkJPNumber(String number, String env) async {
  // check to see if PM number is available, true if available
  var result = existJpNumberCache(number);
  if (result) {
    return false;
  }
  result = await existJpNumberMaximo(number, env);
  // check maximo async
  await Future.delayed(const Duration(seconds: 5));
  return true;
}

String numberToLetter(int counter) {
  String letters = '';
  while (counter >= 0) {
    letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[counter % 26] + letters;
    counter = (counter / 26.0).floor() - 1;
  }
  return letters;
}
