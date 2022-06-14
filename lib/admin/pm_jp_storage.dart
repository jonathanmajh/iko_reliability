import 'package:hive/hive.dart';

bool existPmNumberCache(String pmNumber, String siteid) {
  final box = Hive.box('pmNumber');
  var result = box.get('$siteid|$pmNumber');
  if (result == null) {
    box.put('$siteid|$pmNumber', '$siteid|$pmNumber');
    return false;
  }
  return true;
  // TODO need to clear XXnumber box everytime we load files / program start?
  // not sure which frequency is better
}

bool existJpNumberCache(String jpNumber) {
  final box = Hive.box('jpNumber');
  var result = box.get(jpNumber);
  if (result == null) {
    box.put(jpNumber, jpNumber);
    return false;
  }
  return true;
  // TODO need to clear XXnumber box everytime we load files / program start?
  // not sure which frequency is better
}
