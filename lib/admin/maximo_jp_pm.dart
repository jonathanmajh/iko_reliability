import 'dart:convert';

import 'package:http/http.dart' as http;

Map<String, String> maximoServerDomains = {
  'PROD': 'nscandacmaxapp1',
  'TEST': 'nsmaxim1app1',
  'DEV': 'nscandacmaxdev1',
};

Future<bool> existPmNumberMaximo(
    String pmNumber, String siteid, String env) async {
  final url =
      'http://${maximoServerDomains[env]}.na.iko/maxrest/oslc/os/iko_pm?oslc.select=pmnum,siteid&oslc.pageSize=10&oslc.where=pmnum="$pmNumber"%20and%20siteid="$siteid"&_lid=majona&_lpwd=happy818';
  // TODO login management
  // save login in settings box
  try {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var parsed = jsonDecode(response.body);
      if (parsed['rdfs:member'].length == 0) {
        return true;
      }
    } else {
      print('Invalid Response from Maximo');
      return false;
    }
  } catch (err) {
    print('Failed to Connect');
    return true;
  }
  return false;
}

Future<bool> existJpNumberMaximo(String jpNumber, String env) async {
  final url =
      'http://${maximoServerDomains[env]}.na.iko/maxrest/oslc/os/iko_jobplan?oslc.select=jpnum&oslc.pageSize=10&oslc.where=jpnum="$jpNumber"&_lid=majona&_lpwd=happy818';
  // TODO login management
  // save login in settings box
  try {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var parsed = jsonDecode(response.body);
      if (parsed['rdfs:member'].length == 0) {
        return true;
      }
    } else {
      print('Invalid Response from Maximo');
      return false;
    }
  } catch (err) {
    print('Failed to Connect');
    return true;
  }
  return false;
}

Future<bool> existRouteNumberMaximo(
    String routeNumber, String siteid, String env) async {
  final url =
      'http://${maximoServerDomains[env]}.na.iko/maxrest/oslc/os/iko_route?oslc.select=route,siteid&oslc.pageSize=10&oslc.where=route="$routeNumber"%20and%20siteid="$siteid"&_lid=majona&_lpwd=happy818';
  // TODO login management
  // save login in settings box
  try {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var parsed = jsonDecode(response.body);
      if (parsed['rdfs:member'].length == 0) {
        return true;
      }
    } else {
      print('Invalid Response from Maximo');
      return false;
    }
  } catch (err) {
    print('Failed to Connect');
    return true;
  }
  return false;
}
