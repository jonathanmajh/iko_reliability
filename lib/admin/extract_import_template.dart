// Pure Dart module: builds a PM request template workbook from extracted
// PM data. No Flutter/an DB imports so it can be unit tested directly.
import 'dart:typed_data';

import 'package:excel_plus/excel_plus.dart';
import 'package:iko_reliability_flutter/admin/extract_store.dart';
import 'package:iko_reliability_flutter/admin/parse_template.dart';
import 'package:iko_reliability_flutter/bin/consts.dart';

/// Asset path of the bundled blank PM request template (.xlsm; the VBA is
/// not kept, saving produces a macro free .xlsx).
const pmRequestTemplateAsset = 'assets/PM Request Template.xlsm';

/// Row of the PM data (asset, route type, due date, ...) inside the first
/// template block on the 'Main' sheet of the PM request template.
const _pmTemplateMainDataRow = 7;

/// First row the first PM block's content (labour/tasks/materials/services)
/// may occupy, and last row of the template's first block.
const _pmTemplateMainContentFirstRow = 12;
const _pmTemplateMainContentLastRow = 21;

/// Where subsequent PM block skeletons start (first 22 rows hold the
/// template's own first block).
const _pmTemplateSecondBlockRow = 22;

/// Row on the template's 'Template Copy' sheet holding the content-row /
/// material header / material row / service header styles.
const _pmTemplateStyleSourceSheet = 'Template Copy';

/// A default template cell whose text can be removed when unused.
class _TemplateDefaultCell {
  final int row;
  final int col;
  final CellStyle? style;
  _TemplateDefaultCell(this.row, this.col, this.style);
}

/// Dropdown option strings of the PM request template, read from its
/// 'Option List' sheet so written values stay valid for its lookups.
class TemplateOptions {
  final workTypes = <String, String>{}; // 'PPM' -> 'PPM (Preventative Maintenance)'
  final crafts = <String, String>{}; // 'E' -> 'ELECT: E'
  final conditions = <String, String>{}; // 'CR01' -> 'CR01 (Running)'

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

/// Reads the dropdown option strings from the template's 'Option List' sheet.
TemplateOptions readTemplateOptions(Excel excel) {
  final options = TemplateOptions();
  final sheet = excel.tables['Option List'];
  if (sheet == null) {
    return options;
  }
  final typePattern = RegExp(r'^(?:[A-Z0-9]{3}) \(');
  final craftPattern = RegExp(r'^([A-Z][A-Z-]*):\s*([EMO])$');
  final conditionPattern = RegExp(r'^([A-Z]{2}\d{2}) \(');
  for (var i = 0; i < sheet.maxRows; i++) {
    final row = sheet.row(i);
    // column G (6) is the full work order type option, e.g. 'INR (Routine Inspection)'
    if (row.length > 6) {
      final full = row[6]?.value?.toString() ?? '';
      if (typePattern.hasMatch(full)) {
        options.workTypes[full.substring(0, 3)] = full;
      }
    }
    // column D (3) holds process condition and craft options
    if (row.length > 4) {
      final value = row[3]?.value?.toString() ?? '';
      final craftMatch = craftPattern.firstMatch(value);
      if (craftMatch != null) {
        options.crafts[craftMatch.group(2)!] = value;
        continue;
      }
      final conditionMatch = conditionPattern.firstMatch(value);
      if (conditionMatch != null) {
        options.conditions[conditionMatch.group(1)!] = value;
      }
    }
  }
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

/// Builds the 'Main' sheet of a copy of the blank PM request template filled
/// with [stores].
///
/// The template's formatting and row layout is preserved: the first PM is
/// written into the template's own first block (rows 6-21) and every further
/// PM repeats the blank form layout (see the template's 'Template Copy'
/// sheet). Child route job plans become task rows with asset numbers (all of
/// their tasks), plain stops become 'Task Route Assets' rows.
/// [resolveMeter] maps an extracted Maximo meter name (e.g. 'LNWK01') to the
/// meter text the template expects.
/// Returns the encoded .xlsx bytes.
Future<Uint8List> buildImportTemplateWorkbook(
  List<ExtractStore> stores,
  Uint8List templateBytes,
  Future<String?> Function(String? metername) resolveMeter,
) async {
  final excel = Excel.decodeBytes(templateBytes);
  final main = excel.tables['Main'];
  if (main == null) {
    throw ArgumentError('Invalid PM Request Template (missing Main sheet)');
  }
  final options = readTemplateOptions(excel);
  final form = excel.tables[_pmTemplateStyleSourceSheet];

  // cell style of the blank form (source row of the 'Template Copy' sheet)
  CellStyle? formStyle(int formRow, int column) {
    if (form == null) {
      return null;
    }
    final prow = form.row(formRow);
    return prow.length > column ? prow[column]?.cellStyle : null;
  }

  // default texts of the template's own content area (rows 12-21); cells not
  // overwritten by PM data are cleared after the export while keeping the
  // style, so no leftover template defaults corrupt the parsed data
  final templateDefaults = <_TemplateDefaultCell>[];
  final writtenCells = <String>{};

  // write helper: write a single cell, cloning the blank form style
  void put(int row, int column, CellValue? value, int formRow) {
    writtenCells.add('$row:$column');
    main.updateCell(
      CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row),
      value,
      cellStyle: formStyle(formRow, column),
    );
  }

  for (var row = _pmTemplateMainContentFirstRow;
      row <= _pmTemplateMainContentLastRow;
      row++) {
    final prow = main.row(row);
    for (var col = 0; col < prow.length; col++) {
      if (prow[col]?.value != null) {
        templateDefaults.add(_TemplateDefaultCell(row, col, prow[col]?.cellStyle));
      }
    }
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
      put(row, 4, TextCellValue(asset.toString().toUpperCase()), 6);
    }
    final meter = fieldOf(task, 'metername');
    if (meter != null && meter.toString().isNotEmpty) {
      final inspect = await meterInspect(meter.toString());
      if (inspect != null && inspect.isNotEmpty) {
        put(row, 5, TextCellValue(inspect), 6);
      }
    }
    final jptask = fieldOf(task, 'jptask');
    if (jptask != null) {
      put(row, 6, IntCellValue(int.tryParse(jptask.toString()) ?? 0), 6);
    }
    put(row, 7, TextCellValue(fieldOf(task, 'description') ?? ''), 6);
    put(
        row,
        8,
        TextCellValue(stripHtml(fieldOf(task, 'description_longdescription'))),
        6);
  }

  /// Writes labour, task, route asset, materials and services rows of one PM
  /// starting at [row], returns the next free row.
  Future<int> writeContent(ExtractStore store, int row) async {
    // whether any stop will be written as a 'Task Route Assets' entry
    var routeAssetsNeeded = false;
    for (final stop in store.routeStops) {
      final stopJpnum = fieldOf(stop, 'jpnum') ?? '';
      final stopAsset = fieldOf(stop, 'assetnum') ?? '';
      if (stopAsset.isEmpty ||
          (stopJpnum.isNotEmpty &&
              store.stopJobPlans[stopJpnum] != null &&
              store.stopJobPlans[stopJpnum]!.jobtasks.isNotEmpty)) {
        continue;
      }
      routeAssetsNeeded = true;
    }

    // the template's own first block carries the task route asset marker on
    // its first content row (row 12); write it there explicitly so it
    // survives the unused-default cleanup and precedes the labour rows
    var markerPlaced = false;
    if (routeAssetsNeeded && row == _pmTemplateMainContentFirstRow) {
      put(row, 3, TextCellValue('Task Route Assets (one per cell):'), 6);
      markerPlaced = true;
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
          6);
      put(row, 1, IntCellValue(int.tryParse(rowValue(labor, 'QUANTITY')) ?? 1), 6);
      put(row, 2, DoubleCellValue(hoursFromRow(labor)), 6);
      row++;
    }

    // tasks of the PM's own job plan (no asset -> main job plan)
    var firstTaskRow = -1;
    for (final task in store.jobtasks) {
      if (firstTaskRow < 0) {
        firstTaskRow = row;
        // the template places the task route asset marker on the task row;
        // only needed when route assets follow and not placed already
        if (!markerPlaced && routeAssetsNeeded) {
          markerPlaced = true;
          put(row, 3, TextCellValue('Task Route Assets (one per cell):'), 6);
        }
      }
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
        if (!markerPlaced) {
          put(row, 3, TextCellValue('Task Route Assets (one per cell):'), 6);
          markerPlaced = true;
          row++;
        }
        put(row, 3, TextCellValue(stopAsset), 6);
        row++;
        continue;
      }
      for (final t in stopTasks) {
        if (!markerPlaced) {
          put(row, 3, TextCellValue('Task Route Assets (one per cell):'), 6);
          markerPlaced = true;
        }
        final task = Map<String, dynamic>.from(t as Map);
        await putTaskCells(row, task, stopAsset.isEmpty ? null : stopAsset);
        // ensure a task number / description exists even if the child job
        // task row lacks them
        if (int.tryParse(fieldOf(task, 'jptask') ?? '') == null) {
          put(row, 6, IntCellValue(taskSeq), 6);
        }
        if (fieldOf(task, 'description') == null) {
          put(row, 7, TextCellValue(fieldOf(stop, 'description') ?? ''), 6);
        }
        row++;
      }
    }

    // materials section
    put(row, 0, TextCellValue('Materials (Mapics Number)'), 9);
    put(row, 1, TextCellValue('Quantity'), 9);
    put(row, 2, TextCellValue('Cost (Optional)'), 9);
    put(row, 9, TextCellValue('Urgency Level (1-4)'), 9);
    row++;
    for (final material in store.jobmaterials) {
      put(row, 0, TextCellValue(rowValue(material, 'ITEMNUM')), 10);
      put(
          row,
          1,
          DoubleCellValue(double.tryParse(rowValue(material, 'ITEMQTY')) ?? 1),
          10);
      final cost = double.tryParse(rowValue(material, 'COST'));
      if (cost != null) {
        put(row, 2, DoubleCellValue(cost), 10);
      }
      row++;
    }

    // services section
    put(row, 0, TextCellValue('Services (Mapics Number)'), 15);
    put(row, 1, TextCellValue('Cost (Optional)'), 15);
    put(row, 2, TextCellValue('Vendor #'), 15);
    row++;
    for (final service in store.jobservices) {
      put(row, 0, TextCellValue(rowValue(service, 'ITEMNUM')), 15);
      final cost = double.tryParse(rowValue(service, 'COST'));
      if (cost != null) {
        put(row, 1, DoubleCellValue(cost), 15);
      }
      put(row, 2, TextCellValue(rowValue(service, 'COMPANY')), 15);
      row++;
    }
    return row;
  }

  /// Writes the label / data / number rows of a PM block.
  void writeHead(ExtractStore store, int dataRow) {
    final route = fieldOf(store.route ?? {}, 'route');
    put(dataRow - 1, 0, TextCellValue('PM Asset/ Parent (Route)*:'), 0);
    put(dataRow - 1, 1, TextCellValue('Route:'), 0);
    put(dataRow - 1, 2, TextCellValue('Next Due Date (MM/DD/YYYY):'), 0);
    put(dataRow - 1, 3, TextCellValue('Site ID*:'), 0);
    put(dataRow - 1, 4, TextCellValue('Frequency Unit*:'), 0);
    put(dataRow - 1, 5, TextCellValue('Frequency*:'), 0);
    put(dataRow - 1, 6, TextCellValue('Work Order Types*:'), 0);
    put(dataRow - 1, 7, TextCellValue('Stopped/Running'), 0);
    put(dataRow - 1, 8, TextCellValue('Suggested PM Name'), 0);
    put(dataRow - 1, 9, TextCellValue('Route Name'), 0);

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
    final freqWord =
        freqWords[rawFreqUnit] ?? (rawFreqUnit.isEmpty ? 'Select Frequency' : rawFreqUnit);
    final asset = fieldOf(store.pm, 'assetnum') ?? '';
    if (asset.isNotEmpty) {
      put(dataRow, 0, TextCellValue(asset), 1);
    }
    put(dataRow, 1, TextCellValue(routeTypeLabel(store)), 1);
    put(dataRow, 2, TextCellValue(_dateOnly(fieldOf(store.pm, 'nextdate'))), 1);
    put(dataRow, 3, TextCellValue(store.siteid), 1);
    put(dataRow, 4, TextCellValue(freqWord), 1);
    final frequency = int.tryParse(fieldOf(store.pm, 'frequency') ?? '');
    if (frequency != null) {
      put(dataRow, 5, IntCellValue(frequency), 1);
    }
    put(
        dataRow,
        6,
        TextCellValue(workType.isEmpty
            ? 'Select Work Order'
            : options.workTypes[workType] ?? workType),
        1);
    put(
        dataRow,
        7,
        TextCellValue(condition.isEmpty
            ? 'Select Process Condition'
            : options.conditions[condition] ?? condition),
        1);
    final pmName = fieldOf(store.pm, 'description') ?? store.pmnum;
    if (pmName.isNotEmpty) {
      put(dataRow, 8, TextCellValue(pmName), 1);
    }
    put(dataRow, 9,
        TextCellValue(route == null || route.isEmpty
            ? 'Select Route (Optional)'
            : fieldOf(store.route!, 'description') ?? ''),
        1);

    // PM number (and route code) row used by the parser
    put(dataRow + 1, 8, TextCellValue(store.pmnum), 2);
    if (route != null && route.isNotEmpty) {
      put(dataRow + 1, 9, TextCellValue(route), 2);
    }
  }

  /// Writes the static form rows between the number row and the content
  /// rows of a PM block (blank row, section labels and the craft header).
  void writeFormExtras(int baseRow) {
    // base + 3 is left blank, mirroring the template
    put(baseRow + 4, 0, TextCellValue('Craft'), 4);
    put(baseRow + 4, 3, TextCellValue('Replacement (ONLY for LC1)'), 4);
    put(baseRow + 4, 4, TextCellValue('Job Task:'), 4);
    put(baseRow + 4, 9, TextCellValue('IKO PM History Notes'), 4);
    put(baseRow + 5, 0, TextCellValue('Craft @ (Optional) Labour Code'), 5);
    put(baseRow + 5, 1, TextCellValue('Quantity'), 5);
    put(baseRow + 5, 2, TextCellValue('Hours'), 5);
    put(baseRow + 5, 4, TextCellValue('Child Route Assets:'), 5);
    put(baseRow + 5, 5, TextCellValue('Inspect:'), 5);
    put(baseRow + 5, 6, TextCellValue('Task Order:'), 5);
    put(baseRow + 5, 7, TextCellValue('Short Description '), 5);
    put(baseRow + 5, 8, TextCellValue('Long Description'), 5);
  }

  // first PM goes into the template's own first block, which already has
  // the label / number / craft header rows (rows 6-11)
  writeHead(stores.first, _pmTemplateMainDataRow);
  var cursor = _pmTemplateMainContentFirstRow;
  cursor = await writeContent(stores.first, cursor);
  // later blocks start on a fresh form, past the template's first block
  if (cursor <= _pmTemplateMainContentLastRow) {
    cursor = _pmTemplateSecondBlockRow;
  }
  for (final store in stores.skip(1)) {
    writeHead(store, cursor + 1);
    writeFormExtras(cursor);
    cursor = await writeContent(store, cursor + 6);
  }

  // clear default template texts that no PM data overwrote, keep their style,
  // so leftovers (default task text, section headers, fillers) corrupt neither
  // the parse nor the look of the form
  for (final cell in templateDefaults) {
    if (writtenCells.contains('${cell.row}:${cell.col}')) {
      continue;
    }
    main.updateCell(
      CellIndex.indexByColumnRow(columnIndex: cell.col, rowIndex: cell.row),
      null,
      cellStyle: cell.style,
    );
  }

  return Uint8List.fromList(excel.encode()!);
}
