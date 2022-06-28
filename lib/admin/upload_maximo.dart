import 'dart:convert';

import 'maximo_jp_pm.dart';
import 'package:http/http.dart' as http;

void uploadToMaximo(Map<String, List<List<String>>> uploadData) {
  // consider returning data of what was uploaded, prefix data with +/!
  // Meters
  // Asset Meter (dont think checks are necessary)
  // Jobplans (only need to check CBMs)
  // should cache job plans that are brand new to save on later check
  // Measure point
  // Route + Route stop
  // PM
  // Jobplan childs
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

Future<bool> uploadMeter(String meterName, String maximoEnvironment) async {
  const url = '/maxrest/oslc/os/iko_meter';
  final result = await maximoRequest(url, 'post', maximoEnvironment);
  // TODO post data and header
  if (result['status']! == 'empty') {
    return true; // TODO read status
  } else {
    return false;
  }
}

Future<Map<String, String>> maximoRequest(String url, String type, String env,
    [Map<String, String>? header, String? body]) async {
  url = 'http://${maximoServerDomains[env]}.na.iko';
  http.Response response;
  try {
    if (type == 'get') {
      response = await http.get(Uri.parse('$url&_lid=corcoop3&_lpwd=maximo'));
      if (response.statusCode == 200) {
        var parsed = jsonDecode(response.body);
        if (parsed['rdf:member'] == null) {
          return {'status': 'empty'};
        } else {
          return parsed['rdf:member'] + {'status': 'results'};
        }
      } else {
        return {'status': 'Invalid Response Code from Maximo'};
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
