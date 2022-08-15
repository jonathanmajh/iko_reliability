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
    if (wotype != 'LIF') {
      replaceable[1] =
          '${replaceable[1]} - ${pmdetails.frequency} ${freqUnitToString[pmdetails.frequencyUnit]}';
      name =
          '$name - ${pmdetails.frequency} ${freqUnitToString[pmdetails.frequencyUnit]} - ';
    }
  }
// add work order type
  if (wotype != 'LIF') {
    number = '$number$wotype';
    name = '$name ${workType[wotype]}';
    replaceable[0] = '${replaceable[0]}$wotype';
    replaceable[1] = '${replaceable[1]} ${workType[wotype]}';
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
    name = '${name}A';
  }
  return PMName(
    pmNumber: number,
    pmName: name,
    jpNumber: '${pmdetails.siteId!}$number',
    replaceable: replaceable,
    commonParent: commonParent,
  );
}

// consider making recursive would probably be cleaner
Future<int> findAvailablePMNumber(String pmNumber, String siteID, String server,
    String woType, int checkType) async {
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
