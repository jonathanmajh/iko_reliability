// Standalone sample generator for the WO Print Pack design review.
//
// Fetches one parent work order and its full tree (task WOs + child WOs +
// their tasks + asset descriptions) from the test2 Maximo environment via
// OSLC/REST, then renders the packet with the same code the app will use
// (lib/print/wo_packet.dart).
//
// Usage:
//   set IKO_TEST2_APIKEY=<apikey>
//   dart run tool/wo_print_sample.dart [--wonum W24J12811]
//
// Never commit API keys; they are read from the environment / CLI only.
// Output: samples/<wonum>_print_pack.pdf

import 'dart:convert';
import 'dart:io';

import 'package:iko_reliability_flutter/print/wo_packet.dart';

const _base = 'https://test2.manage.test2.iko.max-it-eam.com/maximo/api/os/';
const _site = 'AA';
const _defaultWonum = 'W24J12811';

// ---------------------------------------------------------------------------
// Demo (placeholder) plan data — used until the IKO_WOPRINT automation script
// provides live planned labor/materials/tools from the SQL Server backend.
// ---------------------------------------------------------------------------

const _demoNote =
    'NOTE: Planned Materials / Planned Tools rows in this sample are '
    'placeholders for layout review only - this work order tree has none '
    'planned. Planned Labor rows are live data (from the IKOMXWODETAIL '
    'object structure).';

const _demoMaterials = [
  PlannedMaterialRow('13252258',
      description: 'Plastic film wrap 16" x 1500m (demo)', qty: '1 RL', storeroom: 'PKG-AA'),
  PlannedMaterialRow('C-440012',
      description: 'Dry film lubricant spray (demo)', qty: '1 EA', storeroom: 'SB-AA'),
];

const _demoTools = [
  PlannedToolRow('GL40FT',
      description: 'Aerial lift, 40 ft (demo)', qty: '1', hours: '2', rate: '125.00/h'),
];

/// Demo plan rows only where the tree has no live data.
List<T> _fallbackDemo<T>(List<T> live, List<T> demo) =>
    live.isEmpty ? demo : live;

String _fmtNum(num v) =>
    v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

String _fmtVal(dynamic v) {
  if (v is num) return _fmtNum(v);
  if (v == null) return '';
  return v.toString();
}

Future<void> main(List<String> args) async {
  final key = Platform.environment['IKO_TEST2_APIKEY'] ?? _arg('--key', args) ?? '';
  if (key.isEmpty) {
    stderr.writeln('Missing API key: set IKO_TEST2_APIKEY or pass --key <key>.');
    exit(2);
  }
  final wonum = _arg('--wonum', args) ?? _defaultWonum;
  stdout.writeln('Fetching $wonum (site $_site) from test2 ...');

  // OSLC helper: returns the member list of a structure query.
  Future<List<Map<String, dynamic>>> q(
      String struct, String where, List<String> sel) async {
    final url = '$_base$struct'
        '?oslc.where=${Uri.encodeQueryComponent(where)}'
        '&oslc.select=${Uri.encodeQueryComponent(sel.join(','))}'
        '&lean=1';
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set('apikey', key);
      final res = await req.close();
      final body = await utf8.decodeStream(res);
      if (res.statusCode != 200) {
        throw Exception(
            'HTTP ${res.statusCode} on $struct: ${body.substring(0, body.length.clamp(0, 300))}');
      }
      final parsed = jsonDecode(body) as Map<String, dynamic>;
      return (parsed['member'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
    } finally {
      client.close();
    }
  }

  // 1. parent work order with everything
  final parentRaw =
      (await q('mxwo', 'wonum="$wonum" and siteid="$_site"', ['*'])).first;
  stdout.writeln('parent: ${parentRaw['wonum']}');

  // 2. tree descendants: task WOs + child WOs (parent needed for banner)
  final descend = await q('mxwo', 'parent="$wonum" and siteid="$_site"', [
    'wonum', 'taskid', 'istask', 'description', 'status', 'worktype',
    'wopriority', 'assetnum', 'location', 'estdur', 'targstartdate',
    'targcompdate', 'parent',
  ]);
  final childrenRaw =
      descend.where((r) => r['istask'].toString() != 'true').toList();
  stdout.writeln(
      'tree: ${descend.length} records, ${childrenRaw.length} child work orders');

  // 3. all tasks of the whole tree in one in-list query
  final listForIn = ['"$wonum"', ...childrenRaw.map((k) => '"${k['wonum']}"')];
  final tasksAll = await q(
      'mxwo',
      'parent in [${listForIn.join(',')}] and siteid="$_site" and istask=1',
      [
        'wonum', 'taskid', 'parent', 'description',
        'description_longdescription', 'status',
      ]);
  final tasksByParent = <String, List<WoTask>>{};
  for (final t in tasksAll) {
    tasksByParent.putIfAbsent('${t['parent']}', () => []).add(WoTask(
          wonum: '${t['wonum']}',
          taskid: t['taskid'] == null ? null : '${t['taskid']}',
          description: '${t['description'] ?? ''}',
          longDesc: t['description_longdescription']?.toString(),
          status: t['status'] == null ? null : '${t['status']}',
        ));
  }
  tasksByParent.updateAll((_, list) {
    list.sort((a, b) =>
        (int.tryParse(a.taskid ?? '') ?? 0).compareTo(int.tryParse(b.taskid ?? '') ?? 0));
    return list;
  });
  stdout.writeln('tasks: ${tasksAll.length} across the tree');

  // 4. asset descriptions (parent + children) in one in-list query
  final assetNums = <String>{'${parentRaw['assetnum']}'};
  for (final k in childrenRaw) {
    if (k['assetnum'] != null) assetNums.add('${k['assetnum']}');
  }
  final assetWhere =
      'assetnum in [${assetNums.map((a) => '"$a"').join(',')}] and siteid="$_site"';
  final assets = await q('mxasset', assetWhere, ['assetnum', 'description']);
  final assetDesc = <String, String>{
    for (final a in assets) '${a['assetnum']}': '${a['description'] ?? ''}',
  };
  stdout.writeln('assets: ${assetDesc.length} resolved');

  // 5. live planned labor / materials / tools for the whole tree in ONE
  //    ikomxwodetail query. Child objects: WPLABOR / WPMATERIAL / WPTOOL
  //    (+ ASSIGNMENT - assignments replace planned labor on the cover
  //    when present).
  final plan = await q('ikomxwodetail',
      'wonum in [${listForIn.join(',')}] and siteid="$_site"', [
    'wonum',
    'istask',
    'wplabor',
    'wpmaterial',
    'wptool',
    'assignment',
  ]);
  final planByWonum = <String, Map<String, dynamic>>{
    for (final r in plan) '${r['wonum']}': r,
  };

  PlannedLaborRow? laborFrom(Map<String, dynamic> l) {
    final code = l['laborcode'] == null ? '' : '${l['laborcode']}';
    final craft = l['craft'] == null ? '' : '${l['craft']}';
    if (code.isEmpty && craft.isEmpty) return null;
    final hrs = l['laborhrs'];
    final hours =
        hrs is num ? _fmtNum(hrs) : (hrs == null ? '' : '$hrs');
    final skill = l['skilllevel'] == null ? '' : '${l['skilllevel']}';
    return PlannedLaborRow(code, craft: craft, skilllevel: skill, hours: hours);
  }

  PlannedMaterialRow? materialFrom(Map<String, dynamic> m) {
    final item = m['itemnum'] == null ? '' : '${m['itemnum']}';
    final desc = m['description'] == null ? '' : '${m['description']}';
    if (item.isEmpty && desc.isEmpty) return null;
    return PlannedMaterialRow(
      item,
      description: desc,
      qty: m['itemqty'] == null ? '' : _fmtVal(m['itemqty']),
      storeroom: m['location'] == null ? '' : '${m['location']}',
    );
  }

  PlannedToolRow? toolFrom(Map<String, dynamic> t) {
    final item = t['itemnum'] == null ? '' : '${t['itemnum']}';
    if (item.isEmpty) return null;
    return PlannedToolRow(
      item,
      description: t['description'] == null ? '' : '${t['description']}',
      qty: t['itemqty'] == null ? '' : _fmtVal(t['itemqty']),
      hours: t['hours'] == null ? '' : _fmtVal(t['hours']),
      rate: t['rate'] == null ? '' : _fmtVal(t['rate']),
    );
  }

  List<PlannedLaborRow> liveLabor(Map<String, dynamic>? rec) => [
        for (final l in (rec?['wplabor'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>())
          if (laborFrom(l) != null) laborFrom(l)!,
      ];
  List<PlannedMaterialRow> liveMaterials(Map<String, dynamic>? rec) => [
        for (final m in (rec?['wpmaterial'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>())
          if (materialFrom(m) != null) materialFrom(m)!,
      ];
  List<PlannedToolRow> liveTools(Map<String, dynamic>? rec) => [
        for (final t in (rec?['wptool'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>())
          if (toolFrom(t) != null) toolFrom(t)!,
      ];

  List<PlannedLaborRow> assignmentsFrom(Map<String, dynamic>? rec) => [
        for (final a in (rec?['assignment'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>())
          if (a['laborcode'] != null || a['craft'] != null)
            PlannedLaborRow(
              a['laborcode'] == null ? '' : '${a['laborcode']}',
              craft: a['craft'] == null ? '' : '${a['craft']}',
              skilllevel: a['skilllevel'] == null ? '' : '${a['skilllevel']}',
              hours: a['laborhrs'] == null ? '' : _fmtVal(a['laborhrs']),
            ),
      ];

  final parentPlan = planByWonum[wonum];
  stdout.writeln(
      'plan: parent labor=${liveLabor(parentPlan).length}, tree materials=${liveMaterials(parentPlan).length}');

  // ---- assemble packet ------------------------------------------------------
  WoRecord headerFrom(Map<String, dynamic> p, {required String parentWonum, bool isChild = false}) => {
        'wonum': '${p['wonum']}',
        'description': '${p['description'] ?? ''}',
        'longdesc': '${p['description_longdescription'] ?? ''}',
        'status': '${p['status'] ?? ''}',
        if (!isChild) 'worktype': '${p['worktype'] ?? ''}',
        if (!isChild) 'wopriority': p['wopriority'],
        'siteid': '${p['siteid'] ?? _site}',
        'assetnum': '${p['assetnum'] ?? ''}',
        'assetdesc': assetDesc['${p['assetnum']}'] ?? '',
        'location': '${p['location'] ?? ''}',
        if (!isChild) 'jpnum': '${p['jpnum'] ?? ''}',
        if (!isChild) 'pmnum': '${p['pmnum'] ?? ''}',
        if (!isChild) 'supervisor': '${p['supervisor'] ?? ''}',
        if (!isChild) 'targstartdate': p['targstartdate']?.toString(),
        if (!isChild) 'targcompdate': p['targcompdate']?.toString(),
        if (!isChild) 'reportdate': p['reportdate']?.toString(),
        if (!isChild) 'conditions': '${p['iko_conditions_description'] ?? ''}',
        if (!isChild) 'duration': p['estdur']?.toString(),
        'parent': '${p['parent'] ?? parentWonum}',
      };

  final packet = WoPacket(
    header: headerFrom(parentRaw, parentWonum: wonum),
    tasks: tasksByParent[wonum] ?? const [],
    labor: liveLabor(parentPlan),
    assignments: assignmentsFrom(parentPlan),
    materials: _fallbackDemo(liveMaterials(parentPlan), _demoMaterials),
    tools: _fallbackDemo(liveTools(parentPlan), _demoTools),
    demoNote: _demoNote,
    children: [
      for (final k in childrenRaw)
        WoChildPacket(
          header: headerFrom(k, parentWonum: wonum, isChild: true),
          tasks: tasksByParent['${k['wonum']}'] ?? const [],
          // Materials live data when present; demo rows only where the
          // tree has none, so the section layout can be reviewed.
          materials: _fallbackDemo(liveMaterials(planByWonum['${k['wonum']}']), _demoMaterials),
        ),
    ],
  );

  // ---- render ---------------------------------------------------------------
  final bytes = await buildWoPacketPdf(packet);
  final out = File('samples/${wonum}_print_pack.pdf')
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes);
  stdout.writeln('Wrote ${out.path} (${bytes.length} bytes)');
}

String? _arg(String name, List<String> args) {
  for (var i = 0; i < args.length; i++) {
    if (args[i] == name && i + 1 < args.length) return args[i + 1];
    if (args[i].startsWith('$name=')) return args[i].substring(name.length + 1);
  }
  return null;
}
