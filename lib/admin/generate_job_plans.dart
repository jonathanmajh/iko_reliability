import 'package:iko_reliability/admin/asset_storage.dart';
import 'package:iko_reliability/admin/parse_template.dart';

import 'consts.dart';
import 'pm_name_generator.dart';

class JobAssetMaximo {
  final String assetNumber;

  const JobAssetMaximo({
    required this.assetNumber,
  });
}

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
  List<JobAssetMaximo> jobasset;

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
    required this.jobasset,
  })  : jobmaterial = jobmaterial ?? [],
        jobservice = jobservice ?? [];
}

class RouteStopMaximo {
  int routeStopID;
  String? jpnum;
  int stopSequence;
  String assetNumber;

  RouteStopMaximo({
    required this.routeStopID,
    required this.assetNumber,
    required this.stopSequence,
    this.jpnum,
  });
}

class RouteMaximo {
  String routeNumber;
  String routeStopsBecome;
  String description;
  List<RouteStopMaximo> routeStops;
  List<JobPlanMaximo> childJobPlans;

  RouteMaximo({
    required this.routeNumber,
    required this.description,
    required this.routeStopsBecome,
    required this.routeStops,
    List<JobPlanMaximo>? childJobPlans,
  }) : childJobPlans = childJobPlans ?? [];
}

class PMMaximo {
  String siteID;
  String pmNumber;
  String description;
  JobPlanMaximo jobplan;
  RouteMaximo? route;
  final woStatus = 'WSCH';
  int frequency;
  String personGroup;
  String freqUnit;
  bool pmAssetWOGen;
  String assetNumber;
  int leadTime;
  final priority = 2;
  String? nextDate;
  String orgID;
  String targetStartTime;
  String? ikoPMHistoryNotes;
  bool fmecaPM;
  List<String>? logs;

  PMMaximo({
    required this.siteID,
    required this.pmNumber,
    required this.description,
    required this.jobplan,
    this.route,
    required this.frequency,
    required this.personGroup,
    required this.freqUnit,
    this.pmAssetWOGen = false,
    required this.assetNumber,
    required this.leadTime,
    this.nextDate,
    required this.orgID,
    required this.targetStartTime,
    this.ikoPMHistoryNotes,
    this.fmecaPM = false,
    this.logs,
  });
}

Future<PMMaximo> generatePM(
    ParsedTemplate pmDetails, String maximoServerSelected) async {
  List<JobTaskMaximo> mainJobTasks = [];
  List<JobPlanMaximo> childJobPlans = [];
  List<RouteStopMaximo> routeStops = [];
  Map<String, List<String>> meters = {};
  var sequence = 1;
  int routeTasks = 0;
  String routeType = 'NONE';
  String meter = '';
  int meterCount = 1;
  for (final task in pmDetails.tasks) {
    //count number of route task for calculating labor hours required
    //check if PM is child route, will set as TASK if there are child job tasks
    if (task.metername == null || task.metername == '') {
      continue;
    } else {
      routeTasks++;
      routeType = 'CHILD';
    }
  }
  if (pmDetails.assets.length > 1 && routeType != 'CHILD') {
    routeType = 'TASK';
    for (final asset in pmDetails.assets) {
      routeStops.add(RouteStopMaximo(
        routeStopID: sequence,
        assetNumber: asset,
        stopSequence: sequence,
      ));
      sequence++;
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
      if (meters.keys.contains(task.assetNumber)) {
        meter =
            '${task.metername}${meterCount < 10 ? "0$meterCount" : meterCount}';
        while (meters[task.assetNumber]!.contains(meter)) {
          meterCount++;
          meter =
              '${task.metername}${meterCount < 10 ? "0$meterCount" : meterCount}';
        }
      } else {
        meter = '${task.metername}01';
      }
      meters[task.assetNumber!] = [meter];
      var childTask = JobTaskMaximo(
        jptask: task.jptask,
        description: task.description,
        longdescription: task.longdescription,
        metername: meter,
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
          jpnumber, pmDetails.siteId!, maximoServerSelected, woType, 2);
      if (counter > 0) {
        if (woType != 'LC1') {
          jpnumber = '$jpnumber$counter';
        } else {
          jpnumber = jpnumber.replaceFirst('!!!', '$counter');
          jpdescription =
              jpdescription.replaceFirst('!!!', numberToLetter(counter));
        }
      }
      routeStops.add(RouteStopMaximo(
          routeStopID: sequence,
          assetNumber: asset.assetNumber,
          stopSequence: sequence,
          jpnum: jpnumber));
      sequence++;
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
        jobasset: [JobAssetMaximo(assetNumber: asset.assetNumber)],
      ));
    }
  }
  double jobhrs = 0.0;
  List<JobLaborMaximo> joblabs = [];
  for (final joblabor in pmDetails.crafts) {
    jobhrs = jobhrs + joblabor.hours;
    joblabs.add(JobLaborMaximo(
      laborType: joblabor.laborType,
      quantity: joblabor.quantity,
      hours: joblabor.hours,
    ));
  }
  List<JobMaterialMaximo> jobmats = [];
  for (final jobmaterial in pmDetails.materials) {
    jobmats.add(JobMaterialMaximo(
      itemNumber: jobmaterial.itemNumber,
      quantity: jobmaterial.quantity,
    ));
  }
  List<JobServiceMaximo> jobservs = [];
  for (final jobservice in pmDetails.services) {
    jobservs.add(JobServiceMaximo(
      itemNumber: jobservice.itemNumber,
      vendorId: jobservice.vendorId,
    ));
  }
  var mainJobPlan = JobPlanMaximo(
      description: pmDetails.uploads!.pmName,
      ikoConditions: pmDetails.processCondition!,
      ikoPmpackage: pmDetails.pmPackageNumber,
      ikoWorktype: pmDetails.workOrderType!,
      jpduration: jobhrs,
      jpnum: pmDetails.uploads!.jpNumber,
      persongroup: personGroups[pmDetails.crafts[0].laborType]!,
      priority: 2,
      templatetype: 'PM',
      joblabor: joblabs,
      jobmaterial: jobmats,
      jobservice: jobservs,
      jobtask: mainJobTasks,
      jobasset: [JobAssetMaximo(assetNumber: pmDetails.uploads!.commonParent)]);
  var route = RouteMaximo(
    routeNumber: pmDetails.uploads!.pmNumber,
    description: pmDetails.uploads!.pmName,
    routeStopsBecome: routeType,
    routeStops: routeStops,
    childJobPlans: childJobPlans,
  );
  print('complete job plan generation');
  return PMMaximo(
    siteID: pmDetails.siteId!,
    pmNumber: pmDetails.uploads!.pmNumber,
    description: pmDetails.uploads!.pmName,
    jobplan: mainJobPlan,
    frequency: pmDetails.frequency!,
    personGroup: personGroups[
        pmDetails.crafts[0].laborType]!, // take first craft as primary craft
    freqUnit: pmDetails.frequencyUnit!,
    assetNumber: pmDetails.uploads!.commonParent,
    leadTime: calcLeadTime(pmDetails.frequency!, pmDetails.frequencyUnit!),
    orgID: siteIDAndOrgID[pmDetails.siteId!]!,
    route: routeType != 'NONE' ? route : null,
    targetStartTime: '08:00:00',
    // TODO ikoPMHistoryNotes: ikoPMHistoryNotes,
    fmecaPM: null != pmDetails.pmPackageNumber,
    nextDate: pmDetails.nextDueDate,
  );
}

int calcLeadTime(int frequency, String freqUnit) {
  final days = frequency * freqUnitToDays[freqUnit]!;
  if (days <= 14) {
    return 7;
  }
  if (days <= 42) {
    return 14;
  }
  return 30;
}
