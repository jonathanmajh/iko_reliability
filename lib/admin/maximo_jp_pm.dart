import 'package:iko_reliability_flutter/admin/upload_maximo.dart';

Future<bool> existPmNumberMaximo(
    String pmNumber, String siteid, String env) async {
  final url =
      'iko_pm?oslc.select=pmnum,siteid&oslc.pageSize=10&oslc.where=pmnum="$pmNumber"%20and%20siteid="$siteid"';
  final result = await maximoRequest(url, 'get', env);
  if (result['status']! == 'empty') {
    return false;
  }
  return true;
}

Future<bool> existJpNumberMaximo(String jpNumber, String env) async {
  final url =
      'iko_jobplan?oslc.select=jpnum&oslc.pageSize=10&oslc.where=jpnum="$jpNumber"';
  final result = await maximoRequest(url, 'get', env);
  if (result['status']! == 'empty') {
    return false;
  }
  return true;
}

Future<bool> existRouteNumberMaximo(
    String routeNumber, String siteid, String env) async {
  final url =
      'iko_route?oslc.select=route,siteid&oslc.pageSize=10&oslc.where=route="$routeNumber"%20and%20siteid="$siteid"';
  final result = await maximoRequest(url, 'get', env);
  if (result['status']! == 'empty') {
    return false;
  }
  return true;
}
