import 'package:iko_reliability_flutter/admin/maximo_jp_pm.dart';
import 'package:iko_reliability_flutter/admin/pm_jp_storage.dart';

import '../main.dart';
import 'consts.dart';
import 'db_drift.dart';
import 'parse_template.dart';

///Object representing a PM
class PMName {
  String pmNumber;
  String pmName;
  String pmNameAuto;
  String pmNameSuggested;
  String jpNumber;
  String? routeNumber;
  String? routeName;
  String commonParent;
  List<String>? replaceable;

  PMName({
    required this.pmNumber,
    required this.pmName,
    required this.pmNameAuto,
    required this.pmNameSuggested,
    required this.jpNumber,
    this.routeNumber,
    this.routeName,
    required this.commonParent,
    this.replaceable,
  });
}

///Auto-generate name for PM
Future<PMName> generateName(
    ParsedTemplate pmdetails, String maximoServerSelected) async {
  String number = '';
  String name = '';
  String? routeNumber;
  String? routeName;
  Asset asset;
  String commonParent;
  if (pmdetails.assets.isEmpty) {
    asset = await database!.getAsset(pmdetails.siteId!, pmdetails.pmAsset!);
  } else {
    asset = await getCommonParent(pmdetails.assets, pmdetails.siteId!);
  }
  commonParent = asset.assetnum;
  if (pmdetails.routeCode != null && pmdetails.routeCode != "null") {
    // use route naming scheme if route code is specified
    number = await findAvailableRouteCode(
      pmdetails.routeCode!,
      pmdetails.siteId!,
      maximoServerSelected,
    );
    name =
        '${pmdetails.routeName} Route ${int.parse(number.substring(3))} - ${asset.description}';
    routeName = name;
    routeNumber = number;
  } else {
    number = asset.assetnum;
    name = asset.description;
  }
  var replaceable = ['XXXXX', 'XXXXX'];
  // number, name | XXXXX asset number, !!! duplicate counter
  String wotype = pmdetails.workOrderType!.substring(0, 3);

// add frequency details if pm
  if (pmdetails.frequency != null) {
    number = '$number${pmdetails.frequencyUnit}${pmdetails.frequency}';
    replaceable[0] =
        '${replaceable[0]}${pmdetails.frequencyUnit}${pmdetails.frequency}';
    if (wotype != 'LIF') {
      replaceable[1] =
          '${replaceable[1]} - ${pmdetails.frequency} ${freqUnitToString[pmdetails.frequencyUnit]}';
      name =
          '$name - ${pmdetails.frequency} ${freqUnitToString[pmdetails.frequencyUnit]}';
    }
  }
// add work order type
  if (wotype != 'LIF') {
    number = '$number$wotype';
    name = '$name - ${workType[wotype]}';
    replaceable[0] = '${replaceable[0]}$wotype';
    replaceable[1] = '${replaceable[1]} - ${workType[wotype]}';
  } else {
    number = '${number}LC1';
    name = '$name - LC-';
    replaceable[0] = '${replaceable[0]}LC!!!';
    replaceable[1] = '${replaceable[1]} - LC-!!!';
    // properly assign letter after number has been determined
    // TODO add the replaced component to the end of the name
  }
  // add craft
  var craft = pmdetails.crafts[0].laborType;
  craft = craft.substring(craft.length - 1);
  number = '$number$craft';
  replaceable[0] = '${replaceable[0]}$craft';
  if (wotype != 'LIF') {
    name = '$name - ${crafts[craft]}';
    replaceable[1] = '${replaceable[1]} - ${crafts[craft]}';
  }
  final counter = await findAvailablePMNumber(
      number, pmdetails.siteId!, maximoServerSelected, wotype, 3);
  if (counter > 0) {
    if (wotype != 'LIF') {
      number = '$number$counter';
    } else {
      number =
          '${number.substring(0, number.length - 2)}${counter + 1}${number.substring(number.length - 1)}';
      name = '$name${numberToLetter(counter)}';
    }
  } else {
    if (wotype == 'LIF') {
      name = '${name}A';
    }
  }

  //consider suggested PM name of null to be ''
  String pmNameSuggested = pmdetails.suggestedPmName ?? '';
  return PMName(
    pmNumber: number,
    pmName: name, //use auto-generated PM name by default
    pmNameAuto: name,
    pmNameSuggested: pmNameSuggested,
    jpNumber: '${pmdetails.siteId!}$number',
    replaceable: replaceable,
    commonParent: commonParent,
    routeName: routeName,
    routeNumber: routeNumber,
  );
}

Future<String> findAvailableRouteCode(
  String routeCode,
  String siteID,
  String server,
) async {
  int counter = 1;
  String routeNumber = '$routeCode${"$counter".padLeft(3, "0")}';
  bool unAvailable =
      await existRouteNumberMaximo(routeNumber, siteID, server) ||
          existRouteNumberCache(routeNumber, siteID);
  while (unAvailable) {
    counter++;
    routeNumber = '$routeCode${"$counter".padLeft(3, "0")}';
    unAvailable = await existRouteNumberMaximo(routeNumber, siteID, server) ||
        existRouteNumberCache(routeNumber, siteID);
  }
  return routeNumber;
}

// consider making recursive would probably be cleaner
Future<int> findAvailablePMNumber(
  String pmNumber,
  String siteID,
  String server,
  String woType,
  int checkType,
) async {
  // checkType 1 = PM + JP
  // checkType 2 = JP
  // checkType 3 = PM + JP + Route
  // assume type 2 by default
  bool existPM = false;
  bool existJP = false;
  bool existRoute = false;
  int counter = 0;
  if (checkType == 1) {
    existPM = existPmNumberCache(pmNumber, siteID);
  }
  existJP = existJpNumberCache('$siteID$pmNumber');
  if (checkType == 3) {
    existRoute = existRouteNumberCache(pmNumber, siteID);
    existPM = existPmNumberCache(pmNumber, siteID);
  }
  if (existRoute == false && existJP == false && existPM == false) {
    if (checkType == 1) {
      existPM = await existPmNumberMaximo(pmNumber, siteID, server);
    }
    existJP = await existJpNumberMaximo('$siteID$pmNumber', server);
    if (checkType == 3) {
      existRoute = await existRouteNumberMaximo(pmNumber, siteID, server);
      existPM = await existPmNumberMaximo(pmNumber, siteID, server);
    }
    if (existRoute == false && existJP == false && existPM == false) {
      return counter;
    }
  }
  String tempNumber = pmNumber;
  while (existPM || existJP || existRoute) {
    counter++;
    if (woType != 'LIF') {
      tempNumber = '$pmNumber$counter';
    } else {
      tempNumber =
          '${pmNumber.substring(0, pmNumber.length - 2)}${counter + 1}${pmNumber.substring(pmNumber.length - 1)}';
    }
    existJP = existJpNumberCache('$siteID$tempNumber');
    if (checkType == 1) {
      existPM = existPmNumberCache(tempNumber, siteID);
    }
    if (checkType == 3) {
      existRoute = existRouteNumberCache(tempNumber, siteID);
      existPM = existPmNumberCache(tempNumber, siteID);
    }
    if (existRoute == false && existJP == false && existPM == false) {
      existJP = await existJpNumberMaximo('$siteID$tempNumber', server);
      if (checkType == 1) {
        existPM = await existPmNumberMaximo(tempNumber, siteID, server);
      }
      if (checkType == 3) {
        existRoute = await existRouteNumberMaximo(tempNumber, siteID, server);
        existPM = await existPmNumberMaximo(tempNumber, siteID, server);
      }
    }
  }
  return counter;
}

///checks if a PM number is availiable in Maximo
Future<bool> checkPMNumber(String number, String siteid, String env) async {
  // check to see if PM number is available, true if available
  var result = existPmNumberCache(number, siteid);
  if (result) {
    return false;
  }
  result = await existPmNumberMaximo(number, siteid, env);
  // check maximo async
  return result;
}

///checks if a PM route number is available in Maximo
Future<bool> checkRouteNumber(String number, String siteid, String env) async {
  // check to see if PM number is available, true if available
  var result = existRouteNumberCache(number, siteid);
  if (result) {
    return false;
  }
  result = await existRouteNumberMaximo(number, siteid, env);
  // check maximo async
  return result;
}

///checks if a job plan PM number is available in Maximo
Future<bool> checkJPNumber(String number, String env) async {
  // check to see if PM number is available, true if available
  var result = existJpNumberCache(number);
  if (result) {
    return false;
  }
  result = await existJpNumberMaximo(number, env);
  // check maximo async
  return result;
}

///Creates a string of letters from an int
String numberToLetter(int counter) {
  String letters = '';
  while (counter >= 0) {
    letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[counter % 26] + letters;
    counter = (counter / 26.0).floor() - 1;
  }
  return letters;
}
