import 'dart:convert';

import '../main.dart';
import 'consts.dart';
import 'package:http/http.dart' as http;

///gets a Map of user data information from Maximo using HTTP and saves login data into local database if successful
Future<Map<String, dynamic>> getUserMaximo(
    String userid, String password, String env) async {
  // check if credentials are valid before saving
  // password is same as APIKEY, userid is [APIKEY] for apikey
  String url = '${maximoServerDomains[env]}whoami';
  Map<String, String> header = {};
  if (userid == '[APIKEY]') {
    header['apikey'] = password;
  } else {
    url = '$url?_lid=$userid&_lpwd=$password';
  }
  url = url.replaceAll('/os/', '/');
  http.Response response;
  try {
    response = await http.get(Uri.parse(url), headers: header);
  } catch (err) {
    showDataAlert(
        ['No response from Maximo servers', 'Check internet connection'],
        'Failed to Login');
    return {'status': 'fail'};
  }
  var parsed = jsonDecode(response.body);
  if (response.statusCode == 200) {
    if (parsed['displayName'] != null) {
      showDataAlert([
        'Logged into :$env',
        'As :${parsed['displayName']}',
        'Server URL: ${parsed['spi:clientHost']}'
      ], 'Logged in!');
      parsed['status'] = 'pass';
      saveLoginMaximo(userid, password, env);
      return parsed;
    }
  }
  showDataAlert(['Please check credentials', 'Check internet connection'],
      'Failed to Login');
  parsed['status'] = 'fail';
  return parsed;
}

///save login data from Maximo to local database
Future<void> saveLoginMaximo(String userid, String password, String env) async {
  if (userid == '[APIKEY]') {
    await database!.addUpdateLoginSettings('$env-APIKEY', password);
  } else {
    await database!.addUpdateLoginSettings('$env-USERID', userid);
    await database!.addUpdateLoginSettings('$env-PASSWORD', password);
  }
}

///Object for Maximo login credentials
class Credentials {
  final String login;
  final String password;

  const Credentials({
    required this.login,
    required this.password,
  });
}

///Gets saved login credentials from local database for the environment specified by [env]
Future<Credentials> getLoginMaximo(String env) async {
  if (apiKeys.containsKey(env)) {
    //return APIKEY type credentials if possible
    final pw = await database!.getLoginSettings('$env-APIKEY');
    return Credentials(login: '[APIKEY]', password: pw.value);
  } else {
    final id = await database!.getLoginSettings('$env-USERID');
    final pw = await database!.getLoginSettings('$env-PASSWORD');
    return Credentials(login: id.value, password: pw.value);
  }
}
