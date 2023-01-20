import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/widgets.dart';
import 'package:iko_reliability_flutter/admin/settings.dart';
import 'package:iko_reliability_flutter/admin/template_notifier.dart';
import 'consts.dart';
import 'package:http/http.dart' as http;

Future<Map<String, List<List<String>>>> uploadToMaximo(
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
          uploadData['JobLabor']![i][2], uploadData['JobLabor']![i][7], env))) {
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

Future<bool> isNewJobLabor(
    String jpNumber, String orgid, String maximoEnvironment) async {
  // do for all in case of retries
  final url =
      'iko_joblabor?oslc.select=jpnum&oslc.where=jpnum="$jpNumber" and joblabor.orgid="$orgid"';
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
    [String? body, Map<String, String>? header]) async {
  url = '${maximoServerDomains[env]}$url';
  final login = await getLoginMaximo(env);
  header ??= {};
  if (!apiKeys.containsKey(env)) {
    if (url.contains('?')) {
      url = '$url&_lid=${login.login}&_lpwd=${login.password}';
    } else {
      url = '$url?_lid=${login.login}&_lpwd=${login.password}';
    }
  } else {
    header['apikey'] = login.password;
  }
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
    var parsed = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (parsed['rdfs:member'] != null) {
        if (parsed['rdfs:member'].length == 0) {
          parsed['status'] = 'empty';
          return parsed;
        }
      }
      parsed['status'] = 'results';
      return parsed;
    } else {
      parsed['status'] = 'Invalid Response Code from Maximo';
      return parsed;
    }
  } else if (type == 'post') {
    header['preview'] = '1';
    header['Content-Type'] = 'text/plain';
    try {
      response = await http.post(
        Uri.parse(
          url.contains('?')
              ? '$url&action=importfile&lean=1'
              : '$url?action=importfile&lean=1',
        ),
        headers: header,
        body: body,
      );
    } catch (err) {
      return {'status': 'Failed to Connect'};
    }
    debugPrint('post preview response');
    debugPrint(response.body);
    var parsed = jsonDecode(response.body);
    if (parsed['Error'] != null) {
      return {'status': response.body};
    }
    if (parsed['invaliddoc'] != null) {
      if (parsed['invaliddoc'] > 0) {
        return {'status': 'failed'};
      }
    }
    if (parsed['totaldoc'] != null && parsed['validdoc'] != null) {
      if (parsed['totaldoc'] == parsed['validdoc']) {
        // preview passed
        header.remove('preview');
        try {
          response = await http.post(
            Uri.parse(
              url.contains('?')
                  ? '$url&action=importfile&lean=1'
                  : '$url?action=importfile&lean=1',
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
