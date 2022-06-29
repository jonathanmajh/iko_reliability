import 'dart:convert';
import 'package:csv/csv.dart';
import 'maximo_jp_pm.dart';
import 'package:http/http.dart' as http;

void uploadToMaximo(
    Map<String, List<List<String>>> uploadData, String env) async {
  // +: uploaded; ~: already exist; !: error
  var result;
  if (uploadData.containsKey('Meter')) {
    for (int i = 0; i < uploadData['Meter']!.length; i++) {
      if (await isNewMeter(uploadData['Meter']![i][0], env)) {
        result = await uploadMeter(uploadData['Meter']![i], env);
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
    // no checks
    for (int i = 0; i < uploadData['AssetMeter']!.length; i++) {
      result = await uploadAssetMeter(uploadData['AssetMeter']![i], env);
      if (result) {
        uploadData['AssetMeter']![i].add('+');
      } else {
        uploadData['AssetMeter']![i].add('!');
      }
    }
  }
  if (uploadData.containsKey('JobPlan')) {
    for (int i = 0; i < uploadData['JobPlan']!.length; i++) {
      if (uploadData['JobPlan']![i][9] == 'CBM') {
        if (!(await isNewJobPlan(uploadData['JobPlan']![i][0], env))) {
          uploadData['JobPlan']![i].add('~');
          continue;
        }
      }
      result = await uploadAssetMeter(uploadData['JobPlan']![i], env);
      if (result) {
        uploadData['JobPlan']![i].add('+');
      } else {
        uploadData['JobPlan']![i].add('!');
      }
    }
  } // should cache job plans that are brand new to save on later check
  if (uploadData.containsKey('MeasurePoint')) {
    for (int i = 0; i < uploadData['MeasurePoint']!.length; i++) {
      if (await isNewMeasurePoint(uploadData['MeasurePoint']![i][3], env)) {
        result = await uploadMeasurePoint(uploadData['MeasurePoint']![i], env);
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
    for (int i = 0; i < uploadData['MeasurePoint2']!.length; i++) {
      if (await isNewMeasurePoint2(uploadData['MeasurePoint2']![i][2],
          uploadData['MeasurePoint2']![i][2], env)) {
        result =
            await uploadMeasurePoint2(uploadData['MeasurePoint2']![i], env);
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
    // no checks
    for (int i = 0; i < uploadData['Route']!.length; i++) {
      result = await uploadRoute(uploadData['Route']![i], env);
      if (result) {
        uploadData['Route']![i].add('+');
      } else {
        uploadData['Route']![i].add('!');
      }
    }
  }
  if (uploadData.containsKey('RouteStop')) {
    // no checks
    for (int i = 0; i < uploadData['RouteStop']!.length; i++) {
      result = await uploadRouteStop(uploadData['RouteStop']![i], env);
      if (result) {
        uploadData['RouteStop']![i].add('+');
      } else {
        uploadData['RouteStop']![i].add('!');
      }
    }
  }
  if (uploadData.containsKey('PM')) {
    // no checks
    for (int i = 0; i < uploadData['PM']!.length; i++) {
      result = await uploadPM(uploadData['PM']![i], env);
      if (result) {
        uploadData['PM']![i].add('+');
      } else {
        uploadData['PM']![i].add('!');
      }
    }
  }
  if (uploadData.containsKey('JobLabor')) {
    for (int i = 0; i < uploadData['JobLabor']!.length; i++) {
      if (uploadData['JobLabor']![i][0].contains('CBM')) {
        if (!(await isNewJobLabor(uploadData['JobLabor']![i][0],
            uploadData['JobLabor']![i][2], env))) {
          uploadData['JobLabor']![i].add('~');
          continue;
        }
      }
      result = await uploadJobLabor(uploadData['JobLabor']![i], env);
      if (result) {
        uploadData['JobLabor']![i].add('+');
      } else {
        uploadData['JobLabor']![i].add('!');
      }
    }
  }
  if (uploadData.containsKey('JPASSETLINK')) {
    for (int i = 0; i < uploadData['JPASSETLINK']!.length; i++) {
      if (uploadData['JPASSETLINK']![i][0].contains('CBM')) {
        if (!(await isNewJobAsset(uploadData['JPASSETLINK']![i][0],
            uploadData['JPASSETLINK']![i][2], env))) {
          uploadData['JPASSETLINK']![i].add('~');
          continue;
        }
      }
      result = await uploadJobAsset(uploadData['JPASSETLINK']![i], env);
      if (result) {
        uploadData['JPASSETLINK']![i].add('+');
      } else {
        uploadData['JPASSETLINK']![i].add('!');
      }
    }
  }

  if (uploadData.containsKey('JobTask')) {
    // no checks
    for (int i = 0; i < uploadData['JobTask']!.length; i++) {
      if (uploadData['JobTask']![i][0].contains('CBM')) {
        uploadData['JPASSETLINK']![i].add('~');
        continue;
      }
      result = await uploadJobTask(uploadData['JobTask']![i], env);
      if (result) {
        uploadData['JobTask']![i].add('+');
      } else {
        uploadData['JobTask']![i].add('!');
      }
    }
  }
  if (uploadData.containsKey('JobMaterial')) {
    // no checks
    for (int i = 0; i < uploadData['JobMaterial']!.length; i++) {
      result = await uploadJobMaterial(uploadData['JobMaterial']![i], env);
      if (result) {
        uploadData['JobMaterial']![i].add('+');
      } else {
        uploadData['JobMaterial']![i].add('!');
      }
    }
  }
  if (uploadData.containsKey('JobService')) {
    // no checks
    for (int i = 0; i < uploadData['JobService']!.length; i++) {
      result = await uploadJobService(uploadData['JobService']![i], env);
      if (result) {
        uploadData['JobService']![i].add('+');
      } else {
        uploadData['JobService']![i].add('!');
      }
    }
  }
}

Future<bool> uploadPM(List<String> route, String maximoEnvironment) async {
  const url = '/maxrest/oslc/os/iko_pm';
  final result = await maximoRequest(url, 'post', maximoEnvironment, {},
      const ListToCsvConverter().convert([route]));
  // TODO post data and header
  if (result['status']! == 'empty') {
    return true; // TODO read status
  } else {
    return false;
  }
}

Future<bool> uploadRoute(List<String> route, String maximoEnvironment) async {
  const url = '/maxrest/oslc/os/iko_route';
  final result = await maximoRequest(url, 'post', maximoEnvironment, {},
      const ListToCsvConverter().convert([route]));
  // TODO post data and header
  if (result['status']! == 'empty') {
    return true; // TODO read status
  } else {
    return false;
  }
}

Future<bool> uploadRouteStop(
    List<String> routestop, String maximoEnvironment) async {
  const url = '/maxrest/oslc/os/iko_routestop';
  final result = await maximoRequest(url, 'post', maximoEnvironment, {},
      const ListToCsvConverter().convert([routestop]));
  // TODO post data and header
  if (result['status']! == 'empty') {
    return true; // TODO read status
  } else {
    return false;
  }
}

Future<bool> uploadMeasurePoint(
    List<String> measurepoint, String maximoEnvironment) async {
  const url = '/maxrest/oslc/os/iko_measurepoint';
  final result = await maximoRequest(url, 'post', maximoEnvironment, {},
      const ListToCsvConverter().convert([measurepoint]));
  // TODO post data and header
  if (result['status']! == 'empty') {
    return true; // TODO read status
  } else {
    return false;
  }
}

Future<bool> uploadMeasurePoint2(
    List<String> measurepoints, String maximoEnvironment) async {
  const url = '/maxrest/oslc/os/iko_measurepoint';
  final result = await maximoRequest(url, 'post', maximoEnvironment, {},
      const ListToCsvConverter().convert([measurepoints]));
  // TODO post data and header
  if (result['status']! == 'empty') {
    return true; // TODO read status
  } else {
    return false;
  }
}

Future<bool> uploadAssetMeter(
    List<String> assetMeter, String maximoEnvironment) async {
  const url = '/maxrest/oslc/os/iko_assetmeter';
  final result = await maximoRequest(url, 'post', maximoEnvironment, {},
      const ListToCsvConverter().convert([assetMeter]));
  // TODO post data and header
  if (result['status']! == 'empty') {
    return true; // TODO read status
  } else {
    return false;
  }
}

Future<bool> uploadJobLabor(
    List<String> assetMeter, String maximoEnvironment) async {
  const url = '/maxrest/oslc/os/iko_joblabor';
  final result = await maximoRequest(url, 'post', maximoEnvironment, {},
      const ListToCsvConverter().convert([assetMeter]));
  // TODO post data and header
  if (result['status']! == 'empty') {
    return true; // TODO read status
  } else {
    return false;
  }
}

Future<bool> isNewJobLabor(
    String jpNumber, String orgid, String maximoEnvironment) async {
  // is only needed for CBMs
  final url =
      '/maxrest/oslc/os/iko_joblabor?oslc.select=jpnum&oslc.where=jpnum="$jpNumber"';
  final result = await maximoRequest(url, 'get', maximoEnvironment);
  if (result['status']! == 'empty') {
    return true;
  } else {
    return false;
  }
}

Future<bool> uploadJobAsset(
    List<String> jobAsset, String maximoEnvironment) async {
  const url = '/maxrest/oslc/os/iko_jpassetlink';
  final result = await maximoRequest(url, 'post', maximoEnvironment, {},
      const ListToCsvConverter().convert([jobAsset]));
  // TODO post data and header
  if (result['status']! == 'empty') {
    return true; // TODO read status
  } else {
    return false;
  }
}

Future<bool> uploadJobMaterial(
    List<String> jobMaterial, String maximoEnvironment) async {
  const url = '/maxrest/oslc/os/iko_jobmaterial';
  final result = await maximoRequest(url, 'post', maximoEnvironment, {},
      const ListToCsvConverter().convert([jobMaterial]));
  // TODO post data and header
  if (result['status']! == 'empty') {
    return true; // TODO read status
  } else {
    return false;
  }
}

Future<bool> uploadJobService(
    List<String> jobService, String maximoEnvironment) async {
  const url = '/maxrest/oslc/os/iko_jobservice';
  final result = await maximoRequest(url, 'post', maximoEnvironment, {},
      const ListToCsvConverter().convert([jobService]));
  // TODO post data and header
  if (result['status']! == 'empty') {
    return true; // TODO read status
  } else {
    return false;
  }
}

Future<bool> isNewJobAsset(
    String jpNumber, String siteid, String maximoEnvironment) async {
  // is only needed for CBMs
  final url =
      '/maxrest/oslc/os/iko_jpassetlink?oslc.select=jpnum&oslc.where=jpnum="$jpNumber"';
  final result = await maximoRequest(url, 'get', maximoEnvironment);
  if (result['status']! == 'empty') {
    return true;
  } else {
    return false;
  }
}

Future<bool> uploadJobTask(
    List<String> jobTask, String maximoEnvironment) async {
  const url = '/maxrest/oslc/os/iko_jobtask';
  final result = await maximoRequest(url, 'post', maximoEnvironment, {},
      const ListToCsvConverter().convert([jobTask]));
  // TODO post data and header
  if (result['status']! == 'empty') {
    return true; // TODO read status
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
      '/maxrest/oslc/os/iko_measurepoint?oslc.select=measurepoint&oslc.where=measurepoint="$measurePoint"';
  final result = await maximoRequest(url, 'get', maximoEnvironment);
  if (result['status']! == 'empty') {
    return true;
  } else {
    return false;
  }
}

Future<bool> isNewMeasurePoint2(String measurePoint, String observationCode,
    String maximoEnvironment) async {
  final url =
      '/maxrest/oslc/os/iko_measurepoint?oslc.select=measurepoint&oslc.where=measurepoint="$measurePoint"';
  final result = await maximoRequest(url, 'get', maximoEnvironment);
  if (result['status']! == 'empty') {
    return true;
  } else {
    return false;
  }
}

Future<bool> isNewMeter(String meterName, String maximoEnvironment) async {
  // TODO check string
  final url =
      '/maxrest/oslc/os/iko_meter?oslc.select=meter&oslc.where=meter="$meterName"';
  final result = await maximoRequest(url, 'get', maximoEnvironment);
  if (result['status']! == 'empty') {
    return true;
  } else {
    return false;
  }
}

Future<bool> uploadJobPlan(
    List<String> jobplan, String maximoEnvironment) async {
  const url = '/maxrest/oslc/os/iko_jobplan';
  final result = await maximoRequest(url, 'post', maximoEnvironment, {},
      const ListToCsvConverter().convert([jobplan]));
  // TODO post data and header
  if (result['status']! == 'empty') {
    return true; // TODO read status
  } else {
    return false;
  }
}

Future<bool> uploadMeter(List<String> meter, String maximoEnvironment) async {
  const url = '/maxrest/oslc/os/iko_meter';
  final result = await maximoRequest(url, 'post', maximoEnvironment, {},
      const ListToCsvConverter().convert([meter]));
  // TODO post data and header
  if (result['status']! == 'empty') {
    return true; // TODO read status
  } else {
    return false;
  }
}

Future<Map<String, String>> maximoRequest(String url, String type, String env,
    [Map<String, String>? header, String? body]) async {
  url = 'http://${maximoServerDomains[env]}.na.iko$url';
  http.Response response;
  try {
    if (type == 'get') {
      response = await http.get(Uri.parse('$url&_lid=corcoop3&_lpwd=maximo'));
      var parsed = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (parsed['rdf:member'] == null) {
          return {'status': 'empty'};
        } else {
          return parsed['rdf:member'] + {'status': 'results'};
        }
      } else {
        return parsed + {'status': 'Invalid Response Code from Maximo'};
      }
    } else if (type == 'post') {
      response = await http.post(
        Uri.parse('$url?action=importfile&lean=1&_lid=corcoop3&_lpwd=maximo'),
        headers: header, // TODO preview first then real upload
        body: body,
      );
      return {'status': 'TODO'};
    } else {
      return {'status': 'TODO'};
    }
  } catch (err) {
    return {'status': 'Failed to Connect'};
  }
}
