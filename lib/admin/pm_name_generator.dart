import 'dart:developer';

import 'package:iko_reliability/admin/maximo_jp_pm.dart';
import 'package:iko_reliability/admin/pm_jp_storage.dart';

import 'asset_storage.dart';
import 'consts.dart';
import 'parse_template.dart';

class PMName {
  String pmNumber;
  String pmName;
  String jpNumber;
  String commonParent;
  List<String>? replaceable;

  PMName({
    required this.pmNumber,
    required this.pmName,
    required this.jpNumber,
    required this.commonParent,
    this.replaceable,
  });
}

Future<PMName> generateName(
    ParsedTemplate pmdetails, String maximoServerSelected) async {
  String number = '';
  String name = '';
  Asset asset;
  String commonParent;
  if (pmdetails.assets.isEmpty) {
    asset = getAsset(pmdetails.siteId!, pmdetails.pmAsset!);
  } else {
    asset = getCommonParent(pmdetails.assets, pmdetails.siteId!);
  }
  commonParent = asset.assetNumber;
  if (pmdetails.routeNumber != null) {
    number = pmdetails.routeNumber!;
    name = '[RouteName]';
    // TODO proper handling of route naming
  } else {
    number = asset.assetNumber;
    name = asset.name;
  }
  var replaceable = ['XXXXX', 'XXXXX'];
  // number, name | XXXXX asset number, !!! duplicate counter
  String wotype = pmdetails.workOrderType!.substring(0, 3);

// add frequency details if pm
  if (pmdetails.frequency != null) {
    number = '$number${pmdetails.frequencyUnit}${pmdetails.frequency}';
    replaceable[0] =
        '${replaceable[0]}${pmdetails.frequencyUnit}${pmdetails.frequency}';
    if (wotype != 'LC1') {
      replaceable[1] =
          '${replaceable[1]} - ${pmdetails.frequency} ${freqUnitToString[pmdetails.frequencyUnit]}';
      name =
          '$name - ${pmdetails.frequency} ${freqUnitToString[pmdetails.frequencyUnit]} - ';
    }
  }
// add work order type
  number = '$number$wotype';
  if (wotype != 'LC1') {
    name = '$name ${workType[wotype]}';
    replaceable[0] = '${replaceable[0]}$wotype';
    replaceable[1] = '${replaceable[1]} ${workType[wotype]}';
  } else {
    name = '$name - LC-';
    replaceable[0] = '${replaceable[0]}LC!!!';
    replaceable[1] = '${replaceable[1]} - LC-!!!';
    // properly assign letter after number has been determined
  }
  // add craft
  var craft = pmdetails.crafts[0].laborType;
  craft = craft.substring(craft.length - 1);
  number = '$number$craft';
  replaceable[0] = '${replaceable[0]}$craft';
  if (wotype != 'LC1') {
    name = '$name - ${crafts[craft]}';
    replaceable[1] = '${replaceable[1]} - ${crafts[craft]}';
  }
  final counter = await findAvailablePMNumber(
      number, pmdetails.siteId!, maximoServerSelected, wotype, 3);
  if (counter > 0) {
    if (wotype != 'LC1') {
      number = '$number$counter';
    } else {
      number =
          '${number.substring(0, number.length - 2)}${counter + 1}${number.substring(number.length - 1)}';
      name = '$name${numberToLetter(counter)}';
    }
  }
  return PMName(
    pmNumber: number,
    pmName: name,
    jpNumber: '${pmdetails.siteId!}$number',
    replaceable: replaceable,
    commonParent: commonParent,
  );
}

Future<int> findAvailablePMNumber(String pmNumber, String siteID, String server,
    String woType, int checkType) async {
  // checkType 1 = PM + JP
  // checkType 2 = JP
  // checkType 3 = PM + JP + Route
  // assume type 2 by default
  bool availablePM = true;
  bool availableJP = true;
  bool availableRoute = true;
  if (checkType == 1) {
    availablePM = await checkPMNumber(pmNumber, siteID, server);
  }
  availableJP = await checkJPNumber('$siteID$pmNumber', server);
  if (checkType == 3) {
    availableRoute = await checkRouteNumber(pmNumber, siteID, server);
    availablePM = await checkPMNumber(pmNumber, siteID, server);
  }
  int counter = 0;
  String tempNumber = pmNumber;
  while (!availablePM || !availableJP || !availableRoute) {
    counter++;
    if (woType != 'LC1') {
      tempNumber = '$pmNumber$counter';
    } else {
      tempNumber =
          '${pmNumber.substring(0, pmNumber.length - 2)}${counter + 1}${pmNumber.substring(pmNumber.length - 1)}';
    }
    availableJP = await checkJPNumber('$siteID$tempNumber', server);
    if (checkType == 1) {
      availablePM = await checkPMNumber(tempNumber, siteID, server);
    }
    if (checkType == 3) {
      availableRoute = await checkRouteNumber(tempNumber, siteID, server);
      availablePM = await checkPMNumber(tempNumber, siteID, server);
    }
  }
  return counter;
}

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

String numberToLetter(int counter) {
  String letters = '';
  while (counter >= 0) {
    letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[counter % 26] + letters;
    counter = (counter / 26.0).floor() - 1;
  }
  return letters;
}
