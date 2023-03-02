import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

const updateUrl =
    'https://api.github.com/repos/jonathanmajh/iko_reliability/releases/latest';

Future<bool> checkUpdate() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String curVersion = packageInfo.version;
  http.Response response;
  try {
    response = await http.get(Uri.parse(updateUrl));
  } catch (err) {
    print('update check fail 1');
    return false;
  }
  var parsed = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print(parsed);
    if (parsed['tag_name'] != null) {
      if (parsed['tag_name'] != 'v$curVersion') {
        print('update check true');
        return true;
      }
    }
    print('update check fail 2');
    return false;
  }
  print('update check fail 3');
  return false;
}
