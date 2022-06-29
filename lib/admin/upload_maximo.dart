import 'dart:convert';
import 'dart:developer';
import 'package:csv/csv.dart';
import 'consts.dart';
import 'maximo_jp_pm.dart';
import 'package:http/http.dart' as http;

Future<Map<String, List<List<String>>>> uploadToMaximo(
    Map<String, List<List<String>>> uploadData, String env) async {
  // +: uploaded; ~: already exist; !: error
  bool result;
  if (uploadData.containsKey('Meter')) {
    print('uploading meters');
    for (int i = 0; i < uploadData['Meter']!.length; i++) {
      if (await isNewMeter(uploadData['Meter']![i][0], env)) {
        debugger();
        result = await uploadGeneric(
          uploadData['Meter']![i],
          env,
          'Meter',
          '/maxrest/oslc/os/iko_meter',
        );
        if (result) {
          uploadData['Meter']![i].add('+');
        } else {
          uploadData['Meter']![i].add('!');
        }
      } else {
        uploadData['Meter']![i].add('~');
      }
    }
  }
  if (uploadData.containsKey('AssetMeter')) {
    print('uploading assetmeters');
    // no checks, maximo will auto error out, can consider adding check for less errors
    for (int i = 0; i < uploadData['AssetMeter']!.length; i++) {
      result = await uploadGeneric(
        uploadData['AssetMeter']![i],
        env,
        'AssetMeter',
        '/maxrest/oslc/os/iko_assetmeter',
      );
      if (result) {
        uploadData['AssetMeter']![i].add('+');
      } else {
        uploadData['AssetMeter']![i].add('!');
      }
    }
  }
  if (uploadData.containsKey('JobPlan')) {
    print('uploading jobplan');
    for (int i = 0; i < uploadData['JobPlan']!.length; i++) {
      if (uploadData['JobPlan']![i][9] == 'CBM') {
        if (!(await isNewJobPlan(uploadData['JobPlan']![i][0], env))) {
          uploadData['JobPlan']![i].add('~');
          continue;
        }
      }
      result = await uploadGeneric(
        uploadData['JobPlan']![i],
        env,
        'JobPlan',
        '/maxrest/oslc/os/iko_jobplan',
      );
      if (result) {
        uploadData['JobPlan']![i].add('+');
      } else {
        uploadData['JobPlan']![i].add('!');
      }
    }
  } // should cache job plans that are brand new to save on later check
  if (uploadData.containsKey('MeasurePoint')) {
    print('uploading measurepoint');
    for (int i = 0; i < uploadData['MeasurePoint']!.length; i++) {
      if (await isNewMeasurePoint(uploadData['MeasurePoint']![i][3], env)) {
        result = await uploadGeneric(
          uploadData['MeasurePoint']![i],
          env,
          'MeasurePoint',
          '/maxrest/oslc/os/iko_measurepoint',
        );
        if (result) {
          uploadData['MeasurePoint']![i].add('+');
        } else {
          uploadData['MeasurePoint']![i].add('!');
        }
      } else {
        uploadData['MeasurePoint']![i].add('~');
      }
    }
  } // should cache
  if (uploadData.containsKey('MeasurePoint2')) {
    print('uploading measurepoint2');
    for (int i = 0; i < uploadData['MeasurePoint2']!.length; i++) {
      if (await isNewMeasurePoint2(uploadData['MeasurePoint2']![i][3], env)) {
        result = await uploadGeneric(
          uploadData['MeasurePoint2']![i],
          env,
          'MeasurePoint2',
          '/maxrest/oslc/os/iko_measurepoint',
        );
        if (result) {
          uploadData['MeasurePoint2']![i].add('+');
        } else {
          uploadData['MeasurePoint2']![i].add('!');
        }
      } else {
        uploadData['MeasurePoint2']![i].add('~');
      }
    }
  }
  if (uploadData.containsKey('Route')) {
    print('uploading route');
    // no checks
    for (int i = 0; i < uploadData['Route']!.length; i++) {
      result = await uploadGeneric(
        uploadData['Route']![i],
        env,
        'Route',
        '/maxrest/oslc/os/iko_route',
      );
      if (result) {
        uploadData['Route']![i].add('+');
      } else {
        uploadData['Route']![i].add('!');
      }
    }
  }
  if (uploadData.containsKey('Route_Stop')) {
    print('uploading routestop');
    // no checks
    for (int i = 0; i < uploadData['Route_Stop']!.length; i++) {
      result = await uploadGeneric(
        uploadData['Route_Stop']![i],
        env,
        'Route_Stop',
        '/maxrest/oslc/os/iko_route_stop',
      );
      if (result) {
        uploadData['Route_Stop']![i].add('+');
      } else {
        uploadData['Route_Stop']![i].add('!');
      }
    }
  }
  if (uploadData.containsKey('PM')) {
    print('uploading pm');
    // no checks
    for (int i = 0; i < uploadData['PM']!.length; i++) {
      result = await uploadGeneric(
        uploadData['PM']![i],
        env,
        'PM',
        '/maxrest/oslc/os/iko_pm',
      );
      if (result) {
        uploadData['PM']![i].add('+');
      } else {
        uploadData['PM']![i].add('!');
      }
    }
  }
  if (uploadData.containsKey('JobLabor')) {
    print('uploading joblabor');
    for (int i = 0; i < uploadData['JobLabor']!.length; i++) {
      if (uploadData['JobLabor']![i][0].contains('CBM')) {
        if (!(await isNewJobLabor(uploadData['JobLabor']![i][0],
            uploadData['JobLabor']![i][2], env))) {
          uploadData['JobLabor']![i].add('~');
          continue;
        }
      }
      result = await uploadGeneric(
        uploadData['JobLabor']![i],
        env,
        'JobLabor',
        '/maxrest/oslc/os/iko_joblabor',
      );
      if (result) {
        uploadData['JobLabor']![i].add('+');
      } else {
        uploadData['JobLabor']![i].add('!');
      }
    }
  }
  if (uploadData.containsKey('JPASSETLINK')) {
    print('uploading jobasset');
    for (int i = 0; i < uploadData['JPASSETLINK']!.length; i++) {
      if (uploadData['JPASSETLINK']![i][0].contains('CBM')) {
        if (!(await isNewJobAsset(
          uploadData['JPASSETLINK']![i][0],
          uploadData['JPASSETLINK']![i][2],
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
        '/maxrest/oslc/os/iko_jpassetlink',
      );
      if (result) {
        uploadData['JPASSETLINK']![i].add('+');
      } else {
        uploadData['JPASSETLINK']![i].add('!');
      }
    }
  }

  if (uploadData.containsKey('JobTask')) {
    print('uploading jobtask');
    // no checks
    for (int i = 0; i < uploadData['JobTask']!.length; i++) {
      // do not upload if CBM job plan already exists
      if (uploadData['JobTask']![i][0].contains('CBM')) {
        uploadData['JobTask']![i].add('~');
        continue;
      }
      result = await uploadGeneric(
        uploadData['JobTask']![i],
        env,
        'JobTask',
        '/maxrest/oslc/os/iko_jobtask',
      );
      if (result) {
        uploadData['JobTask']![i].add('+');
      } else {
        uploadData['JobTask']![i].add('!');
      }
    }
  }
  if (uploadData.containsKey('JobMaterial')) {
    print('uploading jobmaterial');
    // no checks
    for (int i = 0; i < uploadData['JobMaterial']!.length; i++) {
      result = await uploadGeneric(
        uploadData['JobMaterial']![i],
        env,
        'JobMaterial',
        '/maxrest/oslc/os/iko_jobmaterial',
      );
      if (result) {
        uploadData['JobMaterial']![i].add('+');
      } else {
        uploadData['JobMaterial']![i].add('!');
      }
    }
  }
  if (uploadData.containsKey('JobService')) {
    print('uploading jobservice');
    // no checks
    for (int i = 0; i < uploadData['JobService']!.length; i++) {
      result = await uploadGeneric(
        uploadData['JobService']![i],
        env,
        'JobService',
        '/maxrest/oslc/os/iko_jobservice',
      );
      if (result) {
        uploadData['JobService']![i].add('+');
      } else {
        uploadData['JobService']![i].add('!');
      }
    }
  }
  return uploadData;
}

Future<bool> isNewJobLabor(
    String jpNumber, String orgid, String maximoEnvironment) async {
  // is only needed for CBMs
  final url =
      '/maxrest/oslc/os/iko_joblabor?oslc.select=jpnum&oslc.where=jpnum="$jpNumber" and joblabor.orgid="$orgid"';
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
      '/maxrest/oslc/os/iko_jpassetlink?oslc.select=*&oslc.where=jpnum="$jpNumber" and JPASSETSPLINK.siteid="$siteid" and JPASSETSPLINK.assetnum="$assetnum"';
  final result = await maximoRequest(url, 'get', maximoEnvironment);
  if (result['status']! == 'empty') {
    return true;
  } else {
    return false;
  }
}

Future<bool> isNewJobPlan(String jpNumber, String maximoEnvironment) async {
  // is only needed for CBMs
  final url =
      '/maxrest/oslc/os/iko_jobplan?oslc.select=jpnum&oslc.where=jpnum="$jpNumber"';
  final result = await maximoRequest(url, 'get', maximoEnvironment);
  if (result['status']! == 'empty') {
    return true;
  } else {
    return false;
  }
}

Future<bool> isNewMeasurePoint(
    String measurePoint, String maximoEnvironment) async {
  final url =
      '/maxrest/oslc/os/iko_measurepoint?oslc.select=pointnum&oslc.where=pointnum="$measurePoint"';
  final result = await maximoRequest(url, 'get', maximoEnvironment);
  if (result['status']! == 'empty') {
    return true;
  } else {
    return false;
  }
}

Future<bool> isNewMeasurePoint2(String jpnum, String maximoEnvironment) async {
  final url =
      '/maxrest/oslc/os/iko_measurepoint?oslc.select=charpointaction&oslc.where=charpointaction.jpnum="$jpnum"';
  final result = await maximoRequest(url, 'get', maximoEnvironment);
  if (result['status']! == 'empty') {
    return true;
  } else {
    return false;
  }
}

Future<bool> isNewMeter(String meterName, String maximoEnvironment) async {
  final url =
      '/maxrest/oslc/os/iko_meter?oslc.select=metername&oslc.where=metername="$meterName"';
  final result = await maximoRequest(url, 'get', maximoEnvironment);
  if (result['status']! == 'empty') {
    return true;
  } else {
    return false;
  }
}

Future<bool> uploadGeneric(List<String> data, String maximoEnvironment,
    String table, String url) async {
  // first preview the upload
  final result = await maximoRequest(url, 'post', maximoEnvironment,
      const ListToCsvConverter().convert([tableHeaders[table], data]));
  if (result['status'] == 'uploaded') {
    print('uploaded');
    return true;
  } else {
    print(result.toString());
    return false;
  }
}

Future<Map<String, dynamic>> maximoRequest(String url, String type, String env,
    [String? body, Map<String, String>? header]) async {
  url = 'http://${maximoServerDomains[env]}.na.iko$url';
  http.Response response;

  if (type == 'get') {
    try {
      response = await http.get(Uri.parse('$url&_lid=majona&_lpwd=maximo'));
    } catch (err) {
      return {'status': 'Failed to Connect'};
    }
    print('get response');
    print(response.body);
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
      return parsed + {'status': 'Invalid Response Code from Maximo'};
    }
  } else if (type == 'post') {
    header ??= {'preview': '1', 'Content-Type': 'text/plain'};
    try {
      response = await http.post(
        Uri.parse('$url?action=importfile&lean=1&_lid=majona&_lpwd=maximo'),
        headers: header,
        body: body,
      );
    } catch (err) {
      return {'status': 'Failed to Connect'};
    }
    // debugger();
    print('post response');
    print(response.body);
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
            Uri.parse('$url?action=importfile&lean=1&_lid=majona&_lpwd=maximo'),
            headers: header,
            body: body,
          );
        } catch (err) {
          return {'status': 'Failed to Connect'};
        }
        // debugger();
        print('post response');
        print(response.body);
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
