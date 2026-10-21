// Maximo fetch layer for the Work Order Print Pack.
//
// Builds [WoPacket]s for a batch of parent work orders using the app's
// `maximoRequest` OSLC client. Every heavy lookup (child work orders, task
// WOs, asset descriptions, planned labor/materials/tools/assignments) is a
// batched `... in [...]` query (chunked to keep URLs sane), so a whole
// print run costs a handful of HTTP calls â€” the opposite of the N+1 BIRT
// report (woprint2.rptdesign) this feature replaces.

import 'package:iko_reliability_flutter/admin/upload_maximo.dart'
    show maximoRequest;

import 'wo_assemble.dart';

export 'wo_assemble.dart' show WoPrintBatch, assembleWoPrintBatch;

/// Thrown when a Maximo query fails or cannot be interpreted.
class WoPrintFetchException implements Exception {
  final String message;

  WoPrintFetchException(this.message);

  @override
  String toString() => message;
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

    // 4. asset descriptions (parent + children) in one in-list query
    onStatus?.call('Fetching asset descriptions...');
    final assetNums = <String>{
      for (final r in [...validParentRows, ...childRows])
        if ('${r['assetnum'] ?? ''}'.isNotEmpty) '${r['assetnum']}',
    }.toList();
    final assetRows = assetNums.isEmpty
        ? const <Map<String, dynamic>>[]
        : await _queryIn('mxasset', 'assetnum', assetNums,
            select: const ['assetnum', 'description'],
            step: 'asset descriptions');

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

    // 6. assemble packets in requested order
    onStatus?.call('Fetched work order data.');
    return assembleWoPrintBatch(
      parents: parents,
      validParentRows: validParentRows,
      childRows: childRows,
      taskRows: taskRows,
      assetRows: assetRows,
      planRows: planRows,
      site: site,
      notFound: notFound,
      skippedChildren: skippedChildren,
    );
  }
}
