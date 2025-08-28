import 'dart:convert';

import 'package:iko_reliability_flutter/bin/common.dart';
import 'package:provider/provider.dart';

import '../bin/db_drift.dart';
import '../main.dart';
import '../bin/consts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../settings/settings_notifier.dart';

/// logs in and display result in dataAlert
Future<void> displayLoginAttempt(String password, String env) async {
  var result = await getUserMaximo('[APIKEY]', password, env);
  if (result['status'] == 'fail|connection') {
    showDataAlert(
        navigatorKey.currentContext!,
        ['No response from Maximo servers', 'Check internet connection'],
        'Failed to Login');
  } else if (result['status'] == 'fail|account') {
    showDataAlert(
        navigatorKey.currentContext!,
        ['Please check credentials', 'Check internet connection'],
        'Failed to Login');
  } else {
    showDataAlert(
        navigatorKey.currentContext!,
        [
          'Logged into: $env',
          'As: ${result['displayName']}',
          'Server URL: ${result['maslogouturl'].toString().substring(0, 42)}'
        ],
        'Logged in!');
  }
}

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
  if (kIsWeb) {
    header['x-proxy-target-url'] = url;
    url = 'https://iko-proxy.jonathanmajh.workers.dev/';
  }

  http.Response response;
  try {
    response = await http.get(Uri.parse(url), headers: header);
  } catch (err) {
    return {'status': 'fail|connection'};
  }
  var parsed = jsonDecode(response.body);
  if (response.statusCode == 200) {
    if (parsed['displayName'] != null) {
      parsed['status'] = 'pass';
      saveLoginMaximo(userid, password, env);
      database!.setSettings(
        newSetting:
            Setting(key: 'isAdmin', value: parsed['inactiveSites'].toString()),
      );
      Provider.of<SettingsNotifier>(navigatorKey.currentContext!, listen: false)
          .setAdmin(parsed['inactiveSites']);
      return parsed;
    }
  }
  parsed['status'] = 'fail|account';
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
