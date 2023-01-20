import 'dart:convert';

import '../main.dart';
import 'consts.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getUserMaximo(
    String userid, String password, String env) async {
  // check if credentials are valid before saving
  // password is same as APIKEY, userid is [APIKEY] for apikey
  String url = '${maximoServerDomains[env]}whoami';
  Map<String, String> header = {};
  if (userid == '[APIKEY]') {
    header['apikey'] = password;
    url = url.replaceAll('/os/', '/script/');
  } else {
    url = url.replaceAll('/os/', '/');
    url = '$url?_lid=$userid&_lpwd=$password';
  }
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

Future<void> saveLoginMaximo(String userid, String password, String env) async {
  if (userid == '[APIKEY]') {
    await database!.addUpdateSettings('$env-APIKEY', password);
  } else {
    await database!.addUpdateSettings('$env-USERID', userid);
    await database!.addUpdateSettings('$env-PASSWORD', password);
  }
}

class Credentials {
  final String login;
  final String password;

  const Credentials({
    required this.login,
    required this.password,
  });
}

Future<Credentials> getLoginMaximo(String env) async {
  if (apiKeys.containsKey(env)) {
    final pw = await database!.getSettings('$env-APIKEY');
    return Credentials(login: '[APIKEY]', password: pw.value);
  } else {
    final id = await database!.getSettings('$env-USERID');
    final pw = await database!.getSettings('$env-PASSWORD');
    return Credentials(login: id.value, password: pw.value);
  }
}
