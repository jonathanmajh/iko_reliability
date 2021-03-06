import 'package:csv/csv.dart';
import 'package:iko_reliability/admin/consts.dart';
import 'package:iko_reliability/admin/generate_job_plans.dart';
import 'package:iko_reliability/admin/observation_list_storage.dart';

import 'asset_storage.dart';

Map<String, List<List<String>>> generateUploads(PMMaximo pmpkg) {
  Map<String, List<List<String>>> generated = {};
  // pm template
  generated['PM'] = [
    [
      pmpkg.siteID,
      pmpkg.pmNumber,
      pmpkg.description,
      pmpkg.jobplan.jpnum,
      pmpkg.woStatus,
      pmpkg.personGroup,
      pmpkg.frequency.toString(),
      freqUnitToString[pmpkg.freqUnit]!.toUpperCase(),
      pmpkg.pmAssetWOGen ? 'Y' : 'N',
      pmpkg.assetNumber,
      pmpkg.route?.routeNumber ?? '',
      pmpkg.leadTime.toString(),
      pmpkg.priority.toString(),
      '${pmpkg.nextDate}T00:00:00',
      pmpkg.orgID,
      pmpkg.targetStartTime,
      pmpkg.ikoPMHistoryNotes ?? '',
      pmpkg.fmecaPM ? 'Y' : 'N'
    ]
  ];
  // route
  if (pmpkg.route != null) {
    generated['Route'] = [
      [
        pmpkg.orgID,
        pmpkg.siteID,
        pmpkg.route!.routeNumber,
        pmpkg.route!.routeStopsBecome,
        pmpkg.route!.description,
      ]
    ];
    generated['Route_Stop'] = [];
    for (final routeStop in pmpkg.route!.routeStops) {
      generated['Route_Stop']!.add([
        pmpkg.orgID,
        pmpkg.siteID,
        pmpkg.route!.routeNumber,
        routeStop.stopSequence.toString(),
        routeStop.assetNumber,
        routeStop.jpnum ?? '',
        routeStop.stopSequence.toString(),
        pmpkg.orgID,
        pmpkg.siteID,
      ]);
    }
    // job plan
    generated['JobPlan'] = [];
    generated['JobMaterial'] = [];
    generated['JobService'] = [];
    generated['JobLabor'] = [];
    generated['JPASSETLINK'] = [];
    generated['JobTask'] = [];
    generated = generateJobplan(
      pmpkg.jobplan,
      pmpkg.siteID,
      pmpkg.orgID,
      generated,
    );

    // Asset update for fmeca
    generated['Asset'] = [];
    generated['AssetMeter'] = [];
    generated['MeasurePoint'] = [];
    generated['Meter'] = [];
    generated['MeasurePoint2'] = [];
    if (pmpkg.jobplan.ikoPmpackage != null) {
      for (final jobplan in pmpkg.route!.childJobPlans) {
        final jobasset = jobplan.jobasset[0];
        // TODO will not work if it is single asset PM
        generated['Asset']!.add([
          pmpkg.siteID,
          jobasset.assetNumber,
          pmpkg.jobplan.ikoPmpackage ?? '',
        ]);
      }
    }
    // Asset Meter + Meausure Point + AssetMeter + CBM Job Plans
    for (final jobplan in pmpkg.route!.childJobPlans) {
      final jobtask =
          jobplan.jobtask[0]; // child job plans should only have 1 job task
      if (jobtask.metername != null) {
        for (final routeStops in pmpkg.route!.routeStops) {
          if (routeStops.jpnum == jobplan.jpnum) {
            generated['AssetMeter']!.add([
              pmpkg.siteID,
              routeStops.assetNumber,
              jobtask.metername ?? '',
            ]);
            final asset = getAsset(pmpkg.siteID, routeStops.assetNumber);
            final meter = getObservation(jobtask.metername!);
            generated['MeasurePoint']!.add([
              pmpkg.siteID,
              routeStops.assetNumber,
              jobtask.metername ?? '',
              '${routeStops.assetNumber}${jobtask.metername}',
              '${asset.name} - ${meter.inspect} ${jobtask.metername!.substring(jobtask.metername!.length - 2)}',
            ]);
            generated['Meter']!.add([
              jobtask.metername ?? '',
              jobtask.metername ?? '',
              'CHARACTERISTIC',
              'M-${jobtask.metername!.substring(0, jobtask.metername!.length - 2)}'
            ]);
            final newGen = generateMeterJobplan(
                getAsset(pmpkg.siteID, routeStops.assetNumber),
                jobtask.metername!);
            generated['JobPlan'] = [
              ...generated['JobPlan']!,
              ...newGen['JobPlan']!
            ];
            generated['JobLabor'] = [
              ...generated['JobLabor']!,
              ...newGen['JobLabor']!
            ];
            generated['JPASSETLINK'] = [
              ...generated['JPASSETLINK']!,
              ...newGen['JPASSETLINK']!
            ];
            generated['JobTask'] = [
              ...generated['JobTask']!,
              ...newGen['JobTask']!
            ];
            generated['MeasurePoint2'] = [
              ...generated['MeasurePoint2']!,
              ...newGen['MeasurePoint2']!
            ];
          }
        }
      }
    }
    // child job plan
    if (pmpkg.route!.childJobPlans.isNotEmpty) {
      for (var jobplan in pmpkg.route!.childJobPlans) {
        generated = generateJobplan(
          jobplan,
          pmpkg.siteID,
          pmpkg.orgID,
          generated,
        );
      }
    }
  }

  // give me space damn it
  // asdfasdf
  return generated;
}

Map<String, List<List<String>>> generateJobplan(JobPlanMaximo jobplan,
    String siteID, String orgID, Map<String, List<List<String>>> generated) {
  generated['JobPlan']!.add([
    // consider constants moving into object
    orgID,
    siteID,
    jobplan.jpnum,
    '0', // PLUSCREVNUM
    jobplan.description,
    '', // details
    'ACTIVE', // STATUS
    jobplan.persongroup,
    jobplan.ikoConditions,
    jobplan.priority.toString(),
    jobplan.ikoWorktype,
    'PM', // TEMPLATETYPE
    jobplan.jpduration.toString(),
    'N', //downtime
    'N', //interruptible
    jobplan.ikoPmpackage ?? ''
  ]);
  if (jobplan.jobmaterial.isNotEmpty) {
    for (final jobmaterial in jobplan.jobmaterial) {
      generated['JobMaterial']!.add([
        orgID,
        siteID,
        jobplan.jpnum,
        '0', //PLUSCREVNUM
        '', //orgid for item
        '', //siteid  for item
        jobmaterial.itemNumber,
        jobmaterial.quantity.toString(),
        'ITEMSET1',
        '', //location
        '', //storelocsite
        '', //company
        jobmaterial.cost?.toString() ?? '',
      ]);
    }
  }
  if (jobplan.jobservice.isNotEmpty) {
    for (final jobservice in jobplan.jobservice) {
      generated['JobService']!.add([
        orgID,
        siteID,
        jobplan.jpnum,
        '0', //PLUSCREVNUM
        '', //orgid for item
        '', //siteid  for item
        jobservice.itemNumber,
        '', //ITEMQTY
        'ITEMSET1',
        jobservice.cost?.toString() ?? '',
      ]);
    }
  }
  for (final joblabor in jobplan.joblabor) {
    generated['JobLabor']!.add([
      orgID,
      siteID,
      jobplan.jpnum,
      '0', //PLUSCREVNUM
      craftCode[joblabor.laborType]!,
      joblabor.hours.toString(),
      joblabor.quantity.toString(),
      orgID,
    ]);
  }
  for (final jobasset in jobplan.jobasset) {
    generated['JPASSETLINK']!.add([
      orgID,
      siteID,
      jobplan.jpnum,
      '0', //PLUSCREVNUM
      jobasset.assetNumber,
      '0', //ISDEFAULTASSETSP
      orgID,
      siteID,
    ]);
  }
  for (final jobtask in jobplan.jobtask) {
    generated['JobTask']!.add([
      orgID,
      siteID,
      jobplan.jpnum,
      '0', //PLUSCREVNUM
      jobtask.jptask.toString(),
      '0', //PLUSCJPREVNUM
      jobtask.metername ?? '',
      jobtask.description,
      jobTaskFormat(jobtask.longdescription ?? ''),
    ]);
  }
  return generated;
}

Map<String, List<List<String>>> generateMeterJobplan(
    Asset asset, String meterCode) {
  Map<String, List<List<String>>> generated = {};
  final meter = getObservation(meterCode);
  final meterNumber = int.parse(meterCode.substring(meterCode.length - 2));
  generated['JobPlan'] = [];
  generated['JobLabor'] = [];
  generated['JPASSETLINK'] = [];
  generated['JobTask'] = [];
  generated['MeasurePoint2'] = [];
  for (final observation in meter.observations) {
    if (!['C01', 'C98'].contains(observation.code)) {
      final jpnum =
          '${asset.assetNumber}${meterCode}CBM${meter.craft}${observation.code.substring(1, 3)}';
      generated['JobPlan']!.add([
        '', //orgid
        '', //siteid
        jpnum,
        '0', //pluscrevnum
        '${asset.name} ${meter.inspect} $meterNumber - CBM - ${crafts[meter.craft]}',
        '${meter.inspect} $meterNumber - ${observation.description} - ${observation.action} ${meter.inspect} $meterNumber',
        'ACTIVE',
        personGroups[meter.craft]!,
        meter.condition,
        '3',
        'CBM',
        'PM',
        '1',
        'N',
        'N',
        ''
      ]);
      generated['JobTask']!.add([
        '',
        '',
        jpnum,
        '0',
        '10',
        '0',
        '',
        'General',
        "<div>1. Strictly follow all IKO, plant and common sense safety procedures when executing each and all tasks.</div>\n<div>2. Clean off all debris from asset being worked on and related work area.</div>\n<div>3. Record all work done and all parts used, and all observations as each task is executed.</div>\n<div>4. Ensure all applicable IKO SOP's are followed when performing each task.</div>\n<div>5. If any suspect conditions or components are found that may cause operating problems before the next PM cycle, immediately report these to the maintenance supervisor or designate.</div>",
      ]);
      generated['JobTask']!.add([
        '',
        '',
        jpnum,
        '0',
        '20',
        '0',
        meterCode,
        '${observation.action} ${meter.inspect}',
        "<div></div>",
      ]);
      generated['JobTask']!.add([
        '',
        '',
        jpnum,
        '0',
        '30',
        '0',
        '',
        'Completion',
        "<div>1. Remove any garbage from area and dispose.</div>\n<div>2. Ensure that all tools are removed from the area and returned to their proper storage location.</div>\n<div>3. Clean all lubricate surfaces and areas.</div>\n<div>4. Remove all lock outs.</div>\n<div>5. Review the work orders assuring that all reported requirements have been fully satisfied, all parts that consumed are documented, and all adjustments made are recorded. If any concern still exists about the condition of this piece of equipment notify the supervisor immediately.</div>\n<div>6. Record the time taken to execute the whole work order.</div>\n<div>7. Hand in all replaced components with work order to Supervisor for analysis.</div>",
      ]);
      generated['JobLabor']!.add([
        '',
        '',
        jpnum,
        '0', //PLUSCREVNUM
        craftCode[meter.craft]!,
        '1',
        '1',
        siteIDAndOrgID[asset.siteid]!,
      ]);
      generated['JPASSETLINK']!.add([
        '',
        '',
        jpnum,
        '0', //PLUSCREVNUM
        asset.assetNumber,
        '0', //ISDEFAULTASSETSP
        siteIDAndOrgID[asset.siteid]!,
        asset.siteid,
      ]);
      generated['MeasurePoint2']!.add([
        asset.siteid,
        '${asset.assetNumber}$meterCode',
        observation.code,
        jpnum,
      ]);
    }
  }
  return generated;
}

String writeToCSV(Map<String, List<List<String>>> generated) {
  String allData = '';
  for (final tables in generated.keys) {
    allData =
        '$allData\n$tables\n${const ListToCsvConverter().convert(generated[tables])}';
  }
  return allData;
}

String jobTaskFormat(String desc) {
  return '<div>${desc.replaceAll('\n', '<div>\n</div>')}</div>';
}
