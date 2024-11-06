import 'package:iko_reliability_flutter/admin/maximo_jp_pm.dart';
import 'package:iko_reliability_flutter/admin/pm_jp_storage.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../bin/consts.dart';
import '../bin/db_drift.dart';
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
    replaceable[1] =
        '${replaceable[1]} - ${pmdetails.frequency} ${freqUnitToString[pmdetails.frequencyUnit]}';
    name =
        '$name - ${pmdetails.frequency} ${freqUnitToString[pmdetails.frequencyUnit]}';
  }
// add work order type
  if (wotype != 'LIF') {
    number = '$number$wotype';
    name = '$name - ${workType[wotype]}';
    replaceable[0] = '${replaceable[0]}$wotype';
    replaceable[1] = '${replaceable[1]} - ${workType[wotype]}';
  } else {
    number = '${number}LC|';
    name = '$name - LC-';
    replaceable[0] = '${replaceable[0]}LC|';
    replaceable[1] = '${replaceable[1]} - LC-|';
    // properly assign letter after number has been determined
    if (pmdetails.replacement != null) {
      replaceable[1] = '${replaceable[1]} ${pmdetails.replacement}';
    }
  }
  // add craft
  if (pmdetails.crafts.isEmpty) {
    throw Exception('No crafts selected for this template');
  }
  var craft = pmdetails.crafts[0].laborType;
  craft = craft.substring(craft.length - 1);
  if (wotype != 'LIF') {
    number = '$number$craft|||';
    replaceable[0] = '${replaceable[0]}$craft|||';
    name = '$name - ${crafts[craft]}';
    replaceable[1] = '${replaceable[1]} - ${crafts[craft]}';
  } else {
    number = '$number$craft';
    replaceable[0] = '${replaceable[0]}$craft';
    if (pmdetails.replacement != null) {
      name = '$name ${pmdetails.replacement}';
    }
  }
  final counter = await findAvailablePMNumber(
      number, pmdetails.siteId!, maximoServerSelected);
  NumberFormat formatter = NumberFormat("0" * '|'.allMatches(number).length);
  number = number.replaceAll(RegExp(r'\|+'), formatter.format(counter));

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
  // TODO move number generation into function, caller should give format of PM number, type (life cycle / other), siteid, server
  // check all PM, route, job plan by default
  String pmNumber,
  String siteID,
  String server,
) async {
  bool existPM = false;
  bool existJP = false;
  bool existRoute = false;
  int counter = 0;
  while (existPM || existJP || existRoute || counter == 0) {
    counter++;
    NumberFormat formatter =
        NumberFormat("0" * '|'.allMatches(pmNumber).length);
    var pmNumberTemp =
        pmNumber.replaceAll(RegExp(r'\|+'), formatter.format(counter));
    existPM = existPmNumberCache(pmNumberTemp, siteID);
    existJP = existJpNumberCache('$siteID$pmNumberTemp');
    existRoute = existRouteNumberCache(pmNumberTemp, siteID);
    if (existRoute == false && existJP == false && existPM == false) {
      existPM = await existPmNumberMaximo(pmNumberTemp, siteID, server);
      existJP = await existJpNumberMaximo('$siteID$pmNumberTemp', server);
      existRoute = await existRouteNumberMaximo(pmNumberTemp, siteID, server);
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
