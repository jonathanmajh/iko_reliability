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
  String jpnum;
  String description;
  String persongroup;
  String ikoConditions;
  int priority;
  String ikoWorktype;
  String templatetype;
  int jpduration;
  String ikoPmpackage;
  List<JobTaskMaximo> jobtask;
  List<JobLaborMaximo> joblabor;
  List<JobMaterialMaximo> jobmaterial;
  List<JobServiceMaximo> jobservice;

  JobPlanMaximo({
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
    List<JobMaterialMaximo>? jobmaterial,
    List<JobServiceMaximo>? jobservice,
    required this.jobtask,
  })  : jobmaterial = jobmaterial ?? [],
        jobservice = jobservice ?? [];
}

Map<String, dynamic> generatePM(PreventiveMaintenanceTemplate pmDetails) {
  // var mainJobPlan = JobPlanMaximo(description: description, ikoConditions: ikoConditions, ikoPmpackage: ikoPmpackage, ikoWorktype: ikoWorktype, jpduration: jpduration, jpnum: jpnum, persongroup: persongroup, priority: priority, templatetype: templatetype, joblabor: joblabor, jobmaterial: jobmaterial, jobservice: jobservice, jobtask: jobtask)
  List<JobTaskMaximo> mainJobTasks = [];
  List<JobPlanMaximo> childJobPlans = [];
  int routeTasks = 0;
  for (final task in pmDetails.tasks) {
    //count number of route task for calculating labor hours required
    if (task.metername == null || task.metername == '') {
      continue;
    } else {
      routeTasks++;
    }
  }
  for (final task in pmDetails.tasks) {
    if (task.metername == null || task.metername == '') {
      mainJobTasks.add(JobTaskMaximo(
        jptask: task.jptask,
        description: task.description,
        longdescription: task.longdescription,
      ));
    } else {
      var childTask = JobTaskMaximo(
        jptask: task.jptask,
        description: task.description,
        longdescription: task.longdescription,
        metername: task.metername,
      );
      var childLabor = JobLaborMaximo(
        laborType: pmDetails.crafts[0].laborType,
        quantity: pmDetails.crafts[0].quantity,
        hours: pmDetails.crafts[0].hours / routeTasks.toDouble(),
      );
      //TODO actually generate the numbers / descriptions
      // populate child job plan
      childJobPlans.add(JobPlanMaximo(description: description, ikoConditions: ikoConditions, ikoPmpackage: ikoPmpackage, ikoWorktype: ikoWorktype, jpduration: jpduration, jpnum: jpnum, persongroup: persongroup, priority: priority, templatetype: templatetype, joblabor: joblabor, jobtask: jobtask))
    }
  }

  return {'thing': 'thing'};
}
