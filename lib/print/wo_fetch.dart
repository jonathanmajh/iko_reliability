// Maximo fetch layer for the Work Order Print Pack.
//
// Builds [WoPacket]s for a batch of parent work orders using the app's
// `maximoRequest` OSLC client. Every heavy lookup (child work orders, task
// WOs, asset descriptions, planned labor/materials/tools/assignments) is a
// batched `... in [...]` query (chunked to keep URLs sane), so a whole
// print run costs a handful of HTTP calls — the opposite of the N+1 BIRT
// report (woprint2.rptdesign) this feature replaces.

import 'package:iko_reliability_flutter/admin/upload_maximo.dart'
    show maximoRequest;

import 'wo_packet.dart';

/// Thrown when a Maximo query fails or cannot be interpreted.
class WoPrintFetchException implements Exception {
  final String message;

  WoPrintFetchException(this.message);

  @override
  String toString() => message;
}

/// Result of fetching a batch of work orders.
class WoPrintBatch {
  /// Complete packets, in the same order as the requested wonums.
  final List<WoPacket> packets;

  /// Requested wonums Maximo returned nothing for.
  final List<String> notFound;

  /// Requested wonums that are actually child WOs of another parent.
  final List<String> skippedChildren;

  const WoPrintBatch({
    required this.packets,
    this.notFound = const [],
    this.skippedChildren = const [],
  });
}

/// Fetches work order print packets from Maximo.
class WoPrintFetcher {
  final String env;
  final String site;

  WoPrintFetcher({required this.env, required this.site});

  /// Number of values per `in [...]` chunk (keeps OSLC URLs reasonable).
  static const int chunkSize = 100;

  /// Fields fetched for parent headers (print covers + picker grid).
  static const List<String> _parentSelect = [
    'wonum',
    'description',
    'description_longdescription',
    'status',
    'worktype',
    'wopriority',
    'siteid',
    'assetnum',
    'location',
    'jpnum',
    'pmnum',
    'supervisor',
    'targstartdate',
    'targcompdate',
    'reportdate',
    'iko_conditions_description',
    'estdur',
    'schedstart',
    'schedfinish',
    'statusdate',
    'parent',
  ];

  /// Fields fetched for child headers (child page banners).
  static const List<String> _childSelect = [
    'wonum',
    'taskid',
    'istask',
    'description',
    'description_longdescription',
    'status',
    'worktype',
    'wopriority',
    'assetnum',
    'location',
    'estdur',
    'targstartdate',
    'targcompdate',
    'parent',
  ];

  /// Fields fetched for task work orders.
  static const List<String> _taskSelect = [
    'wonum',
    'taskid',
    'parent',
    'description',
    'description_longdescription',
    'status',
  ];

  /// Queries `structure` for rows where [field] is in [values], adding
  /// `and siteid="$site"[extraWhere]`. Chunks [values] and concatenates.
  Future<List<Map<String, dynamic>>> _queryIn(
    String structure,
    String field,
    List<String> values, {
    String extraWhere = '',
    List<String> select = const ['*'],
    String step = 'query',
  }) async {
    final rows = <Map<String, dynamic>>[];
    for (var i = 0; i < values.length; i += chunkSize) {
      final end = (i + chunkSize) > values.length ? values.length : i + chunkSize;
      final inList =
          values.sublist(i, end).map((v) => '"$v"').join(',');
      final where = '$field in [$inList] and siteid="$site"$extraWhere';
      final url = '$structure?oslc.where=$where&oslc.select=${select.join(',')}';
      Map<String, dynamic> res;
      try {
        res = await maximoRequest(url, 'get', env);
      } catch (e) {
        throw WoPrintFetchException('Maximo error while fetching $step: $e');
      }
      if (res['status'] == 'Failed to Connect') {
        throw WoPrintFetchException(
            'Failed to connect to Maximo ($env) while fetching $step.');
      }
      final member = res['member'] as List<dynamic>? ?? const [];
      rows.addAll(member.cast<Map<String, dynamic>>());
    }
    return rows;
  }

  /// Picker rows for the grid: released parent work orders for [site].
  /// Rows that are children of another WO are filtered out (they are
  /// covered by their parent's packet).
  Future<List<Map<String, dynamic>>> fetchReleasedWorkOrderRows() async {
    final rows = await _queryIn('mxwo', 'status', const ['RELEASED'],
        extraWhere: ' and istask=0',
        select: _parentSelect,
        step: 'the released work order list');
    return rows.where((r) => '${r['parent'] ?? ''}'.isEmpty).toList();
  }

  /// Picker rows for a pasted list of wonums (any status; the UI only lets
  /// released parents be selected). Returned rows keep their `parent` field
  /// so pasted children can be shown with a reason instead of "not found".
  Future<List<Map<String, dynamic>>> fetchWorkOrderRowsForWonums(
      List<String> wonums) async {
    final cleaned = wonums
        .map((w) => w.trim().toUpperCase())
        .where((w) => w.isNotEmpty)
        .toSet()
        .toList();
    if (cleaned.isEmpty) return const [];
    return _queryIn('mxwo', 'wonum', cleaned,
        select: _parentSelect, step: 'the pasted work orders');
  }

  /// Fetches complete packets for [parentWonums], in request order.
  ///
  /// [onStatus] receives progress text for the UI between the batched
  /// queries (the app's connection pool serializes them anyway).
  Future<WoPrintBatch> fetchPackets(
    List<String> parentWonums, {
    void Function(String status)? onStatus,
  }) async {
    final parents =
        parentWonums.map((w) => w.trim().toUpperCase()).toSet().toList();
    if (parents.isEmpty) {
      return const WoPrintBatch(packets: []);
    }

    // 1. parent headers (also covers pasted WOs that turn out to be children)
    onStatus?.call('Fetching work order headers...');
    final returnedRows = await _queryIn('mxwo', 'wonum', parents,
        select: _parentSelect, step: 'work order headers');

    final returnedWonums =
        returnedRows.map((r) => '${r['wonum']}').toSet();
    final notFound = <String>[
      for (final w in parents)
        if (!returnedWonums.contains(w)) w,
    ];
    final skippedChildren = <String>[];
    final validParentRows = <Map<String, dynamic>>[];
    for (final r in returnedRows) {
      if ('${r['parent'] ?? ''}'.isNotEmpty) {
        skippedChildren.add('${r['wonum']}');
      } else {
        validParentRows.add(r);
      }
    }
    final validParents = validParentRows.map((r) => '${r['wonum']}').toList();

    if (validParents.isEmpty) {
      return WoPrintBatch(
          packets: const [],
          notFound: notFound,
          skippedChildren: skippedChildren);
    }

    // 2. child work orders (istask=0 with a parent set)
    onStatus?.call('Fetching child work orders...');
    final childRowsRaw = await _queryIn('mxwo', 'parent', validParents,
        select: _childSelect, step: 'child work orders');
    final childRows = childRowsRaw
        .where((r) => r['istask'].toString() != 'true')
        .toList();

    // 3. all task WOs of the whole tree in one in-list query
    onStatus?.call('Fetching task work orders...');
    final treeWonums = [
      ...validParents,
      ...childRows.map((r) => '${r['wonum']}'),
    ];
    final taskRows = await _queryIn('mxwo', 'parent', treeWonums,
        extraWhere: ' and istask=1',
        select: _taskSelect,
        step: 'task work orders');
    final tasksByParent = <String, List<WoTask>>{};
    for (final t in taskRows) {
      tasksByParent
          .putIfAbsent('${t['parent'] ?? ''}', () => [])
          .add(taskFromMaximo(t));
    }
    for (final list in tasksByParent.values) {
      list.sort((a, b) => (int.tryParse(a.taskid ?? '') ?? 0)
          .compareTo(int.tryParse(b.taskid ?? '') ?? 0));
    }

    // 4. asset descriptions (parent + children) in one in-list query
    onStatus?.call('Fetching asset descriptions...');
    final assetNums = <String>{
      for (final r in [...validParentRows, ...childRows])
        if ('${r['assetnum'] ?? ''}'.isNotEmpty) '${r['assetnum']}',
    }.toList();
    final assetDesc = <String, String>{
      if (assetNums.isNotEmpty)
        for (final a in await _queryIn('mxasset', 'assetnum', assetNums,
            select: const ['assetnum', 'description'],
            step: 'asset descriptions'))
          '${a['assetnum']}': '${a['description'] ?? ''}',
    };

    // 5. planned labor / materials / tools / assignments for the whole tree
    //    in one ikomxwodetail query.
    onStatus?.call('Fetching planned labor, materials and tools...');
    final planRows = await _queryIn(
        'ikomxwodetail',
        'wonum',
        treeWonums,
        select: const [
          'wonum',
          'istask',
          'wplabor',
          'wpmaterial',
          'wptool',
          'assignment',
        ],
        step: 'planned labor and materials');
    final planByWonum = <String, Map<String, dynamic>>{
      for (final r in planRows) '${r['wonum']}': r,
    };

    // 6. assemble packets in requested order
    final parentByWonum = {
      for (final r in validParentRows) '${r['wonum']}': r,
    };
    final childRowsByParent = <String, List<Map<String, dynamic>>>{};
    for (final r in childRows) {
      childRowsByParent
          .putIfAbsent('${r['parent'] ?? ''}', () => [])
          .add(r);
    }

    final packets = <WoPacket>[];
    for (final wonum in parents) {
      final parentRow = parentByWonum[wonum];
      if (parentRow == null) continue;
      packets.add(WoPacket(
        header: headerFromMaximo(parentRow, assetDesc,
            site: site, parentWonum: wonum),
        tasks: tasksByParent[wonum] ?? const [],
        labor: laborRowsOf(planByWonum[wonum]),
        assignments: assignmentRowsOf(planByWonum[wonum]),
        materials: materialRowsOf(planByWonum[wonum]),
        tools: toolRowsOf(planByWonum[wonum]),
        children: [
          for (final child in childRowsByParent[wonum] ??
              const <Map<String, dynamic>>[])
            WoChildPacket(
              header: headerFromMaximo(child, assetDesc,
                  site: site, parentWonum: wonum, isChild: true),
              tasks: tasksByParent['${child['wonum']}'] ?? const [],
              materials: materialRowsOf(planByWonum['${child['wonum']}']),
            ),
        ],
      ));
    }

    onStatus?.call('Fetched ${packets.length} work order packet(s).');
    return WoPrintBatch(
        packets: packets,
        notFound: notFound,
        skippedChildren: skippedChildren);
  }
}

// ---------------------------------------------------------------------------
// mapping helpers (Maximo rows -> print packet models)
// ---------------------------------------------------------------------------

String _fmtNum(num v) =>
    v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

String _fmtVal(dynamic v) {
  if (v is num) return _fmtNum(v);
  return v == null ? '' : v.toString();
}

PlannedLaborRow? laborFromMaximo(Map<String, dynamic> l) {
  final code = l['laborcode'] == null ? '' : '${l['laborcode']}';
  final craft = l['craft'] == null ? '' : '${l['craft']}';
  if (code.isEmpty && craft.isEmpty) return null;
  final hrs = l['laborhrs'];
  final hours = hrs is num ? _fmtNum(hrs) : (hrs == null ? '' : '$hrs');
  final skill = l['skilllevel'] == null ? '' : '${l['skilllevel']}';
  return PlannedLaborRow(code, craft: craft, skilllevel: skill, hours: hours);
}

PlannedMaterialRow? materialFromMaximo(Map<String, dynamic> m) {
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

PlannedToolRow? toolFromMaximo(Map<String, dynamic> t) {
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

/// Live planned labor (WPLABOR) rows of one ikomxwodetail record.
List<PlannedLaborRow> laborRowsOf(Map<String, dynamic>? rec) => [
      for (final l in (rec?['wplabor'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>())
        if (laborFromMaximo(l) != null) laborFromMaximo(l)!,
    ];

/// Live planned material (WPMATERIAL) rows.
List<PlannedMaterialRow> materialRowsOf(Map<String, dynamic>? rec) => [
      for (final m in (rec?['wpmaterial'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>())
        if (materialFromMaximo(m) != null) materialFromMaximo(m)!,
    ];

/// Live planned tool (WPTOOL) rows.
List<PlannedToolRow> toolRowsOf(Map<String, dynamic>? rec) => [
      for (final t in (rec?['wptool'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>())
        if (toolFromMaximo(t) != null) toolFromMaximo(t)!,
    ];

/// Assignment (ASSIGNMENT) rows; they replace planned labor on the cover
/// when present.
List<PlannedLaborRow> assignmentRowsOf(Map<String, dynamic>? rec) => [
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

/// Builds a packet header map for the renderer (same shape as the sample
/// tool). Keys are documented on [WoPacket].
Map<String, dynamic> headerFromMaximo(
  Map<String, dynamic> p,
  Map<String, String> assetDesc, {
  required String site,
  required String parentWonum,
  bool isChild = false,
}) =>
    {
      'wonum': '${p['wonum']}',
      'description': '${p['description'] ?? ''}',
      'longdesc': '${p['description_longdescription'] ?? ''}',
      'status': '${p['status'] ?? ''}',
      if (!isChild) 'worktype': '${p['worktype'] ?? ''}',
      if (!isChild) 'wopriority': p['wopriority'],
      'siteid': '${p['siteid'] ?? site}',
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

/// Builds a [WoTask] from a task work order row.
WoTask taskFromMaximo(Map<String, dynamic> t) => WoTask(
      wonum: '${t['wonum']}',
      taskid: t['taskid'] == null ? null : '${t['taskid']}',
      description: '${t['description'] ?? ''}',
      longDesc: t['description_longdescription']?.toString(),
      status: t['status'] == null ? null : '${t['status']}',
    );
