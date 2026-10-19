import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getDbVersion() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('version');
}

Future<void> saveDbVersion(String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('version', value);
}
