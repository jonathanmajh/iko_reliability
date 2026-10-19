import 'package:excel_plus/excel_plus.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';

import '../bin/consts.dart';
import 'extract_notifier.dart';
import 'generate_job_plans.dart' show generatePM;
import 'parse_template.dart';
import 'pm_name_generator.dart';
import 'template_notifier.dart';
import 'upload_maximo.dart';

/// Number of (siteid, pmnum) pairs sent per batched OSLC PM query.
const int pmExtractBatchSize = 20;

/// Result of parsing user input for the PM Extract page.
class ParsedPmInput {
  final List<ExtractStore> valid = [];
  final List<String> invalid = [];
}

/// Parses lines like 'AA A0001D1INRE' or 'A0001D1INRE, AA' into pairs.
///
/// A token that matches a known site ID (from [siteIDAndOrgID]) is the site,
/// the remaining token is the PM number. Lines without a site fall back to
/// [fallbackSite]. Invalid lines are reported in [ParsedPmInput.invalid].
ParsedPmInput parsePmInputLines(String text, String? fallbackSite) {
  final result = ParsedPmInput();
  for (String rawLine in text.split(RegExp(r'\r?\n'))) {
    final line = rawLine.trim();
    if (line.isEmpty) {
      continue;
    }
    final tokens = line.split(RegExp(r'[\s,;]+'));
    String? site;
    final others = <String>[];
    String? reason;
    for (final token in tokens) {
      final upper = token.replaceAll('"', '').toUpperCase();
      if (siteIDAndOrgID.containsKey(upper) && upper != 'All') {
        if (site != null && site != upper) {
          reason = 'multiple site IDs';
          break;
        }
        site = upper;
      } else {
        others.add(upper);
      }
    }
    if (reason == null) {
      if (others.isEmpty) {
        reason = 'missing PM number';
      } else if (others.length > 1) {
        reason = 'too many values, expected PM number + site';
      }
    }
    if (reason != null) {
      result.invalid.add('$line: $reason');
      continue;
    }
    site ??= (fallbackSite == null || fallbackSite.isEmpty) ? null : fallbackSite;
    if (site == null) {
      result.invalid.add('$line: no site specified');
      continue;
    }
    result.valid.add(ExtractStore(siteid: site, pmnum: others[0]));
  }
  return result;
}

/// Field list for PM header lookups, mirrored from tableHeaders['PM'].
String get pmExtractSelect => tableHeaders['PM']!.map((e) => e.toLowerCase()).join(',');

/// Encodes an OSLC where clause for use in a URL (spaces as %20).
String encodeOslcWhere(String where) => where.replaceAll(' ', '%20');

/// Fetches PM headers for all stores in batches, then fetches the full
/// detail (job plan, tasks, labor, materials, services, route) of every PM
/// that was found. Updates [notifier] progressively.
Future<void> fetchExtracts(
    List<ExtractStore> stores, String env, ExtractNotifier notifier) async {
  notifier.setFetching(true);
  try {
    await _fetchPmHeaders(stores, env, notifier);
    for (final store in stores) {
      if (store.status == 'extracting') {
        await _fetchPmDetails(store, env, notifier);
      }
    }
  } finally {
    notifier.setFetching(false);
    notifier.update();
  }
}

/// Batched PM header lookup. Pairs are grouped into OR clauses so a list of
/// PMs costs one request per [pmExtractBatchSize] pairs.
Future<void> _fetchPmHeaders(
    List<ExtractStore> stores, String env, ExtractNotifier notifier) async {
  for (var i = 0; i < stores.length; i += pmExtractBatchSize) {
    final chunk =
        stores.sublist(i, i + pmExtractBatchSize > stores.length ? stores.length : i + pmExtractBatchSize);
    for (final store in chunk) {
      store.status = 'fetching';
    }
    notifier.update();
    final where = chunk
        .map((s) => '(pmnum="${s.pmnum}" and siteid="${s.siteid}")')
        .join(' or ');
    final url =
        'iko_pm?oslc.select=$pmExtractSelect&oslc.pageSize=${chunk.length + 10}&oslc.where=${encodeOslcWhere(where)}';
    try {
      final result = await maximoRequest(url, 'get', env);
      if (result['member'] == null) {
        throw Exception('Invalid Response from Maximo');
      }
      final members = result['member'] as List<dynamic>;
      final found = <String, Map<String, dynamic>>{};
      for (final row in members) {
        final key =
            '${(row['siteid'] ?? '').toString().toUpperCase()}|${(row['pmnum'] ?? '').toString().toUpperCase()}';
        found[key] = Map<String, dynamic>.from(row as Map);
      }
      for (final store in chunk) {
        if (found.containsKey(store.key)) {
          store.pm = found[store.key]!;
          store.status = 'extracting';
        } else {
          store.status = 'not found';
        }
      }
    } catch (e) {
      for (final store in chunk) {
        store.status = 'error';
        store.errorMessage = e.toString();
      }
    }
    notifier.update();
  }
}

/// Fetches the job plan (with nested tasks/labor/materials/services) and the
/// route (with stops) referenced by the extracted PM.
Future<void> _fetchPmDetails(
    ExtractStore store, String env, ExtractNotifier notifier) async {
  try {
    final jpnum = fieldOf(store.pm, 'jpnum');
    if (jpnum != null && jpnum.isNotEmpty) {
      final where = 'jpnum="$jpnum"';
      store.jobplan = await _fetchSingle('iko_jobplan', where, env);
      store.jobtasks = await _fetchChildren('iko_jobtask', 'jobtask', where, env);
      store.joblabors = await _fetchChildren('iko_joblabor', 'joblabor', where, env);
      store.jobmaterials =
          await _fetchChildren('iko_jobmaterial', 'jobmaterial', where, env);
      store.jobservices =
          await _fetchChildren('iko_jobservice', 'jobservice', where, env);
    }
    final route = fieldOf(store.pm, 'route');
    if (route != null && route.isNotEmpty) {
      final where = 'route="$route" and siteid="${store.siteid}"';
      store.route = await _fetchSingle('iko_route', where, env);
      store.routeStops =
          await _fetchChildren('iko_route_stop', 'route_stop', where, env);
    }
    store.status = 'extracted';
  } catch (e) {
    store.status = 'error';
    store.errorMessage = e.toString();
  }
  notifier.update();
}

/// GET a single Maximo record; returns null when nothing matches [where].
Future<Map<String, dynamic>?> _fetchSingle(
    String object, String where, String env) async {
  final url = '$object?oslc.select=*&oslc.where=${encodeOslcWhere(where)}';
  final result = await maximoRequest(url, 'get', env);
  if (result['member'] == null) {
    throw Exception('Invalid Response from Maximo ($object)');
  }
  final members = result['member'] as List<dynamic>;
  if (members.isEmpty) {
    return null;
  }
  return Map<String, dynamic>.from(members[0] as Map);
}

/// GET a Maximo record and return its nested child collection rows.
///
/// Maximo returns the parent record with the child rows nested under
/// [childKey] (e.g. iko_jobtask returns the job plan record with a 'jobtask'
/// array). Falls back to the first list-typed value, then to the members
/// themselves when Maximo returns flat child rows.
Future<List<dynamic>> _fetchChildren(
    String object, String childKey, String where, String env) async {
  final url = '$object?oslc.select=*&oslc.where=${encodeOslcWhere(where)}';
  final result = await maximoRequest(url, 'get', env);
  if (result['member'] == null) {
    throw Exception('Invalid Response from Maximo ($object)');
  }
  final members = result['member'] as List<dynamic>;
  if (members.isEmpty) {
    return [];
  }
  final record = Map<String, dynamic>.from(members[0] as Map);
  final nested = record[childKey];
  if (nested is List) {
    return nested;
  }
  for (final value in record.values) {
    if (value is List) {
      return value;
    }
  }
  if (members.length > 1) {
    // flat child rows, one per member
    return members;
  }
  return [];
}

/// Reads a Maximo record field (JSON keys are lowercase) as a String.
String? fieldOf(Map<String, dynamic> record, String name) {
  final value = record[name.toLowerCase()] ?? record[name.toUpperCase()];
  if (value == null) {
    return null;
  }
  return value.toString();
}

/// Strips HTML tags from Maximo long description text for display/export.
String stripHtml(String? text) {
  if (text == null) {
    return '';
  }
  return text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
}

/// Reads a table-header style column (e.g. 'JP_JPNUM', 'CRAFT') from a raw
/// Maximo child row.
String rowValue(dynamic row, String header) {
  if (row is! Map) {
    return '';
  }
  String name = header.toLowerCase();
  if (name.startsWith('jp_')) {
    name = name.substring(3);
  }
  final value = row[name] ?? row[header] ?? row[header.toUpperCase()];
  return value == null ? '' : value.toString();
}

/// Exports all extracted PMs to an Excel workbook with one sheet per table.
///
/// Sheets with no data are skipped. Returns a user facing result message.
Future<String> exportExtractsToExcel(List<ExtractStore> stores) async {
  final extracted = stores.where((s) => s.pm.isNotEmpty).toList();
  if (extracted.isEmpty) {
    return 'Nothing to export, no PMs extracted';
  }
  final excel = Excel.createExcel();
  excel.rename(excel.getDefaultSheet() ?? 'Sheet1', 'PM');

  void writeSheet(String name, List<String> headers, List<List<String>> rows) {
    if (rows.isEmpty) {
      return;
    }
    final sheet = excel[name];
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());
    for (final row in rows) {
      sheet.appendRow(row.map((v) => TextCellValue(v)).toList());
    }
  }

  // PM header sheet, one row per extracted PM
  writeSheet('PM', tableHeaders['PM']! + ['STATUS'],
      extracted.map((s) => tableHeaders['PM']!.map((h) => rowValue(s.pm, h)).toList() + [fieldOf(s.pm, 'status') ?? '']).toList());

  // job plan headers
  final jps = extracted.where((s) => s.jobplan != null).toList();
  writeSheet('JobPlan', tableHeaders['JobPlan']!, [
    for (final s in jps)
      tableHeaders['JobPlan']!
          .map((h) => rowValue(s.jobplan!, h))
          .toList()
  ]);

  // job plan children
  writeSheet('Tasks', tableHeaders['JobTask']!, [
    for (final s in extracted)
      for (final row in s.jobtasks)
        tableHeaders['JobTask']!.map((h) => rowValue(row, h)).toList()
  ]);
  writeSheet('Labor', tableHeaders['JobLabor']!, [
    for (final s in extracted)
      for (final row in s.joblabors)
        tableHeaders['JobLabor']!.map((h) => rowValue(row, h)).toList()
  ]);
  writeSheet('Materials', tableHeaders['JobMaterial']!, [
    for (final s in extracted)
      for (final row in s.jobmaterials)
        tableHeaders['JobMaterial']!.map((h) => rowValue(row, h)).toList()
  ]);
  writeSheet('Services', tableHeaders['JobService']!, [
    for (final s in extracted)
      for (final row in s.jobservices)
        tableHeaders['JobService']!.map((h) => rowValue(row, h)).toList()
  ]);

  // routes
  final routes = extracted.where((s) => s.route != null).toList();
  writeSheet('Route', tableHeaders['Route']!, [
    for (final s in routes)
      tableHeaders['Route']!.map((h) => rowValue(s.route!, h)).toList()
  ]);
  writeSheet('Route Stops', tableHeaders['Route_Stop']!, [
    for (final s in extracted)
      for (final row in s.routeStops)
        tableHeaders['Route_Stop']!.map((h) => rowValue(row, h)).toList()
  ]);

  final bytes = excel.encode();
  if (bytes == null) {
    return 'Failed to encode Excel file';
  }
  const fileName = 'PM_Extract.xlsx';
  final FileSaveLocation? location = await getSaveLocation(
    initialDirectory: null,
    suggestedName: fileName,
  );
  if (location == null) {
    return 'Export cancelled';
  }
  final file = XFile.fromData(
    Uint8List.fromList(bytes),
    mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    name: fileName,
  );
  await file.saveTo(location.path);
  return 'Exported ${extracted.length} PMs to ${location.path}';
}

/// Maps a Maximo frequnit (DAYS/WEEKS/MONTHS/YEARS) to the template code.
String? _freqUnitFromMaximo(String? frequnit) {
  if (frequnit == null || frequnit.isEmpty) {
    return null;
  }
  const map = {'DAYS': 'D', 'WEEKS': 'W', 'MONTHS': 'M', 'YEARS': 'Y'};
  return map[frequnit.toUpperCase()] ?? frequnit.substring(0, 1).toUpperCase();
}

/// Maps a Maximo job labor craft code (ELECT/MECH-MW/PROD) to the template
/// labor type code (E/M/O).
String _laborTypeFromCraft(String? craft) {
  if (craft == null || craft.isEmpty) {
    return '';
  }
  final first = craft.substring(0, 1).toUpperCase();
  if (first == 'P') {
    return 'O'; // Production is code O but Maximo craft is PROD
  }
  return first;
}

/// Parses a labor hours value which can be 'HH:MM' or a plain number.
double _hoursFromRow(dynamic row) {
  final value = rowValue(row, 'LABORHRS');
  if (value.isEmpty) {
    return 0.0;
  }
  if (value.contains(':')) {
    return parseTime(value);
  }
  return double.tryParse(value) ?? 0.0;
}

/// Best effort mapping of an extracted PM into a [ParsedTemplate] which is
/// loaded into the [TemplateNotifier] so it shows up on the PM Check page.
///
/// Fields that do not survive the round trip are listed as status messages.
Future<void> populateTemplateFromExtract(
  ExtractStore store,
  TemplateNotifier templateNotifier,
  String maximoServerSelected,
  bool includeFrequency,
) async {
  final file = store.key;
  final nextDate = fieldOf(store.pm, 'nextdate') ?? '';
  final parsed = ParsedTemplate(
    nextDueDate: nextDate.length > 10 ? nextDate.substring(0, 10) : nextDate,
    siteId: store.siteid,
    frequencyUnit: _freqUnitFromMaximo(fieldOf(store.pm, 'frequnit')),
    frequency: int.tryParse(fieldOf(store.pm, 'frequency') ?? ''),
    workOrderType: fieldOf(store.jobplan ?? {}, 'iko_worktype'),
    processCondition: fieldOf(store.jobplan ?? {}, 'iko_conditions'),
    pmAsset: fieldOf(store.pm, 'assetnum'),
    pmName: fieldOf(store.pm, 'description') ?? store.pmnum,
    pmNumber: store.pmnum,
    suggestedPmName: fieldOf(store.pm, 'description'),
    suggestedPmNumber: store.pmnum,
    routeCode: fieldOf(store.route ?? {}, 'route'),
    routeName: fieldOf(store.route ?? {}, 'description'),
    pmPackageNumber: fieldOf(store.jobplan ?? {}, 'iko_pmpackage'),
  );
  for (final row in store.joblabors) {
    final craft = rowValue(row, 'CRAFT');
    final qty = int.tryParse(rowValue(row, 'QUANTITY'));
    parsed.crafts.add(JobCraft(
      laborType: _laborTypeFromCraft(craft),
      quantity: qty ?? 1,
      hours: _hoursFromRow(row),
      laborCode: '',
    ));
  }
  for (final row in store.jobmaterials) {
    parsed.materials.add(JobMaterial(
      itemNumber: rowValue(row, 'ITEMNUM'),
      quantity: double.tryParse(rowValue(row, 'ITEMQTY')) ?? 1.0,
      cost: double.tryParse(rowValue(row, 'COST')),
    ));
  }
  for (final row in store.jobservices) {
    parsed.services.add(JobService(
      itemNumber: rowValue(row, 'ITEMNUM'),
      vendorId: rowValue(row, 'COMPANY'),
      cost: double.tryParse(rowValue(row, 'COST')),
    ));
  }
  for (final row in store.jobtasks) {
    final task = Map<String, dynamic>.from(row as Map);
    final taskDescription = fieldOf(task, 'description') ?? '';
    final assetNumber = fieldOf(task, 'assetnum')?.toUpperCase();
    if (assetNumber != null && assetNumber.isNotEmpty) {
      parsed.assets.add(assetNumber);
    }
    parsed.tasks.add(JobTask(
      jptask: int.tryParse(fieldOf(task, 'jptask') ?? ''),
      description: taskDescription,
      assetNumber: assetNumber,
      metername: fieldOf(task, 'metername'),
      longdescription: stripHtml(fieldOf(task, 'description_longdescription')),
    ));
  }

  templateNotifier.setParsedTemplate(file, 1, parsed);
  try {
    final name = await generateName(
      templateNotifier.getParsedTemplate(file, 1),
      maximoServerSelected,
      includeFrequency,
    );
    templateNotifier.setNameTemplate(file, 1, name);
    final pm = await generatePM(
      templateNotifier.getParsedTemplate(file, 1),
      templateNotifier.getPMName(file, 1),
      maximoServerSelected,
    );
    templateNotifier.setProcessedTemplate(file, 1, pm);
    templateNotifier.addStatusMessage(file, 1,
        'Best effort template from Maximo ($file), fields with manual edits may not match, review before uploading');
  } catch (e) {
    debugPrint(e.toString());
    templateNotifier.addStatusMessage(file, 1,
        'Best effort template from Maximo ($file) could not be fully generated: $e');
  }
}
