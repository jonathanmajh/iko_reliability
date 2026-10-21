// Pure assembly of print packets from raw Maximo rows.
//
// No network, no Flutter imports — shared by the app's fetch layer
// (wo_fetch.dart) and the CLI tools, which render from dumped JSON files
// (tool/prod_wo_dump.ps1 output) without needing an API key.

import 'wo_packet.dart';

/// Result of a print pack assembly.
class WoPrintBatch {
  /// Complete packets, in the same order as the requested wonums.
  final List<WoPacket> packets;

  /// Requested wonums Maximo returned nothing for.
  final List<String> notFound;

  /// Child WOs that were folded into their parent's packet instead of
  /// being rendered standalone.
  final List<String> skippedChildren;

  const WoPrintBatch({
    required this.packets,
    this.notFound = const [],
    this.skippedChildren = const [],
  });
}

/// Assembles print packets from raw Maximo rows.
WoPrintBatch assembleWoPrintBatch({
  required List<String> parents,
  required List<Map<String, dynamic>> validParentRows,
  required List<Map<String, dynamic>> childRows,
  required List<Map<String, dynamic>> taskRows,
  required List<Map<String, dynamic>> assetRows,
  required List<Map<String, dynamic>> planRows,
  required String site,
  List<String> notFound = const [],
  List<String> skippedChildren = const [],
}) {
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

  final assetDesc = <String, String>{
    for (final a in assetRows) '${a['assetnum']}': '${a['description'] ?? ''}',
  };

  final planByWonum = <String, Map<String, dynamic>>{
    for (final r in planRows) '${r['wonum']}': r,
  };

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

  return WoPrintBatch(
      packets: packets,
      notFound: notFound,
      skippedChildren: skippedChildren);
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

/// Storeroom bins for one detail record's planned materials, keyed for
/// lookup: by `reserveid` (the reservation a WPMATERIAL row points at) and
/// by `'itemnum|location'` (fallback for material rows with no
/// reservation record). [rows] are the record's INVRESERVE children.
Map<String, String> invReserveBinsOf(List<Map<String, dynamic>> rows) {
  final bins = <String, String>{};
  for (final r in rows) {
    final bin = '${r['binnum'] ?? ''}';
    if (bin.isEmpty) continue;
    final rid = '${r['reserveid'] ?? ''}';
    final item = '${r['itemnum'] ?? ''}';
    final loc = '${r['location'] ?? ''}';
    if (rid.isNotEmpty && rid != '0') bins[rid] = bin;
    if (item.isNotEmpty) bins['$item|$loc'] = bin;
  }
  return bins;
}

PlannedMaterialRow? materialFromMaximo(Map<String, dynamic> m,
    [Map<String, String> bins = const {}]) {
  final item = m['itemnum'] == null ? '' : '${m['itemnum']}';
  final desc = m['description'] == null ? '' : '${m['description']}';
  if (item.isEmpty && desc.isEmpty) return null;
  final loc = m['location'] == null ? '' : '${m['location']}';
  final rid = '${m['reserveid'] ?? ''}';
  // BINNUM is on INVRESERVE, not on WPMATERIAL: prefer the row's own
  // reservation, then any reservation of the same item + storeroom.
  final bin = (rid.isNotEmpty && rid != '0' ? bins[rid] : null) ??
      bins['$item|$loc'] ??
      '';
  return PlannedMaterialRow(
    item,
    description: desc,
    qty: m['itemqty'] == null ? '' : _fmtVal(m['itemqty']),
    binnum: bin,
    storeroom: loc,
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

/// Live planned material (WPMATERIAL) rows. BINNUM comes from the same
/// detail record's INVRESERVE children (see [invReserveBinsOf]).
List<PlannedMaterialRow> materialRowsOf(Map<String, dynamic>? rec) {
  final bins = invReserveBinsOf(
      (rec?['invreserve'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>());
  return [
    for (final m in (rec?['wpmaterial'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>())
      if (materialFromMaximo(m, bins) != null) materialFromMaximo(m, bins)!,
  ];
}

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
