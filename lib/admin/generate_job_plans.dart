import 'package:iko_reliability_flutter/admin/parse_template.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../bin/consts.dart';
import 'pm_name_generator.dart';

class JobAssetMaximo {
  final String assetNumber;

  const JobAssetMaximo({
    required this.assetNumber,
  });
}

class JobLaborMaximo {
  final String laborType;
  final String laborCode;
  final int quantity;
  double hours;

  JobLaborMaximo({
    required this.laborType,
    required this.quantity,
    required this.hours,
    required this.laborCode,
  });

  @override
  String toString() {
    return "[laborType: '$laborType', laborCode: '$laborCode', quantity: $quantity, hours: $hours]";
  }
}

class JobMaterialMaximo {
  final String itemNumber;
  final double quantity;
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
  String nextDate;
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
    required this.nextDate,
    required this.orgID,
    required this.targetStartTime,
    this.ikoPMHistoryNotes,
    this.fmecaPM = false,
    this.logs,
  });
}

Future<String?> generateMeterNumber(Map<String, List<String>> meters,
    String? metername, String? assetNumber, String condition) async {
  if (metername == null ||
      metername == '' ||
      assetNumber == null ||
      assetNumber == '') {
    return null;
  }
  final meterObj = await database!.getMeterByDescription(metername);
  String meter = '';
  int meterCount = 1;
  if (meters.keys.contains(assetNumber)) {
    meter = '${meterObj.meter}${meterCount < 10 ? "0$meterCount" : meterCount}';
    while (meters[assetNumber]!.contains(meter)) {
      meterCount++;
      meter =
          '${meterObj.meter}${meterCount < 10 ? "0$meterCount" : meterCount}';
    }
  } else {
    meter = '${meterObj.meter}01';
  }
  meters[assetNumber] = [meter];
  return meter;
}

Future<PMMaximo> generatePM(ParsedTemplate pmDetails, PMName pmName,
    String maximoServerSelected) async {
  List<JobTaskMaximo> mainJobTasks = [];
  Map<String, JobPlanMaximo> childJobPlans = {};
  List<RouteStopMaximo> routeStops = [];
  Map<String, List<String>> meters = {};
  var sequence = 1;
  int routeTasks = 0;
  String routeType = 'NONE';
  String? meter;
  for (final task in pmDetails.tasks) {
    //count number of route task for calculating labor hours required
    //check if PM is child route, will set as TASK if there are child job tasks
    if (task.assetNumber == null || task.assetNumber == '') {
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
  double jobhrs = 0.0;
  List<JobLaborMaximo> joblabs = [];
  for (final joblabor in pmDetails.crafts) {
    // job plan duration should be max craft hours
    jobhrs = jobhrs < joblabor.hours ? joblabor.hours : jobhrs;
    joblabs.add(JobLaborMaximo(
      laborType: joblabor.laborType,
      quantity: joblabor.quantity,
      hours: joblabor.hours,
      laborCode: joblabor.laborCode,
    ));
  }
  for (final task in pmDetails.tasks) {
    if (task.jptask == null) {
      throw Exception('Missing task number for task: ${task.description}');
    }
    if (task.assetNumber == null || task.assetNumber == '') {
      // everything that does not have an asset number falls under the main job plan
      mainJobTasks.add(JobTaskMaximo(
        jptask: task.jptask!,
        description: task.description!,
        longdescription: task.longdescription,
        metername: await generateMeterNumber(meters, task.metername,
            pmDetails.pmAsset, pmDetails.processCondition!),
      ));
    } else {
      // tasks that have asset number goes in the child job plan for that asset
      // TODO put generateMeterNumber in try catch so that it can give all errors
      meter = await generateMeterNumber(meters, task.metername,
          task.assetNumber, pmDetails.processCondition!);
      var childTask = JobTaskMaximo(
        jptask: task.jptask!,
        description: task.description!,
        longdescription: task.longdescription,
        metername: meter,
      );
      var childLabor = JobLaborMaximo(
        laborType: pmDetails.crafts[0].laborType,
        laborCode: pmDetails.crafts[0].laborCode,
        quantity: pmDetails.crafts[0].quantity,
        hours: jobhrs / routeTasks.toDouble(),
      );
      final asset =
          await database!.getAsset(pmDetails.siteId!, task.assetNumber!);
      String jpnumber;
      // if asset already has a child job plan entry add the additional task and adjust hours
      if (childJobPlans.containsKey(asset.assetnum)) {
        jpnumber = childJobPlans[asset.assetnum]!.jpnum;
        childJobPlans[asset.assetnum]!.jobtask.add(childTask);
        childJobPlans[asset.assetnum]!.jpduration =
            childJobPlans[asset.assetnum]!.jpduration +
                (jobhrs / routeTasks.toDouble());
        childJobPlans[asset.assetnum]!.joblabor[0].hours =
            childJobPlans[asset.assetnum]!.jpduration;
        // else we make new child job plan entry
      } else {
        jpnumber = pmName.replaceable![0];
        jpnumber = jpnumber.replaceFirst('XXXXX', asset.assetnum);
        String jpdescription = pmName.replaceable![1];
        jpdescription = jpdescription.replaceFirst('XXXXX', asset.description);
        final woType = pmDetails.workOrderType!;
        final counter = await findAvailablePMNumber(
            jpnumber, pmDetails.siteId!, maximoServerSelected);
        jpnumber = '${pmDetails.siteId}$jpnumber';
        NumberFormat formatter =
            NumberFormat("0" * '|'.allMatches(jpnumber).length);
        jpnumber =
            jpnumber.replaceAll(RegExp(r'\|+'), formatter.format(counter));
        if (woType == 'LIF') {
          jpdescription =
              jpdescription.replaceFirst('|', numberToLetter(counter));
        }
        routeStops.add(RouteStopMaximo(
            routeStopID: sequence,
            assetNumber: asset.assetnum,
            stopSequence: sequence,
            jpnum: jpnumber));
        sequence++;
        childJobPlans[asset.assetnum] = JobPlanMaximo(
          description: jpdescription,
          ikoConditions: pmDetails.processCondition!,
          ikoPmpackage: pmDetails.pmPackageNumber,
          ikoWorktype: woType,
          jpduration: jobhrs / routeTasks.toDouble(),
          jpnum: jpnumber,
          persongroup: personGroups[pmDetails.crafts[0].laborType
              .substring(pmDetails.crafts[0].laborType.length - 1)]!,
          priority: 2,
          templatetype: 'PM',
          joblabor: [childLabor],
          jobtask: [childTask],
          jobasset: [JobAssetMaximo(assetNumber: asset.assetnum)],
        );
      }
    }
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
  if (!personGroups.containsKey(pmDetails.crafts[0].laborType)) {
    throw Exception(
        'Selected craft type is not valid: ${pmDetails.crafts[0].laborType}');
  }
  var mainJobPlan = JobPlanMaximo(
      description: pmName.pmName,
      ikoConditions: pmDetails.processCondition!,
      ikoPmpackage: pmDetails.pmPackageNumber,
      ikoWorktype: pmDetails.workOrderType!,
      jpduration: jobhrs,
      jpnum: pmName.jpNumber,
      persongroup: personGroups[pmDetails.crafts[0].laborType]!,
      priority: 2,
      templatetype: 'PM',
      joblabor: joblabs,
      jobmaterial: jobmats,
      jobservice: jobservs,
      jobtask: mainJobTasks,
      jobasset: [JobAssetMaximo(assetNumber: pmName.commonParent)]);
  var route = RouteMaximo(
    routeNumber: pmName.routeNumber ?? pmName.pmNumber,
    description: pmName.routeName ?? pmName.pmName,
    routeStopsBecome: routeType,
    routeStops: routeStops,
    childJobPlans: childJobPlans.values.toList(),
  );
  // check frequency
  if (!frequencyUnits.contains(pmDetails.frequencyUnit)) {
    throw Exception('Frequency Unit "${pmDetails.frequency}" is invalid');
  }
  if ((pmDetails.frequency ?? -1) < 0 && pmDetails.frequencyUnit != 'J') {
    throw Exception('Frequency "${pmDetails.frequency}" is invalid');
  }
  if (pmDetails.frequencyUnit == 'J') {
    pmDetails.frequency = -1;
  }
  return PMMaximo(
    siteID: pmDetails.siteId!,
    pmNumber: pmName.pmNumber,
    description: pmName.pmName,
    jobplan: mainJobPlan,
    frequency: pmDetails.frequency!,
    personGroup: personGroups[
        pmDetails.crafts[0].laborType]!, // take first craft as primary craft
    freqUnit: pmDetails.frequencyUnit!,
    assetNumber: pmName.commonParent,
    leadTime: pmDetails.frequencyUnit != 'J'
        ? calcLeadTime(pmDetails.frequency!, pmDetails.frequencyUnit!)
        : 0,
    orgID: siteIDAndOrgID[pmDetails.siteId!]!,
    route: routeType != 'NONE' ? route : null,
    targetStartTime: '08:00:00',
    // ikoPMHistoryNotes: ikoPMHistoryNotes,
    // dont have spot on template, perhaps just leave it as a UI thing?
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
