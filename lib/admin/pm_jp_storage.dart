import '../main.dart';

class NumberNotifier {
  List<String> pmNumbers = [];
  List<String> jobPlanNumbers = [];
  List<String> routeNumbers = [];

  void clear() {
    pmNumbers.clear();
    jobPlanNumbers.clear();
    routeNumbers.clear();
  }
}

bool existPmNumberCache(String pmNumber, String siteid) {
  if (!numberNotifier.pmNumbers.contains('$siteid|$pmNumber')) {
    numberNotifier.pmNumbers.add('$siteid|$pmNumber');
    return false;
  }
  return true;
}

bool existJpNumberCache(String jpNumber) {
  if (!numberNotifier.jobPlanNumbers.contains(jpNumber)) {
    numberNotifier.jobPlanNumbers.add(jpNumber);
    return false;
  }
  return true;
}

bool existRouteNumberCache(String routeNumber, String siteid) {
  if (!numberNotifier.routeNumbers.contains('$siteid|$routeNumber')) {
    numberNotifier.routeNumbers.add('$siteid|$routeNumber');
    return false;
  }
  return true;
}
