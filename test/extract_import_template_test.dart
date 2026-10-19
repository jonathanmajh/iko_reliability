// Round-trip check for the PM request template export:
// builds a brand-new workbook from extracted stores through the real
// buildImportTemplateWorkbook (no bundled template involved), verifies the
// layout and template look, and parses it back with the real
// ParsedTemplate.fromExcel.
// Run: dart run test/extract_import_template_test.dart
import 'package:excel_plus/excel_plus.dart';
import 'package:iko_reliability_flutter/admin/extract_import_template.dart';
import 'package:iko_reliability_flutter/admin/extract_store.dart';
import 'package:iko_reliability_flutter/admin/parse_template.dart';
import 'package:iko_reliability_flutter/bin/consts.dart' show FileDetails;

void main() async {
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

  final bytes = await buildImportTemplateWorkbook([pm1, pm2], resolveMeter);
  final excel = Excel.decodeBytes(bytes);

  _expect(excel.tables.keys.toList().join(',') == 'Main', 'workbook holds only Main');

  final main = excel.tables['Main']!;
  String cell(int row, int col) => _cell(main, row, col);
  CellStyle? style(int row, int col) {
    final prow = main.row(row);
    return prow.length > col ? prow[col]?.cellStyle : null;
  }

  String fill(int row, int col) =>
      style(row, col)?.backgroundColor.colorHex ?? '';
  String hex(String argb) =>
      ExcelColor.fromHexString(argb.replaceFirst('#', '')).colorHex;
  const gray = '#FFD9D9D9';
  const paleGreen = '#FFEBF1DE';
  const paleYellow = '#FFFFEB9C';

  // template head reproduction (rows 0-5 + first PM block starts at row 6)
  for (var i = 0; i < 6; i++) {
    _expect(cell(i, 0).contains('DON\u2019T REMOVE'), 'DON\u2019T REMOVE row $i');
  }
  _expect(cell(6, 0) == 'PM Asset/ Parent (Route)*:', 'label row 6 intact');
  _expect(fill(6, 0) == hex(gray) && style(6, 0)?.isBold == true,
      'label style (gray fill, bold)');
  _expect(fill(11, 0) == hex(gray) && style(11, 0)?.isBold == true,
      'craft header label style');
  _expect(fill(11, 1) == hex(gray) && style(11, 1)?.isBold == false,
      'quantity header style (gray, not bold)');

  // --- PM 1 block (rows 6-21) ---
  _expect(cell(7, 0) == 'A0001', 'PM1 asset at row 7');
  _expect(cell(7, 1) == 'Child', 'PM1 route type col1 = Child');
  _expect(cell(7, 2) == '2026-07-01', 'PM1 next due date');
  _expect(cell(7, 3) == 'AA', 'PM1 site');
  _expect(cell(7, 4) == 'Days', 'PM1 frequency unit word');
  _expect(cell(7, 6) == 'INR (Routine Inspection)', 'PM1 work type option string');
  _expect(cell(7, 7) == 'CR01 (Running)', 'PM1 condition option string');
  _expect(fill(7, 7) == hex(paleGreen), 'condition cell pale green (dropdown look)');
  _expect(cell(7, 8) == 'Inspection Child Route with Job Plan Child Route',
      'PM1 name');
  _expect(cell(7, 9) == 'Line Walk Inspection - 1 Days - Routine Inspection - Electrical',
      'PM1 route name');
  _expect(fill(7, 9) == hex(paleYellow) &&
      style(7, 9)?.fontColor.colorHex == hex('#FF9C6500'),
      'route cell style (pale yellow, brown font)');
  _expect(fill(8, 9) == 'none' || fill(8, 9) == '',
      'number row not styled as route anymore');
  _expect(cell(6, 10) == 'PM Number', 'PM Number label at K7');
  _expect(cell(7, 10) == 'A0001D1INRE',
      'PM1 existing number as reference at K8');
  _expect(cell(8, 8) == '' && cell(8, 9) == '',
      'PM1 number row (I9/J9) left empty - no route code reaches the parser');

  // form annotations reproduced from the template
  _expect(cell(10, 0) == 'Craft', 'section label Craft');
  _expect(cell(10, 3) == 'Replacement (ONLY for LC1)', 'section label Replacement');
  _expect(cell(10, 4) == 'Job Task:', 'section label Job Task');
  _expect(cell(10, 9) == 'IKO PM History Notes', 'right note IKO PM History Notes');
  _expect(cell(12, 9) == 'PM Options', 'right note PM Options on first content row');
  _expect(cell(13, 9) == 'Safety Device (Y/N)', 'right note Safety Device');
  _expect(cell(11, 2) == 'Hours', 'craft header Hours');

  // content: labour 12, tasks 13-15 (marker on first task row), route assets
  // 16-17, stop tasks 18-19, materials header 20, services header 21
  _expect(cell(12, 0) == 'MECH-MW: M', 'PM1 craft cell (option string)');
  _expect(fill(12, 0) == hex(paleGreen), 'craft cell pale green (dropdown look)');
  _expect(cell(12, 3) == 'Task Route Assets (one per cell):',
      'PM1 marker in its fixed slot on the first content row (D13)');
  _expect(fill(12, 3) == hex(gray), 'marker styled as label');
  _expect(cell(13, 3) == '', 'no duplicate marker on task rows');
  _expect(fill(13, 4) != hex(gray) && fill(13, 4) != hex(paleGreen),
      'task cells stay plain (no fill)');
  _expect(cell(13, 6) == '10' && cell(13, 7) == 'General', 'PM1 task 10 at row 13');
  _expect(cell(14, 6) == '20', 'PM1 task 20 at row 14');
  _expect(cell(15, 6) == '30', 'PM1 task 30 at row 15');
  _expect(cell(13, 8) == 'Follow safety rules', 'PM1 long description (html stripped)');
  _expect(cell(16, 3) == 'C6105', 'PM1 route asset C6105');
  _expect(cell(17, 3) == 'C6115', 'PM1 route asset C6115');
  _expect(cell(18, 4) == 'C7145', 'PM1 stop task asset C7145');
  _expect(cell(18, 5) == 'Line Walk', 'PM1 stop meter mapped to inspect value');
  _expect(cell(19, 4) == 'H2125', 'PM1 stop task asset H2125');
  _expect(cell(20, 0) == 'Materials (Mapics Number)', 'PM1 materials header');
  _expect(fill(20, 0) == hex(gray) && style(20, 0)?.isBold == false,
      'materials header style (gray, not bold)');
  _expect(cell(20, 9) == 'Urgency Level (1-4)', 'right note Urgency Level');
  _expect(cell(21, 0) == 'Services (Mapics Number)', 'PM1 services header');

  // --- PM 2 block (starts at row 22, PM1 content ended within rows 12-21) ---
  _expect(cell(22, 0) == 'PM Asset/ Parent (Route)*:', 'PM2 label row at row 22');
  _expect(cell(23, 0) == 'C8025', 'PM2 asset');
  _expect(cell(23, 1) == 'Child', 'PM2 route type');
  _expect(cell(23, 6) == 'LUB (Lubrication)', 'PM2 work type option string');
  _expect(cell(22, 10) == 'PM Number', 'PM2 PM Number label at K7');
  _expect(cell(23, 10) == 'C8025LUBM001', 'PM2 number at K8');
  _expect(cell(25, 8) == '' && cell(25, 9) == '', 'PM2 number row left empty');
  _expect(cell(25, 0) == '', 'PM2 blank row left empty');
  _expect(cell(26, 0) == 'Craft', 'PM2 section labels row');
  _expect(cell(27, 0) == 'Craft @ (Optional) Labour Code', 'PM2 craft header row');

  // content: labour 28, stop tasks 29-34 (marker on first task row 29),
  // materials header 35 + 1 row, services header 37 + 1 row
  _expect(cell(28, 0) == 'PROD: O', 'PM2 craft cell (Production = O)');
  _expect(cell(28, 3) == 'Task Route Assets (one per cell):',
      'PM2 marker in its fixed slot on the first content row');
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

  // no duplicated section markers anywhere
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
  _expect(occurrences('PM Options', 9) == 2, 'exactly one PM Options note per PM');
  _expect(occurrences('DON\u2019T REMOVE THIS LINE', 0) == 6,
      'exactly the six top protection rows');

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
  _expect(parsed1.routeCode == null,
      'parsed PM1 route code null (nothing written at J9 -> pm_check generates cleanly)');
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
