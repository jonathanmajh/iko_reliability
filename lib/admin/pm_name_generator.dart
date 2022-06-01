import 'parse_template.dart';

class PMName {
  String pmNumber;
  String pmDescription;

  PMName({
    required this.pmNumber,
    required this.pmDescription,
  });

  factory PMName.generateName(PreventiveMaintenance pmdetails) {
    String number = '';
    String name = '';
    if (pmdetails.routeNumber != null) {
      number = pmdetails.routeNumber!;
      name = '[RouteName]';
    }
    return PMName(pmNumber: number, pmDescription: name);
  }
}
