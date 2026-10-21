// Pure Dart module: builds a PM request template workbook from extracted
// PM data. No Flutter/DB imports so it can be unit tested directly.
//
// The workbook is generated from scratch (a modified template re-encoded by
// excel_plus opened as corrupt in Excel) but reproduces the layout and look
// of the blank PM request template: rows 0-5 'DON'T REMOVE THIS LINE', then
// one 16-row form per PM (label / data / number / blank / section labels /
// craft header rows followed by the labour, task, route asset, materials and
// services rows). The parser contract of ParsedTemplate.fromExcel must keep
// holding - see the round trip test.
import 'dart:typed_data';

import 'package:excel_plus/excel_plus.dart';
import 'package:iko_reliability_flutter/admin/extract_store.dart';
import 'package:iko_reliability_flutter/admin/parse_template.dart';
import 'package:iko_reliability_flutter/bin/consts.dart';

/// Row the first PM block starts at (rows 0-5 hold the DON'T REMOVE lines).
const _pmTemplateFirstBlockRow = 6;

/// Row of the PM data (asset, route type, due date, ...) inside a PM block,
/// relative to the block's base row (the label row).
const _pmBlockDataRow = 1;

/// Rows of one PM form block: label, data, number, blank, section labels,
/// craft header, then 10 content rows.
const _pmBlockHeight = 16;

/// Dropdown option strings of the PM request template ('Option List' sheet)
/// so written values stay valid when the request template is used.
class TemplateOptions {
  final workTypes = <String, String>{};
  final crafts = <String, String>{};
  final conditions = <String, String>{};

  /// Craft prefix (ELECT/MECH-MW/PROD) used by the template for a labor type.
  String craftPrefix(String letter) {
    final option = crafts[letter];
    if (option != null) {
      final split = option.indexOf(':');
      if (split > 0) {
        return option.substring(0, split).trim();
      }
    }
    const fallback = {'E': 'ELECT', 'M': 'MECH-MW', 'O': 'PROD'};
    return fallback[letter] ?? letter;
  }
}

/// The PM request template's dropdown options (from its 'Option List' sheet).
TemplateOptions templateOptions() {
  final options = TemplateOptions();
  const workTypes = {
    'PPM': 'PPM (Preventative Maintenance)',
    'CAL': 'CAL (Calibration)',
    'ENV': 'ENV (Environmental)',
    'HKG': 'HKG (Housekeeping)',
    'INR': 'INR (Routine Inspection)',
    'LC1': 'LC1 (Life Cycle)',
    'LUB': 'LUB (Lubrication)',
    'PDM': 'PDM (Predictive Maintenance)',
    'PEM': 'PEM (Pre-emptive Maintenance)',
    'PRO': 'PRO (Process Maintenance)',
    'SAF': 'SAF (Safety)',
  };
  options.workTypes.addAll(workTypes);
  const crafts = {'E': 'ELECT: E', 'M': 'MECH-MW: M', 'O': 'PROD: O'};
  options.crafts.addAll(crafts);
  const conditions = {'CR01': 'CR01 (Running)', 'CS01': 'CS01 (Stopped)'};
  options.conditions.addAll(conditions);
  return options;
}

/// Maps a Maximo job labor craft code (ELECT/MECH-MW/PROD) to the template
/// labor type code (E/M/O).
String laborTypeFromCraft(String? craft) {
  if (craft == null || craft.isEmpty) {
    return '';
  }
  final first = craft.substring(0, 1).toUpperCase();
  if (first == 'P') {
    return 'O'; // Production is code O but Maximo craft is PROD
  }
  return first;
}

/// Parses a Maximo labor hours value which can be 'HH:MM' or a plain number.
double hoursFromRow(dynamic row) {
  final value = rowValue(row, 'LABORHRS');
  if (value.isEmpty) {
    return 0.0;
  }
  if (value.contains(':')) {
    return parseTime(value);
  }
  return double.tryParse(value) ?? 0.0;
}

/// Formats a Maximo ISO datetime (yyyy-MM-ddTHH...) as yyyy-MM-dd.
String _dateOnly(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) {
    return '';
  }
  return isoDate.length > 10 ? isoDate.substring(0, 10) : isoDate;
}

/// Route type label ('None'/'Task'/'Child') for a PM block's route dropdown.
String routeTypeLabel(ExtractStore store) {
  final stored = rowValue(store.route ?? {}, 'ROUTESTOPSBECOME').toUpperCase();
  if (stored.startsWith('CH')) {
    return 'Child';
  }
  if (stored.startsWith('TA')) {
    return 'Task';
  }
  if (store.route == null) {
    return 'None';
  }
  for (final row in store.routeStops) {
    if ((fieldOf(row, 'jpnum') ?? '').isNotEmpty) {
      return 'Child';
    }
  }
  return 'Task';
}

/// Styles matching the blank PM request template's 'Main' sheet.
class _FormStyles {
  final gray = ExcelColor.fromHexString('#FFD9D9D9');
  final paleGreen = ExcelColor.fromHexString('#FFEBF1DE');
  final paleYellow = ExcelColor.fromHexString('#FFFFEB9C');
  final brown = ExcelColor.fromHexString('#FF9C6500');

  late final plain = CellStyle(
    leftBorder: _thin(),
    rightBorder: _thin(),
    topBorder: _thin(),
    bottomBorder: _thin(),
  );

  /// Filled label cell (bold by default, as in the template's label rows).
  late final label = CellStyle(
    bold: true,
    backgroundColorHex: gray,
    leftBorder: _thin(),
    rightBorder: _thin(),
    topBorder: _thin(),
    bottomBorder: _thin(),
  );

  /// Filled label cell without bold (quantity / cost headers, services).
  late final labelPlain = CellStyle(
    backgroundColorHex: gray,
    leftBorder: _thin(),
    rightBorder: _thin(),
    topBorder: _thin(),
    bottomBorder: _thin(),
  );

  /// Dropdown-style cell (pale green fill like the template's work order,
  /// process condition and labour cells).
  late final dropdown = CellStyle(
    backgroundColorHex: paleGreen,
    leftBorder: _thin(),
    rightBorder: _thin(),
    topBorder: _thin(),
    bottomBorder: _thin(),
  );

  /// Route cell (pale yellow fill, brown font, like the template's route
  /// name / code cells).
  late final route = CellStyle(
    backgroundColorHex: paleYellow,
    fontColorHex: brown,
    leftBorder: _thin(),
    rightBorder: _thin(),
    topBorder: _thin(),
    bottomBorder: _thin(),
  );

  /// Free (borderless) cell for task/route asset/material/service rows, as
  /// in the template's content area.
  late final free = CellStyle();

  Border _thin() => Border(borderStyle: BorderStyle.Thin);
}

/// Builds a PM request workbook filled with [stores], one 16-row form block
/// per PM on the 'Main' sheet.
///
/// Child route job plans become task rows with asset numbers (all of their
/// tasks), plain stops become 'Task Route Assets (one per cell)' rows.
/// [resolveMeter] maps an extracted Maximo meter name (e.g. 'LNWK01') to the
/// meter text the template expects.
/// Returns the encoded .xlsx bytes.
Future<Uint8List> buildImportTemplateWorkbook(
  List<ExtractStore> stores,
  Future<String?> Function(String? metername) resolveMeter,
) async {
  final excel = Excel.createExcel();
  excel.rename(excel.getDefaultSheet() ?? 'Sheet1', 'Main');
  final main = excel.tables['Main'];
  if (main == null) {
    throw StateError('Failed to create the Main sheet');
  }
  final options = templateOptions();
  final styles = _FormStyles();

  void put(int row, int column, CellValue? value, CellStyle style) {
    main.updateCell(
      CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row),
      value,
      cellStyle: style,
    );
  }

  // the template's header protection rows
  for (var row = 0; row < _pmTemplateFirstBlockRow; row++) {
    put(row, 0, TextCellValue('DON\u2019T REMOVE THIS LINE'), styles.plain);
  }

  // meter lookups can repeat across PMs, cache per export run
  final meterInspects = <String, String?>{};
  Future<String?> meterInspect(String? metername) async {
    if (metername == null || metername.isEmpty) {
      return null;
    }
    meterInspects[metername] ??= await resolveMeter(metername);
    return meterInspects[metername];
  }

  Future<void> putTaskCells(
      int row, Map<dynamic, dynamic> task, String? stopAsset) async {
    final asset = stopAsset ?? fieldOf(task, 'assetnum');
    if (asset != null && asset.toString().isNotEmpty) {
      put(row, 4, TextCellValue(asset.toString().toUpperCase()), styles.free);
    }
    final meter = fieldOf(task, 'metername');
    if (meter != null && meter.toString().isNotEmpty) {
      final inspect = await meterInspect(meter.toString());
      if (inspect != null && inspect.isNotEmpty) {
        put(row, 5, TextCellValue(inspect), styles.dropdown);
      }
    }
    final jptask = fieldOf(task, 'jptask');
    if (jptask != null) {
      put(row, 6, IntCellValue(int.tryParse(jptask.toString()) ?? 0), styles.free);
    }
    put(row, 7, TextCellValue(fieldOf(task, 'description') ?? ''), styles.free);
    put(row, 8,
        TextCellValue(stripHtml(fieldOf(task, 'description_longdescription'))),
        styles.free);
  }

  /// Writes labour, task, route asset, materials and services rows of one PM
  /// starting at [row], returns the next free row.
  Future<int> writeContent(ExtractStore store, int row) async {
    // right side notes of the form (first two content rows)
    put(row, 9, TextCellValue('PM Options'), styles.label);
    put(row + 1, 9, TextCellValue('Safety Device (Y/N)'), styles.label);

    // the route asset header sits in its fixed form slot on the first
    // content row (D13 of the first template block); every later cell in
    // the block that holds a value in this column is then parsed as a
    // route asset
    if (store.routeStops.isNotEmpty) {
      put(row, 3, TextCellValue('Task Route Assets (one per cell):'),
          styles.label);
    }

    // labour (craft) rows
    for (final labor in store.joblabors) {
      final craft = rowValue(labor, 'CRAFT');
      if (craft.isEmpty) {
        continue;
      }
      final letter = laborTypeFromCraft(craft);
      final option = options.crafts[letter];
      final laborCode = rowValue(labor, 'LABORCODE');
      put(
          row,
          0,
          TextCellValue(laborCode.isEmpty
              ? (option ?? '${options.craftPrefix(letter)}: $letter')
              : '${options.craftPrefix(letter)}@$laborCode'),
          styles.dropdown);
      put(row, 1, IntCellValue(int.tryParse(rowValue(labor, 'QUANTITY')) ?? 1),
          styles.plain);
      put(row, 2, DoubleCellValue(hoursFromRow(labor)), styles.plain);
      row++;
    }

    // tasks of the PM's own job plan (no asset -> main job plan)
    for (final task in store.jobtasks) {
      putTaskCells(row, Map<String, dynamic>.from(task as Map), null);
      row++;
    }

    // route stops: the tasks of each stop's job plan become task rows with
    // the stop asset number; plain stops become route asset rows
    for (final stop in store.routeStops) {
      final stopJpnum = fieldOf(stop, 'jpnum') ?? '';
      final stopAsset = (fieldOf(stop, 'assetnum') ?? '').toUpperCase();
      final plan = stopJpnum.isEmpty ? null : store.stopJobPlans[stopJpnum];
      final stopTasks = plan?.jobtasks ?? const [];
      final taskSeq = int.tryParse(fieldOf(stop, 'stopsequence') ?? '') ?? 0;
      if (stopTasks.isEmpty) {
        // plain stop (or stop job plan missing): write as route asset
        if (stopAsset.isEmpty) {
          continue;
        }
        put(row, 3, TextCellValue(stopAsset), styles.free);
        row++;
        continue;
      }
      for (final t in stopTasks) {
        final task = Map<String, dynamic>.from(t as Map);
        await putTaskCells(row, task, stopAsset.isEmpty ? null : stopAsset);
        // ensure a task number / description exists even if the child job
        // task row lacks them
        if (int.tryParse(fieldOf(task, 'jptask') ?? '') == null) {
          put(row, 6, IntCellValue(taskSeq), styles.free);
        }
        if (fieldOf(task, 'description') == null) {
          put(row, 7, TextCellValue(fieldOf(stop, 'description') ?? ''),
              styles.free);
        }
        row++;
      }
    }

    // materials section
    put(row, 0, TextCellValue('Materials (Mapics Number)'), styles.labelPlain);
    put(row, 1, TextCellValue('Quantity'), styles.labelPlain);
    put(row, 2, TextCellValue('Cost (Optional)'), styles.labelPlain);
    put(row, 9, TextCellValue('Urgency Level (1-4)'), styles.label);
    row++;
    for (final material in store.jobmaterials) {
      put(row, 0, TextCellValue(rowValue(material, 'ITEMNUM')), styles.plain);
      put(row, 1,
          DoubleCellValue(double.tryParse(rowValue(material, 'ITEMQTY')) ?? 1),
          styles.plain);
      final cost = double.tryParse(rowValue(material, 'COST'));
      if (cost != null) {
        put(row, 2, DoubleCellValue(cost), styles.plain);
      }
      row++;
    }

    // services section
    put(row, 0, TextCellValue('Services (Mapics Number)'), styles.labelPlain);
    put(row, 1, TextCellValue('Cost (Optional)'), styles.labelPlain);
    put(row, 2, TextCellValue('Vendor #'), styles.labelPlain);
    row++;
    for (final service in store.jobservices) {
      put(row, 0, TextCellValue(rowValue(service, 'ITEMNUM')), styles.plain);
      final cost = double.tryParse(rowValue(service, 'COST'));
      if (cost != null) {
        put(row, 1, DoubleCellValue(cost), styles.plain);
      }
      put(row, 2, TextCellValue(rowValue(service, 'COMPANY')), styles.plain);
      row++;
    }
    return row;
  }

  /// Writes the label / data rows of a PM block (base row = label row).
  void writeHead(ExtractStore store, int base) {
    final route = fieldOf(store.route ?? {}, 'route');
    put(base, 0, TextCellValue('PM Asset/ Parent (Route)*:'), styles.label);
    put(base, 1, TextCellValue('Route:'), styles.label);
    put(base, 2, TextCellValue('Next Due Date (MM/DD/YYYY):'), styles.label);
    put(base, 3, TextCellValue('Site ID*:'), styles.label);
    put(base, 4, TextCellValue('Frequency Unit*:'), styles.label);
    put(base, 5, TextCellValue('Frequency*:'), styles.label);
    put(base, 6, TextCellValue('Work Order Types*:'), styles.label);
    put(base, 7, TextCellValue('Stopped/Running'), styles.label);
    put(base, 8, TextCellValue('Suggested PM Name'), styles.label);
    put(base, 9, TextCellValue('Route Name'), styles.label);
    put(base, 10, TextCellValue('PM Number'), styles.label);

    final dataRow = base + _pmBlockDataRow;
    final workType = fieldOf(store.jobplan ?? {}, 'iko_worktype') ?? '';
    final condition = fieldOf(store.jobplan ?? {}, 'iko_conditions') ?? '';
    const freqWords = {
      'DAYS': 'Days',
      'WEEKS': 'Weeks',
      'MONTHS': 'Months',
      'YEARS': 'Years',
    };
    final rawFreqUnit =
        (fieldOf(store.pm, 'frequnit') ?? '').toString().toUpperCase();
    // fall back to the template's own unfilled dropdowns for missing values
    // so the parser's substring calls never fail on empty cells
    final freqWord = freqWords[rawFreqUnit] ??
        (rawFreqUnit.isEmpty ? 'Select Frequency' : rawFreqUnit);
    final asset = fieldOf(store.pm, 'assetnum') ?? '';
    if (asset.isNotEmpty) {
      put(dataRow, 0, TextCellValue(asset), styles.plain);
    }
    put(dataRow, 1, TextCellValue(routeTypeLabel(store)), styles.dropdown);
    put(dataRow, 2, TextCellValue(_dateOnly(fieldOf(store.pm, 'nextdate'))),
        styles.plain);
    put(dataRow, 3, TextCellValue(store.siteid), styles.plain);
    put(dataRow, 4, TextCellValue(freqWord), styles.plain);
    final frequency = int.tryParse(fieldOf(store.pm, 'frequency') ?? '');
    if (frequency != null) {
      put(dataRow, 5, IntCellValue(frequency), styles.plain);
    }
    // a blank Work Order Type / Stopped-Running stays a blank dropdown
    // cell: placeholder texts like 'Select Work Order' would parse as
    // bogus 'Sel'/'Sele' codes when the file is loaded into pm_check
    put(
        dataRow,
        6,
        TextCellValue(workType.isEmpty ? '' : options.workTypes[workType] ?? workType),
        styles.dropdown);
    put(
        dataRow,
        7,
        TextCellValue(condition.isEmpty
            ? ''
            : options.conditions[condition] ?? condition),
        styles.dropdown);
    final pmName = fieldOf(store.pm, 'description') ?? store.pmnum;
    if (pmName.isNotEmpty) {
      put(dataRow, 8, TextCellValue(pmName), styles.plain);
    }
    put(dataRow, 9,
        TextCellValue(route == null || route.isEmpty
            ? 'Select Route (Optional)'
            : fieldOf(store.route!, 'description') ?? ''),
        styles.route);

    // the existing PM number as reference beside the name (K8, col 10);
    // nothing is written on the number row below (I9/J9): a route code
    // there makes generateName look for a non-existing route number and
    // pm_check errors out; the number is purely informational for knowing
    // which PM a template came from
    if (store.pmnum.isNotEmpty) {
      put(dataRow, 10, TextCellValue(store.pmnum), styles.plain);
    }
  }

  /// Writes the static form rows between the number row and the content
  /// rows of a PM block (blank row, section labels and the craft header).
  void writeFormExtras(int base) {
    // base + 3 is left blank, mirroring the template
    put(base + 4, 0, TextCellValue('Craft'), styles.label);
    put(base + 4, 3, TextCellValue('Replacement (ONLY for LC1)'), styles.label);
    put(base + 4, 4, TextCellValue('Job Task:'), styles.label);
    put(base + 4, 9, TextCellValue('IKO PM History Notes'), styles.label);
    put(base + 5, 0, TextCellValue('Craft @ (Optional) Labour Code'),
        styles.label);
    put(base + 5, 1, TextCellValue('Quantity'), styles.labelPlain);
    put(base + 5, 2, TextCellValue('Hours'), styles.labelPlain);
    put(base + 5, 4, TextCellValue('Child Route Assets:'), styles.free);
    put(base + 5, 5, TextCellValue('Inspect:'), styles.free);
    put(base + 5, 6, TextCellValue('Task Order:'), styles.free);
    put(base + 5, 7, TextCellValue('Short Description '), styles.free);
    put(base + 5, 8, TextCellValue('Long Description'), styles.free);
  }

  // one form block per PM, the first starting where the template's starts
  var base = _pmTemplateFirstBlockRow;
  for (final store in stores) {
    writeHead(store, base);
    writeFormExtras(base);
    final end = await writeContent(store, base + 6);
    // the next form starts where the template would place it (base + block
    // height) unless this PM's content overflowed past that; one blank row
    // is always kept between the end of a form and the next one so the
    // file stays easy to edit manually
    final next = end > base + _pmBlockHeight ? end : base + _pmBlockHeight;
    base = next + 1;
  }

  return Uint8List.fromList(excel.encode()!);
}
