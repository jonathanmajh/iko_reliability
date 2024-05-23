import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/widgets.dart';
import 'package:iko_reliability_flutter/bin/db_drift.dart';
import 'package:iko_reliability_flutter/admin/settings.dart';
import 'package:iko_reliability_flutter/admin/template_notifier.dart';
import 'package:iko_reliability_flutter/main.dart';
import '../creation/asset_creation_notifier.dart';
import '../bin/consts.dart';
import 'package:http/http.dart' as http;

Future<Map<String, List<List<String>>>> uploadPMToMaximo(
  String env,
  String file,
  int template,
  TemplateNotifier templates,
  UploadNotifier uploadNotifier,
) async {
  // +: uploaded; ~: already exist; !: error
  bool result;
  if (templates.getStatus(file, template) == 'error') {
    throw Exception(
        'Please fix errors in template before upload: $file: $template');
  }
  List<String> newJobPlans = [];
  var uploadData = uploadNotifier.getUploadDetails(file, template);
  templates.setStatus(file, template, 'uploading');
  uploadNotifier.setUploadDetails(file, template, uploadData);
  var stop = false;
  if (uploadData.containsKey('Asset')) {}
  if (uploadData.containsKey('Meter')) {
    for (int i = 0; i < uploadData['Meter']!.length; i++) {
      if (await isNewMeter(uploadData['Meter']![i][0], env)) {
        result = await uploadGeneric(
          uploadData['Meter']![i],
          env,
          'Meter',
          'iko_meter',
        );
        if (result) {
          uploadData['Meter']![i].add('+');
        } else {
          uploadData['Meter']![i].add('!');
          stop = true;
        }
      } else {
        uploadData['Meter']![i].add('~');
      }
      uploadNotifier.setUploadDetails(file, template, uploadData);
    }
    if (stop) {
      templates.addStatusMessage(file, template,
          'Please add missing Meter Domains, then retry upload again');
      templates.setStatus(file, template, 'retry');
      return uploadData;
    }
  }
  if (uploadData.containsKey('AssetMeter')) {
    // no checks, maximo will auto error out, can consider adding check for less errors
    for (int i = 0; i < uploadData['AssetMeter']!.length; i++) {
      result = await uploadGeneric(
        uploadData['AssetMeter']![i],
        env,
        'AssetMeter',
        'iko_assetmeter',
      );
      if (result) {
        uploadData['AssetMeter']![i].add('+');
      } else {
        uploadData['AssetMeter']![i].add('!');
      }
      uploadNotifier.setUploadDetails(file, template, uploadData);
    }
  }
  if (uploadData.containsKey('JobPlan')) {
    for (int i = 0; i < uploadData['JobPlan']!.length; i++) {
      if (uploadData['JobPlan']![i][10] == 'CBM') {
        if (!(await isNewJobPlan(uploadData['JobPlan']![i][2], env))) {
          uploadData['JobPlan']![i].add('~');
          continue;
        }
        // if the CBM job plan is new add it to list
        newJobPlans.add(uploadData['JobPlan']![i][2]);
      }
      result = await uploadGeneric(
        uploadData['JobPlan']![i],
        env,
        'JobPlan',
        'iko_jobplan',
      );
      if (result) {
        uploadData['JobPlan']![i].add('+');
      } else {
        uploadData['JobPlan']![i].add('!');
      }
      uploadNotifier.setUploadDetails(file, template, uploadData);
    }
  }
  if (uploadData.containsKey('MeasurePoint')) {
    for (int i = 0; i < uploadData['MeasurePoint']!.length; i++) {
      if (await isNewMeasurePoint(uploadData['MeasurePoint']![i][3],
          uploadData['MeasurePoint']![i][0], env)) {
        result = await uploadGeneric(
          uploadData['MeasurePoint']![i],
          env,
          'MeasurePoint',
          'iko_measurepoint',
        );
        if (result) {
          uploadData['MeasurePoint']![i].add('+');
        } else {
          uploadData['MeasurePoint']![i].add('!');
        }
      } else {
        uploadData['MeasurePoint']![i].add('~');
      }
      uploadNotifier.setUploadDetails(file, template, uploadData);
    }
  } // should cache
  if (uploadData.containsKey('MeasurePoint2')) {
    for (int i = 0; i < uploadData['MeasurePoint2']!.length; i++) {
      if (await isNewMeasurePoint2(uploadData['MeasurePoint2']![i][3],
          uploadData['MeasurePoint2']![i][0], env)) {
        result = await uploadGeneric(
          uploadData['MeasurePoint2']![i],
          env,
          'MeasurePoint2',
          'iko_measurepoint',
        );
        if (result) {
          uploadData['MeasurePoint2']![i].add('+');
        } else {
          uploadData['MeasurePoint2']![i].add('!');
        }
      } else {
        uploadData['MeasurePoint2']![i].add('~');
      }
      uploadNotifier.setUploadDetails(file, template, uploadData);
    }
  }
  if (uploadData.containsKey('Route')) {
    // no checks
    for (int i = 0; i < uploadData['Route']!.length; i++) {
      result = await uploadGeneric(
        uploadData['Route']![i],
        env,
        'Route',
        'iko_route',
      );
      if (result) {
        uploadData['Route']![i].add('+');
      } else {
        uploadData['Route']![i].add('!');
      }
      uploadNotifier.setUploadDetails(file, template, uploadData);
    }
  }
  if (uploadData.containsKey('Route_Stop')) {
    // no checks
    for (int i = 0; i < uploadData['Route_Stop']!.length; i++) {
      result = await uploadGeneric(
        uploadData['Route_Stop']![i],
        env,
        'Route_Stop',
        'iko_route_stop',
      );
      if (result) {
        uploadData['Route_Stop']![i].add('+');
      } else {
        uploadData['Route_Stop']![i].add('!');
      }
      uploadNotifier.setUploadDetails(file, template, uploadData);
    }
  }
  if (uploadData.containsKey('PM')) {
    // no checks
    for (int i = 0; i < uploadData['PM']!.length; i++) {
      result = await uploadGeneric(
        uploadData['PM']![i],
        env,
        'PM',
        'iko_pm',
      );
      if (result) {
        uploadData['PM']![i].add('+');
      } else {
        uploadData['PM']![i].add('!');
      }
      uploadNotifier.setUploadDetails(file, template, uploadData);
    }
  }
  if (uploadData.containsKey('JobLabor')) {
    for (int i = 0; i < uploadData['JobLabor']!.length; i++) {
      if (!(await isNewJobLabor(
        uploadData['JobLabor']![i][2], //jpnum
        uploadData['JobLabor']![i][7], //orgid
        uploadData['JobLabor']![i][4], //craft
        uploadData['JobLabor']![i][5], //hour
        env,
      ))) {
        uploadData['JobLabor']![i].add('~');
        continue;
      }
      result = await uploadGeneric(
        uploadData['JobLabor']![i],
        env,
        'JobLabor',
        'iko_joblabor',
      );
      if (result) {
        uploadData['JobLabor']![i].add('+');
      } else {
        uploadData['JobLabor']![i].add('!');
      }
      uploadNotifier.setUploadDetails(file, template, uploadData);
    }
  }
  if (uploadData.containsKey('JPASSETLINK')) {
    for (int i = 0; i < uploadData['JPASSETLINK']!.length; i++) {
      if (uploadData['JPASSETLINK']![i][2].contains('CBM') &&
          !(newJobPlans.contains(uploadData['JPASSETLINK']![i][2]))) {
        if (!(await isNewJobAsset(
          uploadData['JPASSETLINK']![i][2],
          uploadData['JPASSETLINK']![i][7],
          uploadData['JPASSETLINK']![i][4],
          env,
        ))) {
          uploadData['JPASSETLINK']![i].add('~');
          continue;
        }
      }
      result = await uploadGeneric(
        uploadData['JPASSETLINK']![i],
        env,
        'JPASSETLINK',
        'iko_jpassetlink',
      );
      if (result) {
        uploadData['JPASSETLINK']![i].add('+');
      } else {
        uploadData['JPASSETLINK']![i].add('!');
      }
      uploadNotifier.setUploadDetails(file, template, uploadData);
    }
  }
  if (uploadData.containsKey('JobTask')) {
    // no checks
    for (int i = 0; i < uploadData['JobTask']!.length; i++) {
      if (uploadData['JobTask']![i][2].contains('CBM') &&
          !(newJobPlans.contains(uploadData['JobTask']![i][2]))) {
        if (!(await isNewJobTask(
            uploadData['JobTask']![i][2], uploadData['JobTask']![i][4], env))) {
          uploadData['JobTask']![i].add('~');
          continue;
        }
      }
      result = await uploadGeneric(
        uploadData['JobTask']![i],
        env,
        'JobTask',
        'iko_jobtask',
      );
      if (result) {
        uploadData['JobTask']![i].add('+');
      } else {
        uploadData['JobTask']![i].add('!');
      }
      uploadNotifier.setUploadDetails(file, template, uploadData);
    }
  }
  if (uploadData.containsKey('JobMaterial')) {
    // no checks
    for (int i = 0; i < uploadData['JobMaterial']!.length; i++) {
      result = await uploadGeneric(
        uploadData['JobMaterial']![i],
        env,
        'JobMaterial',
        'iko_jobmaterial',
      );
      if (result) {
        uploadData['JobMaterial']![i].add('+');
      } else {
        uploadData['JobMaterial']![i].add('!');
      }
      uploadNotifier.setUploadDetails(file, template, uploadData);
    }
  }
  if (uploadData.containsKey('JobService')) {
    // no checks
    for (int i = 0; i < uploadData['JobService']!.length; i++) {
      result = await uploadGeneric(
        uploadData['JobService']![i],
        env,
        'JobService',
        'iko_jobservice',
      );
      if (result) {
        uploadData['JobService']![i].add('+');
      } else {
        uploadData['JobService']![i].add('!');
      }
      uploadNotifier.setUploadDetails(file, template, uploadData);
    }
  }
  templates.setStatus(file, template, 'done');
  return uploadData;
}

///Uploads assets to maximo.
///
///Order of upload: Location > Asset > JobPlan > JobLabor > JobAsset
///
///@returns Map<String, dynamic> with keys 'location', 'asset', 'jobplan', 'joblabor', 'jpassetlink'
///
///Possible statuses for each key: 'success', 'fail', 'duplicate'.
///In case of duplicate, the upload will continue
Future<Map<String, dynamic>> uploadAssetToMaximo(
  AssetWithUpload asset,
  String env,
  AssetCreationNotifier assetCreationNotifier,
  String selectedSite,
) async {
  const assetUrl = 'iko_asset?action=importfile';
  const locationUrl = 'iko_location?action=importfile';
  var headers = {
    "preview": "1",
  };
  Map<String, dynamic> result = {};
  int numDuplicates = 0;

  ///sets the value of the specified key to the result of the post request
  ///
  ///Since there is a map within the result map, mapLocation specifies which key you
  ///want to set the value of. For example, if you want to set the value of
  ///result['jobplan']['C01234TSH'], mapLocation should be ['jobplan', 'C01234TSH'].
  ///If you want to set the value of result['asset'], mapLocation should be
  ///['asset'].
  void handlePostResult(postResult, String object, List<String> mapLocation) {
    void setResultValue(value) {
      if (mapLocation.length == 1) {
        result[mapLocation[0]] = value;
      } else if (mapLocation.length == 2) {
        result[mapLocation[0]][mapLocation[1]] = value;
      } else {
        throw Exception('trying to set value of non-existent key in map');
      }
    }

    if (postResult['status'] == 'uploaded') {
      debugPrint('$object upload success');
      setResultValue('success');
    } else if (postResult['status'] == 'failed') {
      debugPrint('$object upload failed');
      setResultValue('fail');
      result['result'] = 'fail';
      result['failReason'] = 'Invalid Request';
      result['postResponse'] = postResult['body'];
      throw ['Invalid Request Body for ($object)', result];
    } else if (postResult['status'] == 'preview') {
      setResultValue('preview');
      result['result'] = 'preview';
      result['failReason'] = 'Preview mode on';
      result['postResponse'] = 'null';
      throw ['Preview mode on', result];
    } else {
      debugPrint('$object upload failed');
      setResultValue('fail');
      result['result'] = 'fail';
      result['failReason'] = 'An error has occured';
      result['postResponse'] = postResult['status'];
      throw ['An error has occured', result];
    }
  }

  debugPrint('checking if location exists');
  if (!(await isNewLocation('L-${asset.asset.assetnum}', selectedSite, env))) {
    debugPrint('location already exists');
    result['location'] = 'duplicate';
    numDuplicates++;
  } else {
    //upload location
    var locationResult = await maximoRequest(
        locationUrl,
        'post',
        env,
        const ListToCsvConverter().convert(
          [
            tableHeaders['Location']!,
            [
              selectedSite,
              'L-${asset.asset.assetnum}',
              asset.asset.description,
              'OPERATING',
              'GENERAL',
              'OPERATING',
              'L-${asset.asset.parent}'
            ]
          ],
        ),
        headers,
        false,
        false);
    handlePostResult(locationResult, 'location', ['location']);
  }

  debugPrint('checking if asset exists');
  // check if asset already exists
  if (!(await isNewAsset(asset.asset.assetnum, selectedSite, env))) {
    debugPrint('Asset already exists');
    result['asset'] = 'duplicate';
    numDuplicates++;
  } else {
    debugPrint('asset does not exist, uploading');
    var assetResult = await maximoRequest(
        assetUrl,
        'post',
        env,
        const ListToCsvConverter().convert([
          [
            'SITEID',
            'ASSETNUM',
            'DESCRIPTION',
            'LOCATION',
            'PARENT',
            'STATUS',
          ],
          [
            selectedSite,
            asset.asset.assetnum,
            asset.asset.description,
            'L-${asset.asset.assetnum}',
            asset.asset.parent,
            'OPERATING'
          ]
        ]),
        headers,
        false,
        false);
    handlePostResult(assetResult, 'asset', ['asset']);
    if (asset.uploads != null) {
      assetResult = await maximoRequest(
          assetUrl,
          'post',
          env,
          const ListToCsvConverter().convert([
            [
              'SITEID',
              'ASSETNUM',
              'INSTALLDATE',
              'PRIORITY',
              'VENDOR',
              'MANUFACTURER',
              // 'IKO_MODELNUM', TODO when DB field is added to Prod
            ],
            [
              selectedSite,
              asset.asset.assetnum,
              asset.uploads?.installationDate ?? '',
              asset.uploads?.assetCriticality ?? '',
              asset.uploads?.vendor ?? '',
              asset.uploads?.manufacturer ?? '',
              // asset.uploads?.modelNum ?? '',
            ]
          ]),
          headers,
          false,
          false);
      handlePostResult(assetResult, 'asset', ['asset']);
    }
  }

  List<String> jobPlanHeaders = [
    "JPNUM",
    "PLUSCREVNUM",
    "DESCRIPTION",
    "DESCRIPTION_LONGDESCRIPTION",
    "STATUS",
    "PERSONGROUP",
    "IKO_CONDITIONS",
    "PRIORITY",
    "IKO_WORKTYPE",
    "TEMPLATETYPE",
    "JPDURATION",
    "DOWNTIME",
    "INTERRUPTIBLE"
  ];
  result['jobplan'] = <String, String>{};
  for (var entry in assetWorkType.entries) {
    List<String> jobPlanBody = [];
    if (!(await isNewJobPlan('${asset.asset.assetnum}${entry.key}', env))) {
      debugPrint('${asset.asset.assetnum}${entry.key} jobplan exists');
      result['jobplan']['${asset.asset.assetnum}${entry.key}'] = 'duplicate';
      numDuplicates++;
      continue;
    }
    jobPlanBody = [
      '${asset.asset.assetnum}${entry.key}',
      '0',
      '${asset.uploads?.sjpDescription ?? asset.asset.description} - ${entry.value.description}',
      '',
      'ACTIVE',
      personGroups[entry.key[entry.key.length - 1]]!,
      '',
      entry.value.priority.toString(),
      entry.key.substring(0, 3),
      'STANDARD',
      '1',
      'N',
      'N',
    ];

    var jobPlanResult = await maximoRequest(
        'iko_jobplan?action=importfile',
        'post',
        env,
        const ListToCsvConverter().convert([jobPlanHeaders, jobPlanBody]),
        headers,
        false,
        false);

    handlePostResult(
        jobPlanResult,
        'jobplan ${asset.asset.assetnum}${entry.key}',
        ['jobplan', '${asset.asset.assetnum}${entry.key}']);
  }

  result['joblabor'] = <String, String>{};
  for (var entry in assetWorkType.entries) {
    if (!(await isNewJobLabor(
        '${asset.asset.assetnum}${entry.key}',
        siteIDAndOrgID[selectedSite]!,
        craftCode[entry.key[entry.key.length - 1]]!,
        "1",
        env))) {
      debugPrint('${asset.asset.assetnum}${entry.key} joblabor exists');
      result['joblabor']['${asset.asset.assetnum}${entry.key}'] = 'duplicate';
      numDuplicates++;
      continue;
    }

    List<String> jobPlanBody = [
      '',
      '',
      '${asset.asset.assetnum}${entry.key}',
      '0',
      craftCode[entry.key[entry.key.length - 1]]!,
      '1',
      '1',
      siteIDAndOrgID[selectedSite]!,
      ''
    ];

    var jobLaborResult = await maximoRequest(
        'iko_joblabor?action=importfile',
        'post',
        env,
        const ListToCsvConverter()
            .convert([tableHeaders['JobLabor'], jobPlanBody]),
        headers,
        false,
        false);
    handlePostResult(
        jobLaborResult,
        'joblabor ${asset.asset.assetnum}${entry.key}',
        ['joblabor', '${asset.asset.assetnum}${entry.key}']);
  }

  result['jpassetlink'] = <String, String>{};
  for (var entry in assetWorkType.entries) {
    if (!(await isNewJobAsset('${asset.asset.assetnum}${entry.key}',
        selectedSite, asset.asset.assetnum, env))) {
      debugPrint('${asset.asset.assetnum}${entry.key} jpasset exists');
      result['jpassetlink']['${asset.asset.assetnum}${entry.key}'] =
          'duplicate';
      numDuplicates++;
      continue;
    }

    List<String> jobPlanBody = [
      '',
      '',
      '${asset.asset.assetnum}${entry.key}',
      '0',
      asset.asset.assetnum,
      '0',
      siteIDAndOrgID[selectedSite]!,
      selectedSite,
    ];

    var jpassetlinkResult = await maximoRequest(
        'iko_jpassetlink?action=importfile',
        'post',
        env,
        const ListToCsvConverter()
            .convert([tableHeaders['JPASSETLINK'], jobPlanBody]),
        headers,
        false,
        false);
    handlePostResult(
        jpassetlinkResult,
        'jpassetlink ${asset.asset.assetnum}${entry.key}',
        ['jpassetlink', '${asset.asset.assetnum}${entry.key}']);
  }

  if (numDuplicates >= 56) {
    result['result'] = 'duplicate';
  } else if (result.keys.contains('duplicate')) {
    result['result'] = 'success';
    result['info'] =
        'Asset was partially uploaded before, updated all locations.';
  } else {
    result['result'] = 'success';
  }

  debugPrint(result.toString());
  return result;
}

Future<bool> isNewJobLabor(String jpNumber, String orgid, String craft,
    String hours, String maximoEnvironment) async {
  // do for all in case of retries
  final url =
      'iko_joblabor?oslc.select=jpnum&oslc.where=jpnum="$jpNumber" and joblabor.orgid="$orgid" and joblabor.craft="$craft" and joblabor.laborhrs="$hours"';
  final result = await maximoRequest(url, 'get', maximoEnvironment);
  if (result['status']! == 'empty') {
    return true;
  } else {
    return false;
  }
}

Future<bool> isNewJobTask(
    String jpNumber, String jptask, String maximoEnvironment) async {
  // is only needed for CBMs
  final url =
      'iko_jobtask?oslc.select=*&oslc.where=jpnum="$jpNumber" and jobtask.jptask="$jptask"';
  final result = await maximoRequest(url, 'get', maximoEnvironment);
  if (result['status']! == 'empty') {
    return true;
  } else {
    return false;
  }
}

Future<bool> isNewJobAsset(String jpNumber, String siteid, String assetnum,
    String maximoEnvironment) async {
  // is only needed for CBMs
  final url =
      'iko_jpassetlink?oslc.select=*&oslc.where=jpnum="$jpNumber" and JPASSETSPLINK.siteid="$siteid" and JPASSETSPLINK.assetnum="$assetnum"';
  final result = await maximoRequest(url, 'get', maximoEnvironment);
  if (result['status']! == 'empty') {
    return true;
  } else {
    return false;
  }
}

Future<bool> isNewJobPlan(String jpNumber, String maximoEnvironment) async {
  // is only needed for CBMs
  final url = 'iko_jobplan?oslc.select=jpnum&oslc.where=jpnum="$jpNumber"';
  final result = await maximoRequest(url, 'get', maximoEnvironment);
  if (result['status']! == 'empty') {
    return true;
  } else {
    return false;
  }
}

Future<bool> isNewMeasurePoint(
    String measurePoint, String siteid, String maximoEnvironment) async {
  final url =
      'iko_measurepoint?oslc.select=pointnum&oslc.where=pointnum="$measurePoint" and siteid="$siteid"';
  final result = await maximoRequest(url, 'get', maximoEnvironment);
  if (result['status']! == 'empty') {
    return true;
  } else {
    return false;
  }
}

Future<bool> isNewMeasurePoint2(
    String jpnum, String siteid, String maximoEnvironment) async {
  final url =
      'iko_measurepoint?oslc.select=charpointaction&oslc.where=charpointaction.jpnum="$jpnum" and siteid="$siteid"';
  final result = await maximoRequest(url, 'get', maximoEnvironment);
  if (result['status']! == 'empty') {
    return true;
  } else {
    return false;
  }
}

Future<bool> isNewMeter(String meterName, String maximoEnvironment) async {
  final url =
      'iko_meter?oslc.select=metername&oslc.where=metername="$meterName"';
  final result = await maximoRequest(url, 'get', maximoEnvironment);
  if (result['status']! == 'empty') {
    return true;
  } else {
    return false;
  }
}

Future<bool> isNewLocation(
    String location, String siteId, String maximoEnvironment) async {
  final url =
      'iko_location?oslc.where=siteid="$siteId" and location="$location"&oslc.select=location,siteid';
  final result = await maximoRequest(url, 'get', maximoEnvironment);

  debugPrint(result.toString());

  if (result["member"] == null) {
    throw Exception('Invalid Response from Maximo');
  }

  if (result['status']! == 'empty') {
    debugPrint('not new location');
    return true;
  } else {
    return false;
  }
}

Future<bool> isNewAsset(
    String assetNum, String siteId, String maximoEnvironment) async {
  final url =
      'iko_asset?oslc.where=siteid="$siteId" and assetnum="$assetNum"&oslc.select=assetnum,siteid';
  final result = await maximoRequest(url, 'get', maximoEnvironment);

  debugPrint(result.toString());

  if (result["member"] == null) {
    throw Exception('Invalid Response from Maximo');
  }

  if (result['status']! == 'empty') {
    return true;
  } else {
    return false;
  }
}

Future<bool> uploadGeneric(List<String> data, String maximoEnvironment,
    String table, String url) async {
  final result = await maximoRequest(url, 'post', maximoEnvironment,
      const ListToCsvConverter().convert([tableHeaders[table], data]));
  if (result['status'] == 'uploaded') {
    debugPrint('uploaded');
    return true;
  } else {
    debugPrint(result.toString());
    return false;
  }
}

Future<Map<String, dynamic>> maximoRequest(String url, String type, String env,
    [String? body,
    Map<String, String>? header,
    bool addQuery = true,
    bool preview = false]) async {
  url = '${maximoServerDomains[env]}$url';
  final login = await getLoginMaximo(env);
  header ??= {};
  if (url.contains('?')) {
    url = '$url&lean=1';
  } else {
    url = '$url?lean=1';
  }
  if (!apiKeys.containsKey(env)) {
    url = '$url&_lid=${login.login}&_lpwd=${login.password}';
  } else {
    header['apikey'] = login.password;
  }
  while (connectionPool > 1) {
    await Future.delayed(const Duration(milliseconds: 100));
  }
  connectionPool++;
  http.Response response;
  if (type == 'get' || type == 'api') {
    if (type == 'api') {
      url = url.replaceAll('/os/', '/script/');
    }
    try {
      response = await http.get(Uri.parse(url), headers: header);
    } catch (err) {
      return {'status': 'Failed to Connect'};
    }
    debugPrint('get response received');
    connectionPool--;
    var parsed = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (parsed['member'] != null) {
        if (parsed['member'].length == 0) {
          parsed['status'] = 'empty';
          return parsed;
        }
      }
      parsed['status'] = 'results';
      return parsed;
    } else {
      parsed['status'] = 'Invalid Response Code from Maximo';
      throw Exception(parsed['Error']['message'].toString());
    }
  } else if (type == 'post') {
    header['preview'] = '1';
    header['Content-Type'] = 'text/plain';
    try {
      response = await http.post(
        Uri.parse(
          addQuery
              ? (url.contains('?')
                  ? '$url&action=importfile'
                  : '$url?action=importfile')
              : url,
        ),
        headers: header,
        body: body,
      );
    } catch (err) {
      return {'status': 'Failed to Connect'};
    }
    debugPrint('post preview response');
    connectionPool--;
    debugPrint(response.body);
    var parsed = jsonDecode(response.body);
    if (parsed['Error'] != null) {
      return {'status': response.body};
    }
    if (parsed['invaliddoc'] != null) {
      if (parsed['invaliddoc'] > 0) {
        return {'status': 'failed', 'body': parsed};
      }
    }
    if (parsed['totaldoc'] != null && parsed['validdoc'] != null) {
      if (parsed['totaldoc'] == parsed['validdoc']) {
        if (preview == true) {
          return {'status': 'preview'};
        }
        // preview passed
        header.remove('preview');
        try {
          response = await http.post(
            Uri.parse(
              url.contains('?')
                  ? '$url&action=importfile'
                  : '$url?action=importfile',
            ),
            headers: header,
            body: body,
          );
        } catch (err) {
          return {'status': 'Failed to Connect'};
        }
        debugPrint('post response');
        debugPrint(response.body);
        parsed = jsonDecode(response.body);
        if (parsed['Error'] != null) {
          return {'status': response.body};
        }
        if (parsed['validdoc'] != null) {
          if (parsed['validdoc'] > 0) {
            return {'status': 'uploaded'};
          }
        }
      }
    }
    return {'status': 'Unknown'};
  } else {
    // not post or get
    return {'status': 'TODO'};
  }
}
