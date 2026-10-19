// Round-trip check for the PM request template export:
// builds a workbook from extracted stores through the real
// buildImportTemplateWorkbook with the bundled template, verifies the file
// integrity, and parses it back with the real ParsedTemplate.fromExcel.
// Run: dart run test/extract_import_template_test.dart
import 'dart:io';

import 'package:excel_plus/excel_plus.dart';
import 'package:iko_reliability_flutter/admin/extract_import_template.dart';
import 'package:iko_reliability_flutter/admin/extract_store.dart';
import 'package:iko_reliability_flutter/admin/parse_template.dart';
import 'package:iko_reliability_flutter/bin/consts.dart' show FileDetails;

void main() async {
  final templateBytes =
      File('assets/PM Request Template.xlsm').readAsBytesSync();
  final inspects = {'LNWK': 'Line Walk', 'LUBP': 'Lubrication Points'};
  Future<String?> resolveMeter(String? metername) async {
    if (metername == null || metername.isEmpty) {
      return null;
    }
    return inspects[metername.replaceAll(RegExp(r'\d+$'), '')];
  }

  // PM 1 mirrors the real TEST2 extraction for A0001D1INRE (AA): route with
  // two plain stops and two stops carrying child job plans.
  final pm1 = ExtractStore(siteid: 'AA', pmnum: 'A0001D1INRE')
    ..pm = {
      'pmnum': 'A0001D1INRE',
      'siteid': 'AA',
      'assetnum': 'A0001',
      'route': 'A0001D1INRE',
      'nextdate': '2026-07-01T00:00:00-04:00',
      'frequnit': 'DAYS',
      'frequency': '1',
      'description': 'Inspection Child Route with Job Plan Child Route',
    }
    ..jobplan = {
      'jpnum': 'AAA0001D1INRE',
      'iko_worktype': 'INR',
      'iko_conditions': 'CR01',
    }
    ..route = {
      'route': 'A0001D1INRE',
      'description':
          'Line Walk Inspection - 1 Days - Routine Inspection - Electrical',
      'routestopsbecome': 'CHILD',
    }
    ..joblabors = [
      {'craft': 'MECH-MW', 'quantity': 4, 'laborhrs': '4', 'laborcode': ''},
    ]
    ..jobtasks = [
      {
        'jptask': 10,
        'description': 'General',
        'description_longdescription': '<div>Follow safety rules</div>'
      },
      {'jptask': 20, 'description': 'Line Walk Inspection', 'description_longdescription': '<div>Inspect line</div>'},
      {'jptask': 30, 'description': 'Completion', 'description_longdescription': '<div>Wrap up</div>'},
    ]
    ..routeStops = [
      {'stopsequence': 1, 'assetnum': 'C6105'},
      {'stopsequence': 2, 'assetnum': 'C6115'},
      {'stopsequence': 12, 'assetnum': 'C7145', 'jpnum': 'AAC7145D1INRE'},
      {'stopsequence': 13, 'assetnum': 'H2125', 'jpnum': 'AAH2125D1INRE'},
    ]
    ..stopJobPlans = {
      'AAC7145D1INRE': _stopJp(
          'AAC7145D1INRE',
          'Easy Melt Storage Tank Piping - 1 Days - Routine Inspection',
          [
            {
              'jptask': 10,
              'description': 'Inspect Line Walk',
              'metername': 'LNWK01',
              'description_longdescription':
                  '<div>Inspect line walk carefully</div>'
            },
          ],
          craft: 'ELECT',
          hours: '0:30'),
      'AAH2125D1INRE': _stopJp(
          'AAH2125D1INRE',
          'Process Oil Tank - 1 Days - Routine Inspection - Electrical',
          [
            {
              'jptask': 10,
              'description': 'Inspect Line Walk',
              'metername': 'LNWK01',
              'description_longdescription':
                  '<div>Inspect line walk carefully</div>'
            },
          ],
          craft: 'ELECT',
          hours: '0:30'),
    };

  // PM 2 mirrors a GS lubrication PM with child job plans carrying several
  // tasks and meters each (the reported structure of GS C8025LUBM001).
  final pm2 = ExtractStore(siteid: 'GS', pmnum: 'C8025LUBM001')
    ..pm = {
      'pmnum': 'C8025LUBM001',
      'siteid': 'GS',
      'assetnum': 'C8025',
      'route': 'C8025LUBM001',
      'nextdate': '2026-01-15T00:00:00-05:00',
      'frequnit': 'DAYS',
      'frequency': '30',
      'description': 'Lubrication Walk',
    }
    ..jobplan = {'jpnum': 'GSC8025LUBM001', 'iko_worktype': 'LUB', 'iko_conditions': 'CR01'}
    ..route = {'route': 'C8025LUBM001', 'description': 'Lubrication Walk', 'routestopsbecome': 'CHILD'}
    ..joblabors = [
      {'craft': 'PROD', 'quantity': 1, 'laborhrs': '4:00', 'laborcode': ''},
    ]
    ..jobtasks = []
    ..jobmaterials = [
      {'itemnum': '12345', 'itemqty': '2', 'cost': '12.5'},
    ]
    ..jobservices = [
      {'itemnum': '22001', 'cost': '10', 'company': 'ACME'},
    ]
    ..routeStops = [
      for (var i = 1; i <= 3; i++)
        {'stopsequence': i, 'assetnum': 'SC0$i', 'jpnum': 'GSSC0${i}LUBM001'},
    ]
    ..stopJobPlans = {
      for (var i = 1; i <= 3; i++)
        'GSSC0${i}LUBM001': _stopJp(
            'GSSC0${i}LUBM001', 'Conveyor $i Lubrication', [
          {'jptask': 10, 'description': 'Grease bearings', 'metername': 'LUBP01'},
          {'jptask': 20, 'description': 'Oil chain', 'metername': 'LUBP02'},
        ], craft: 'PROD', hours: '1:00'),
    };

  final bytes =
      await buildImportTemplateWorkbook([pm1, pm2], templateBytes, resolveMeter);
  final excel = Excel.decodeBytes(bytes);

  for (final name in ['Main', 'Template Copy', 'List of Assets', 'Parent Finder', 'Observation List', 'Option List']) {
    _expect(excel.tables.keys.contains(name), 'template sheet preserved: $name');
  }
  _expect(excel.tables['List of Assets']!.maxRows >= 25179,
      'List of Assets data preserved');

  final main = excel.tables['Main']!;
  String cell(int row, int col) => _cell(main, row, col);

  // template head untouched
  _expect(cell(0, 0).contains('DON\u2019T REMOVE'), 'DON\u2019T REMOVE rows intact');
  _expect(cell(6, 0) == 'PM Asset/ Parent (Route)*:', 'label row 6 intact');

  // --- PM 1 block (rows 6-21 of the template) ---
  _expect(cell(7, 0) == 'A0001', 'PM1 asset at row 7');
  _expect(cell(7, 1) == 'Child', 'PM1 route type col1 = Child');
  _expect(cell(7, 2) == '2026-07-01', 'PM1 next due date');
  _expect(cell(7, 3) == 'AA', 'PM1 site');
  _expect(cell(7, 4) == 'Days', 'PM1 frequency unit word');
  _expect(cell(7, 6) == 'INR (Routine Inspection)', 'PM1 work type option string');
  _expect(cell(7, 7) == 'CR01 (Running)', 'PM1 condition option string');
  _expect(cell(7, 9) == 'Line Walk Inspection - 1 Days - Routine Inspection - Electrical',
      'PM1 route name');
  _expect(cell(8, 8) == 'A0001D1INRE', 'PM1 number in number row');
  _expect(cell(8, 9) == 'A0001D1INRE', 'PM1 route code literal (formula replaced)');

  // content: labour 12, tasks 13-15, route assets 16-17, stop tasks 18-19,
  // materials header 20, services header 21
  _expect(cell(12, 0) == 'MECH-MW: M', 'PM1 craft cell (option string)');
  _expect(cell(12, 3) == 'Task Route Assets (one per cell):',
      'PM1 route asset marker on first content row');
  _expect(cell(12, 7) != 'General', 'PM1 default task text cleared');
  _expect(cell(13, 3) != 'Task Route Assets (one per cell):',
      'no duplicate marker at row 13');
  _expect(cell(13, 6) == '10' && cell(13, 7) == 'General', 'PM1 task 10 at row 13');
  _expect(cell(14, 6) == '20', 'PM1 task 20 at row 14');
  _expect(cell(15, 6) == '30', 'PM1 task 30 at row 15');
  _expect(cell(15, 0) != 'Materials (Mapics Number)',
      'PM1 default materials header cleared off task row');
  _expect(cell(13, 8) == 'Follow safety rules', 'PM1 long description (html stripped)');
  _expect(cell(16, 3) == 'C6105', 'PM1 route asset C6105');
  _expect(cell(17, 3) == 'C6115', 'PM1 route asset C6115');
  _expect(cell(18, 4) == 'C7145', 'PM1 stop task asset C7145');
  _expect(cell(18, 5) == 'Line Walk', 'PM1 stop meter mapped to inspect value');
  _expect(cell(19, 4) == 'H2125', 'PM1 stop task asset H2125');
  _expect(cell(20, 0) == 'Materials (Mapics Number)', 'PM1 materials header');
  _expect(cell(21, 0) == 'Services (Mapics Number)', 'PM1 services header');
  for (var i = 11; i <= 21; i++) {
    _expect(cell(i, 0) != 'Add another labour (Optional)',
        'PM1 area row ${i + 1} has no leftover filler');
  }

  // --- PM 2 block (starts at row 22, PM1 content ended within rows 12-21) ---
  _expect(cell(22, 0) == 'PM Asset/ Parent (Route)*:', 'PM2 label row at row 23');
  _expect(cell(23, 0) == 'C8025', 'PM2 asset');
  _expect(cell(23, 1) == 'Child', 'PM2 route type');
  _expect(cell(23, 6) == 'LUB (Lubrication)', 'PM2 work type option string');
  _expect(cell(24, 8) == 'C8025LUBM001', 'PM2 number');
  _expect(cell(24, 9) == 'C8025LUBM001', 'PM2 route code');
  _expect(cell(25, 0) == '', 'PM2 blank row left empty');
  _expect(cell(26, 0) == 'Craft', 'PM2 section labels row');
  _expect(cell(27, 0) == 'Craft @ (Optional) Labour Code', 'PM2 craft header row');

  // content: labour 28, stop tasks 29-34 (marker on first task row 29),
  // materials header 35 + 1 row, services header 37 + 1 row
  _expect(cell(28, 0) == 'PROD: O', 'PM2 craft cell (Production = O)');
  _expect(cell(29, 3) == 'Task Route Assets (one per cell):',
      'PM2 marker on first stop task row');
  _expect(cell(29, 4) == 'SC01', 'PM2 stop 1 asset');
  _expect(cell(29, 5) == 'Lubrication Points', 'PM2 meter 1 mapped to inspect');
  _expect(cell(29, 6) == '10', 'PM2 first task 10');
  _expect(cell(30, 5) == 'Lubrication Points', 'PM2 meter 2 mapped to inspect');
  _expect(cell(30, 6) == '20', 'PM2 second task 20');
  _expect(cell(31, 4) == 'SC02', 'PM2 stop 2 asset');
  _expect(cell(33, 4) == 'SC03', 'PM2 stop 3 asset');
  _expect(cell(35, 0) == 'Materials (Mapics Number)', 'PM2 materials header');
  _expect(cell(36, 0) == '12345', 'PM2 material item');
  _expect(cell(37, 0) == 'Services (Mapics Number)', 'PM2 services header');
  _expect(cell(38, 0) == '22001', 'PM2 service item');
  _expect(cell(38, 2) == 'ACME', 'PM2 service vendor');

  // no duplicated/leftover section markers anywhere
  int occurrences(String text, int col) {
    var count = 0;
    for (var i = 0; i < main.maxRows; i++) {
      if (cell(i, col) == text) {
        count++;
      }
    }
    return count;
  }

  _expect(occurrences('Materials (Mapics Number)', 0) == 2,
      'exactly one materials header per PM');
  _expect(occurrences('Task Route Assets (one per cell):', 3) == 2,
      'exactly one route asset marker per PM');
  _expect(occurrences('Add another labour (Optional)', 0) == 0,
      'no leftover labour fillers');
  _expect(occurrences('Select Labour*', 0) == 0, 'no leftover labour placeholders');

  // --- parse back with the real parser (counter keyed per PM) ---
  final perPm = ParsedTemplate(nextDueDate: '', pmNumber: '', pmName: '')
      .fromExcel(FileDetails(name: 'pm_request_export.xlsx', bytes: bytes))['pm_request_export.xlsx']
      as Map;
  final parsed1 = perPm[1] as ParsedTemplate;
  final parsed2 = perPm[2] as ParsedTemplate;

  _expect(parsed1.pmNumber == 'A0001D1INRE', 'parsed PM1 number');
  _expect(parsed1.siteId == 'AA', 'parsed PM1 site');
  _expect(parsed1.pmAsset == 'A0001', 'parsed PM1 asset');
  _expect(parsed1.workOrderType == 'INR', 'parsed PM1 work type');
  _expect(parsed1.processCondition == 'CR01', 'parsed PM1 condition');
  _expect(parsed1.frequency == 1, 'parsed PM1 frequency');
  _expect(parsed1.frequencyUnit == 'D', 'parsed PM1 frequency unit');
  _expect(parsed1.routeCode == 'A0001D1INRE', 'parsed PM1 route code');
  _expect(parsed1.routeName != null && parsed1.routeName != 'Select Route (Optional)',
      'parsed PM1 route name');
  _expect(parsed1.crafts.length == 1, 'parsed PM1 crafts');
  _expect(parsed1.crafts.first.laborType == 'M', 'parsed PM1 labor type M');
  _expect(parsed1.crafts.first.quantity == 4, 'parsed PM1 craft quantity');
  _expect(parsed1.crafts.first.laborCode == '', 'parsed PM1 craft has no labor code');
  _expect(parsed1.tasks.length == 5, 'parsed PM1 tasks (3 main + 2 stop tasks)');
  _expect(parsed1.tasks.where((t) => t.assetNumber != null).length == 2,
      'parsed PM1 stop tasks carry asset numbers');
  _expect(
      parsed1.tasks
          .where((t) => t.assetNumber != null)
          .every((t) => t.metername == 'Line Walk'),
      'parsed PM1 stop task meters');
  _expect(
      parsed1.assets.toString() == '[C6105, C6115, C7145, H2125]',
      'parsed PM1 assets (2 route assets + 2 stop task assets)');
  _expect(parsed1.materials.isEmpty && parsed1.services.isEmpty,
      'parsed PM1 has no materials/services');

  _expect(parsed2.pmNumber == 'C8025LUBM001', 'parsed PM2 number');
  _expect(parsed2.siteId == 'GS', 'parsed PM2 site');
  _expect(parsed2.workOrderType == 'LUB', 'parsed PM2 work type');
  _expect(parsed2.tasks.length == 6, 'parsed PM2 all 6 child tasks (multi task stop JPs)');
  _expect(parsed2.tasks.where((t) => t.assetNumber == 'SC01').length == 2,
      'parsed PM2 stop 1 child JP carries BOTH of its tasks');
  _expect(parsed2.tasks.where((t) => t.assetNumber == 'SC02').length == 2,
      'parsed PM2 stop 2 child JP carries BOTH of its tasks');
  _expect(parsed2.tasks.where((t) => t.assetNumber == 'SC03').length == 2,
      'parsed PM2 stop 3 child JP carries BOTH of its tasks');
  _expect(parsed2.crafts.length == 1 && parsed2.crafts.first.laborType == 'O',
      'parsed PM2 Production craft maps to O');
  _expect(parsed2.materials.length == 1, 'parsed PM2 materials');
  _expect(parsed2.materials.first.itemNumber == '12345', 'parsed PM2 material item');
  _expect(parsed2.materials.first.quantity == 2, 'parsed PM2 material quantity');
  _expect(parsed2.services.length == 1, 'parsed PM2 services');
  _expect(parsed2.services.first.vendorId == 'ACME', 'parsed PM2 service vendor');
  final pm2Assets = parsed2.assets;
  _expect(pm2Assets.where((a) => a == 'SC01').length == 2 &&
          pm2Assets.where((a) => a == 'SC02').length == 2 &&
          pm2Assets.where((a) => a == 'SC03').length == 2,
      'parsed PM2 assets from all stop task rows');

  // ignore: avoid_print
  print('ALL CHECKS PASSED');
}

FetchedJobPlan _stopJp(String jpnum, String description, List<Map<String, Object?>> tasks,
    {required String craft, required String hours}) {
  return FetchedJobPlan({'jpnum': jpnum, 'description': description})
    ..jobtasks = List<dynamic>.from(tasks)
    ..joblabors = [
      {'craft': craft, 'quantity': 1, 'laborhrs': hours, 'laborcode': ''},
    ];
}

String _cell(Sheet sheet, int row, int col) {
  final prow = sheet.row(row);
  return prow.length > col ? prow[col]?.value?.toString() ?? '' : '';
}

void _expect(bool condition, String label) {
  if (!condition) {
    throw StateError('FAIL: $label');
  }
  // ignore: avoid_print
  print('ok: $label');
}
