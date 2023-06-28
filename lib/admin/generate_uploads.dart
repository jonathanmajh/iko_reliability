import 'package:csv/csv.dart';
import 'package:iko_reliability_flutter/admin/consts.dart';
import 'package:iko_reliability_flutter/admin/generate_job_plans.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../main.dart';
import 'db_drift.dart';

Future<Map<String, List<List<String>>>> generateUploads(PMMaximo pmpkg) async {
  Map<String, List<List<String>>> generated = {};
  generated['Asset'] = [];
  generated['Meter'] = [];
  generated['AssetMeter'] = [];
  generated['JobPlan'] = [];
  generated['MeasurePoint'] = [];
  generated['MeasurePoint2'] = [];
  generated['Route'] = [];
  generated['Route_Stop'] = [];
  generated['PM'] = [];
  generated['JobLabor'] = [];
  generated['JPASSETLINK'] = [];
  generated['JobTask'] = [];
  generated['JobMaterial'] = [];
  generated['JobService'] = [];
  generated['Errors'] = [];
  // pm
  if (pmpkg.freqUnit != 'J') {
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
        pmpkg.nextDate == null ? '' : '${pmpkg.nextDate}T00:00:00',
        pmpkg.orgID,
        pmpkg.targetStartTime,
        pmpkg.ikoPMHistoryNotes ?? '',
        pmpkg.fmecaPM ? 'Y' : 'N'
      ]
    ];
    if (pmpkg.description.length > 100) {
      generated['Errors']!.add([
        'PM Description is too long: ${pmpkg.description.length}/100 character limit'
      ]);
    }
  }
  // job plan
  generated = generateJobplan(
    pmpkg.jobplan,
    pmpkg.siteID,
    pmpkg.orgID,
    generated,
  );
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

  // Asset Meter + Meausure Point + AssetMeter + CBM Job Plans
  for (final jobplan in [...pmpkg.route?.childJobPlans ?? [], pmpkg.jobplan]) {
    for (final jobtask in jobplan.jobtask) {
      // job plan can have multiple job tasks
      if (jobtask.metername != null) {
        String assetNumber = jobplan.jobasset[0].assetNumber;
        generated['AssetMeter']!.add([
          pmpkg.siteID,
          assetNumber,
          jobtask.metername ?? '',
        ]);
        final asset = await database!.getAsset(pmpkg.siteID, assetNumber);
        Meter? meter;
        try {
          meter = await database!.getMeter(
              jobtask.metername!.substring(0, jobtask.metername!.length - 2));
          generated['MeasurePoint']!.add([
            pmpkg.siteID,
            assetNumber,
            jobtask.metername ?? '',
            '$assetNumber${jobtask.metername}',
            '${asset.description} - ${meter.inspect} ${jobtask.metername!.substring(jobtask.metername!.length - 2)}',
          ]);
        } catch (e) {
          generated['Errors']!.add(['$e']);
          meter = null;
        }
        generated['Meter']!.add([
          jobtask.metername ?? '',
          '${meter?.inspect ?? ''} ${jobtask.metername!.substring(jobtask.metername!.length - 2)}',
          'CHARACTERISTIC',
          'M-${jobtask.metername!.substring(0, jobtask.metername!.length - 2)}'
        ]);
        final newGen = await generateMeterJobplan(
            await database!.getAsset(pmpkg.siteID, assetNumber),
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
        generated['Errors'] = [...generated['Errors']!, ...newGen['Errors']!];
      }
    }
  }

  return generated;
}

Map<String, List<List<String>>> generateJobplan(JobPlanMaximo jobplan,
    String siteID, String orgID, Map<String, List<List<String>>> generated) {
  generated['JobPlan']!.add([
    // consider constants moving into object
    // if len(description) > 100 then put it into extended description
    orgID,
    siteID,
    jobplan.jpnum,
    '0', // PLUSCREVNUM
    jobplan.description.length > 100 ? 'CHANGE ME!' : jobplan.description,
    jobplan.description.length > 100 ? jobplan.description : '',
    'ACTIVE', // STATUS
    jobplan.persongroup,
    jobplan.ikoConditions,
    jobplan.priority.toString(),
    jobplan.ikoWorktype,
    generated['PM']?.isNotEmpty ?? false ? 'PM' : 'STANDARD', // TEMPLATETYPE
    // PM is created before job plan, if no PM then it is a standard job plan
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
      joblabor.laborCode,
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

Future<Map<String, List<List<String>>>> generateMeterJobplan(
    Asset asset, String meterCode) async {
  Map<String, List<List<String>>> generated = {};
  generated['JobPlan'] = [];
  generated['JobTask'] = [];
  generated['JobLabor'] = [];
  generated['JPASSETLINK'] = [];
  generated['MeasurePoint2'] = [];
  generated['Errors'] = [];
  Meter meter;
  try {
    meter =
        await database!.getMeter(meterCode.substring(0, meterCode.length - 2));
  } catch (e) {
    generated['Errors']!.add(['$e']);
    return generated;
  }

  final meterNumber = int.parse(meterCode.substring(meterCode.length - 2));

  for (final observation in meter.observations) {
    if (!['C01', 'C98'].contains(observation.code)) {
      final jpnum =
          '${asset.assetnum}${meterCode}CBM${meter.craft}${observation.code.substring(1, 3)}';
      generated['JobPlan']!.add([
        '', //orgid
        '', //siteid
        jpnum,
        '0', //pluscrevnum
        '${asset.description} ${meter.inspect} $meterNumber - CBM - ${crafts[meter.craft]}',
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
        asset.assetnum,
        '0', //ISDEFAULTASSETSP
        siteIDAndOrgID[asset.siteid]!,
        asset.siteid,
      ]);
      generated['MeasurePoint2']!.add([
        asset.siteid,
        '${asset.assetnum}$meterCode',
        observation.code,
        jpnum,
      ]);
    }
  }
  return generated;
}

///Creates a jagged array (list) from data from a plutogrid. A list of rows from top to bottom (visible columns only).
///The first value of each column is its title.
List<List<String>> generatePlutogrid(PlutoGridStateManager stateManager,
    {List<String> excludeFields = const []}) {
  List<List<String>> generated = [];
  List<String> fields = List<String>.from(stateManager.columns
      .where((column) => !(column.hide || excludeFields.contains(column.field)))
      .map((column) => column.field));
  //add header row
  generated.add(List.from(stateManager.columns
      .where((column) => fields.contains(column.field))
      .map((column) => column.title)));
  //add body rows
  for (PlutoRow row in stateManager.rows) {
    generated.add(
        List.from(fields.map((e) => (row.cells[e]?.value ?? '').toString())));
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
