import 'package:flutter_application_1/admin/parse_template.dart';

class JobLaborMaximo {
  final String laborType;
  final int quantity;
  final double hours;

  const JobLaborMaximo({
    required this.laborType,
    required this.quantity,
    required this.hours,
  });
}

class JobMaterialMaximo {
  final String itemNumber;
  final int quantity;
  final double? cost;

  const JobMaterialMaximo({
    required this.itemNumber,
    required this.quantity,
    this.cost,
  });
}

class JobServiceMaximo {
  final String itemNumber;
  final String vendorId;
  final double? cost;

  const JobServiceMaximo({
    required this.itemNumber,
    required this.vendorId,
    this.cost,
  });
}

class JobTaskMaximo {
  final int jptask;
  final String description;
  final String? metername;
  final String? longdescription;

  const JobTaskMaximo({
    required this.jptask,
    required this.description,
    this.metername,
    this.longdescription,
  });
}

class JobPlanMaximo {
  final String jpnum;
  final String description;
  final String persongroup;
  final String ikoConditions;
  final int priority;
  final String ikoWorktype;
  final String templatetype;
  final int jpduration;
  final String ikoPmpackage;
  final List<JobTaskMaximo> jobtask;
  final List<JobLaborMaximo> joblabor;
  final List<JobMaterialMaximo> jobmaterial;
  final List<JobServiceMaximo> jobservice;

  const JobPlanMaximo({
    required this.description,
    required this.ikoConditions,
    required this.ikoPmpackage,
    required this.ikoWorktype,
    required this.jpduration,
    required this.jpnum,
    required this.persongroup,
    required this.priority,
    required this.templatetype,
    required this.joblabor,
    required this.jobmaterial,
    required this.jobservice,
    required this.jobtask,
  });
}

Map<String, dynamic> generatePM(PreventiveMaintenanceTemplate pmDetails) {
  // TODO
}
