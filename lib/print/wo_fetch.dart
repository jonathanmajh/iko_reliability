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
import 'package:iko_reliability_flutter/main.dart' show logger;

import '../bin/consts.dart' show maximoServerDomains;
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

  /// Rows fetched per OSLC page. Larger result sets are paged by following
  /// Maximo's `responseInfo.nextPage` links until the result is complete,
  /// so sites with thousands of released work orders load fully and in
  /// smaller chunks than the default server page size.
  static const int pageSize = 200;

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
    // NOTE: must select the IKO_CONDITIONS *domain attribute*, not its
    // `_description` synonym: Maximo OSLC silently drops
    // `iko_conditions_description` when selected explicitly, but returns
    // both the code and the description when `iko_conditions` is selected.
    'iko_conditions',
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

  /// Assignment labor codes per work order number, read from the nested
  /// `assignment` rows of the `ikomxwodetail` records. Any assignment
  /// status counts; codes are trimmed and uppercased. Work orders without
  /// a detail record or without assignment rows are absent from the
  /// result (i.e. not assigned). [onStatus] receives progress text for
  /// the UI between chunks/pages.
  Future<Map<String, Set<String>>> fetchAssignmentLaborcodes(
    List<String> wonums, {
    void Function(String status)? onStatus,
  }) async {
    final cleaned = wonums
        .map((w) => w.trim().toUpperCase())
        .where((w) => w.isNotEmpty)
        .toSet()
        .toList();
    if (cleaned.isEmpty) return const {};
    final rows = await _queryIn(
      'ikomxwodetail',
      'wonum',
      cleaned,
      select: const ['wonum', 'assignment'],
      step: 'assigned labor codes',
      onStatus: onStatus,
    );
    final result = <String, Set<String>>{};
    for (final r in rows) {
      final codes = result.putIfAbsent(
        '${r['wonum']}'.toUpperCase(),
        () => <String>{},
      );
      for (final a
          in (r['assignment'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>()) {
        final code = '${a['laborcode'] ?? ''}'.trim().toUpperCase();
        if (code.isNotEmpty) codes.add(code);
      }
    }
    logger?.i(
      'Assigned labor codes found for ${result.length} of '
      '${cleaned.length} work order(s).',
    );
    return result;
  }

  /// Queries `structure` for rows where [field] is in [values], adding
  /// `and siteid="$site"[extraWhere]`. Chunks [values] (to keep OSLC URLs
  /// reasonable), requests [pageSize] rows at a time and follows Maximo's
  /// `responseInfo.nextPage` links, so result sets larger than one page
  /// are fetched completely instead of being cut off. [onStatus] receives
  /// progress text ('... page 2 of 17') between pages.
  Future<List<Map<String, dynamic>>> _queryIn(
    String structure,
    String field,
    List<String> values, {
    String extraWhere = '',
    List<String> select = const ['*'],
    String step = 'query',
    void Function(String status)? onStatus,
  }) async {
    final rows = <Map<String, dynamic>>[];
    for (var i = 0; i < values.length; i += chunkSize) {
      final end = (i + chunkSize) > values.length
          ? values.length
          : i + chunkSize;
      final inList = values.sublist(i, end).map((v) => '"$v"').join(',');
      final where = '$field in [$inList] and siteid="$site"$extraWhere';
      var url =
          '$structure?oslc.where=$where&oslc.select=${select.join(',')}'
          '&oslc.pageSize=$pageSize';
      // collectioncount=1 makes responseInfo carry totalPages, used for
      // live progress when [onStatus] is given
      if (onStatus != null) {
        url = '$url&collectioncount=1';
      }
      var page = 1;
      var totalPages = 0;
      final followedHrefs = <String>{};
      while (true) {
        onStatus?.call(
          'Fetching $step (page $page of '
          '${totalPages == 0 ? '?' : totalPages})...',
        );
        Map<String, dynamic> res;
        try {
          res = await maximoRequest(url, 'get', env);
        } catch (e) {
          throw WoPrintFetchException('Maximo error while fetching $step: $e');
        }
        if (res['status'] == 'Failed to Connect') {
          throw WoPrintFetchException(
            'Failed to connect to Maximo ($env) while fetching $step.',
          );
        }
        final member = res['member'] as List<dynamic>? ?? const [];
        rows.addAll(member.cast<Map<String, dynamic>>());
        final info = res['responseInfo'] as Map<String, dynamic>? ?? const {};
        totalPages = int.tryParse('${info['totalPages'] ?? ''}') ?? totalPages;
        // follow Maximo's next-page link while one exists (Test2/MAS returns
        // it as an object `{href: ...}`, other versions as a plain string)
        final nextHref = _pagingHref(info['nextPage']);
        if (member.isEmpty || nextHref.isEmpty) {
          break;
        }
        final nextUrl = _relativePagingUrl(nextHref);
        if (nextUrl == null || !followedHrefs.add(nextHref)) {
          // a next page exists but cannot be followed - fail loudly instead
          // of silently returning a truncated list
          logger?.e(
            'Maximo paging: could not follow next page link while '
            'fetching "$step" (page $page). Next page URL: $nextHref',
          );
          throw WoPrintFetchException(
            'Could not follow the Maximo next page link while fetching '
            '$step (page $page). Next page URL: $nextHref',
          );
        }
        logger?.i(
          'Maximo paging: "$step" following next page link '
          '(page $page -> ${page + 1}, ${rows.length} rows so far)',
        );
        url = nextUrl;
        page++;
      }
    }
    logger?.i('Maximo query "$step" fetched ${rows.length} row(s).');
    return rows;
  }

  /// Maximo versions differ in where they put the paging link: some return
  /// a plain URL string under `nextPage`, MAS/Test2 returns an object like
  /// `{href: ...}`. Normalizes both to the URL string (empty when absent).
  String _pagingHref(dynamic nextPage) {
    if (nextPage == null) return '';
    if (nextPage is Map) {
      return '${nextPage['href'] ?? ''}';
    }
    return '$nextPage';
  }

  /// Maximo OSLC paging links (`responseInfo.nextPage`) are absolute URLs.
  /// [maximoRequest] expects a URL relative to the environment's domain
  /// (it re-adds the domain, auth and lean=1). Returns null when the href
  /// does not start with the configured domain for [env].
  String? _relativePagingUrl(String href) {
    final domain = maximoServerDomains[env] ?? '';
    if (domain.isNotEmpty && href.startsWith(domain)) {
      return href.substring(domain.length);
    }
    return null;
  }

  /// Picker rows for the grid: released parent work orders for [site].
  /// Rows that are children of another WO are filtered out (they are
  /// covered by their parent's packet). The query is paged for sites with
  /// many released work orders; [onStatus] receives progress text for the
  /// UI between pages.
  Future<List<Map<String, dynamic>>> fetchReleasedWorkOrderRows({
    void Function(String status)? onStatus,
  }) async {
    final rows = await _queryIn(
      'mxwo',
      'status',
      const ['RELEASED'],
      extraWhere: ' and istask=0',
      select: _parentSelect,
      step: 'the released work order list',
      onStatus: onStatus,
    );
    return rows.where((r) => '${r['parent'] ?? ''}'.isEmpty).toList();
  }

  /// Picker rows for a pasted list of wonums (any status; the UI only lets
  /// released parents be selected). Returned rows keep their `parent` field
  /// so pasted children can be shown with a reason instead of "not found".
  Future<List<Map<String, dynamic>>> fetchWorkOrderRowsForWonums(
    List<String> wonums,
  ) async {
    final cleaned = wonums
        .map((w) => w.trim().toUpperCase())
        .where((w) => w.isNotEmpty)
        .toSet()
        .toList();
    if (cleaned.isEmpty) return const [];
    return _queryIn(
      'mxwo',
      'wonum',
      cleaned,
      select: _parentSelect,
      step: 'the pasted work orders',
    );
  }

  /// Fetches complete packets for [parentWonums], in request order.
  ///
  /// [onStatus] receives progress text for the UI between the batched
  /// queries (the app's connection pool serializes them anyway).
  Future<WoPrintBatch> fetchPackets(
    List<String> parentWonums, {
    void Function(String status)? onStatus,
  }) async {
    final parents = parentWonums
        .map((w) => w.trim().toUpperCase())
        .toSet()
        .toList();
    if (parents.isEmpty) {
      return const WoPrintBatch(packets: []);
    }

    // 1. parent headers (also covers pasted WOs that turn out to be children)
    onStatus?.call('Fetching work order headers...');
    final returnedRows = await _queryIn(
      'mxwo',
      'wonum',
      parents,
      select: _parentSelect,
      step: 'work order headers',
    );

    final returnedWonums = returnedRows.map((r) => '${r['wonum']}').toSet();
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
        skippedChildren: skippedChildren,
      );
    }

    // 2. child work orders (istask=0 with a parent set)
    onStatus?.call('Fetching child work orders...');
    final childRowsRaw = await _queryIn(
      'mxwo',
      'parent',
      validParents,
      select: _childSelect,
      step: 'child work orders',
    );
    final childRows = childRowsRaw
        .where((r) => r['istask'].toString() != 'true')
        .toList();

    // 3. all task WOs of the whole tree in one in-list query
    onStatus?.call('Fetching task work orders...');
    final treeWonums = [
      ...validParents,
      ...childRows.map((r) => '${r['wonum']}'),
    ];
    final taskRows = await _queryIn(
      'mxwo',
      'parent',
      treeWonums,
      extraWhere: ' and istask=1',
      select: _taskSelect,
      step: 'task work orders',
    );

    // 4. asset descriptions (parent + children) in one in-list query
    onStatus?.call('Fetching asset descriptions...');
    final assetNums = <String>{
      for (final r in [...validParentRows, ...childRows])
        if ('${r['assetnum'] ?? ''}'.isNotEmpty) '${r['assetnum']}',
    }.toList();
    final assetRows = assetNums.isEmpty
        ? const <Map<String, dynamic>>[]
        : await _queryIn(
            'mxasset',
            'assetnum',
            assetNums,
            select: const ['assetnum', 'description'],
            step: 'asset descriptions',
          );

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
        // Reserved-material storeroom bins (BINNUM) live on INVRESERVE;
        // each WPMATERIAL row links to its reservation via reserveid.
        'invreserve',
      ],
      step: 'planned labor and materials',
    );

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
