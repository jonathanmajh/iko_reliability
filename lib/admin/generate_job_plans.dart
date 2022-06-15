import 'package:flutter_application_1/admin/asset_storage.dart';
import 'package:flutter_application_1/admin/parse_template.dart';

import 'pm_name_generator.dart';

final personGroups = {
  'O': 'PRODSUP',
  'M': 'MECHSUP',
  'E': 'ELECTSUP',
};

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
  double jpduration;
  String? ikoPmpackage;
  List<JobTaskMaximo> jobtask;
  List<JobLaborMaximo> joblabor;
  List<JobMaterialMaximo> jobmaterial;
  List<JobServiceMaximo> jobservice;

  JobPlanMaximo({
    required this.description,
    required this.ikoConditions,
    this.ikoPmpackage,
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

Future<Map<String, dynamic>> generatePM(
    ParsedTemplate pmDetails, String maximoServerSelected) async {
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
      if (task.assetNumber == null || task.assetNumber == '') {
        print('asset number is empty, failed to generate child route job plan');
      }
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
      final asset = getAsset(pmDetails.siteId!, task.assetNumber!);
      String jpnumber = pmDetails.uploads!.replaceable![0];
      jpnumber = jpnumber.replaceFirst('XXXXX', asset.assetNumber);
      String jpdescription = pmDetails.uploads!.replaceable![1];
      jpdescription = jpdescription.replaceFirst('XXXXX', asset.name);
      final woType = pmDetails.workOrderType!;
      final counter = await findAvailablePMNumber(
          jpnumber, pmDetails.siteId!, maximoServerSelected, woType, 1);
      if (counter > 0) {
        if (woType != 'LC1') {
          jpnumber = '$jpnumber$counter';
        } else {
          jpnumber = jpnumber.replaceFirst('!!!', '$counter');
          jpdescription =
              jpdescription.replaceFirst('!!!', numberToLetter(counter));
        }
      }

      childJobPlans.add(JobPlanMaximo(
        description: jpdescription,
        ikoConditions: pmDetails.processCondition!,
        ikoPmpackage: pmDetails.pmPackageNumber,
        ikoWorktype: woType,
        jpduration: pmDetails.crafts[0].hours / routeTasks.toDouble(),
        jpnum: jpnumber,
        persongroup: personGroups[pmDetails.crafts[0].laborType
            .substring(pmDetails.crafts[0].laborType.length - 1)]!,
        priority: 2,
        templatetype: 'PM',
        joblabor: [childLabor],
        jobtask: [childTask],
      ));
    }
  }

  return {'thing': 'thing'};
}
