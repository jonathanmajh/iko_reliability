// Work Order Print Pack — data model + PDF renderer.
//
// Replaces the OOTB BIRT report (woprint2.rptdesign) for batch printing of
// released work orders. Pure Dart (`package:pdf`) so it can be used from the
// Flutter desktop UI and from CLI tools.
//
// Layout:
// - US Letter portrait, one parent work order per packet.
// - Cover section: header block, key/value grid, costs, tasks, planned
//   labor/materials/tools, demo note (optional), sign-off strip.
// - Every child work order starts on its own page (asset, tasks, planned
//   materials). Children are not scheduled, so there is no schedule block.
library;

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// One field of a work order record (parent or child).
typedef WoRecord = Map<String, dynamic>;

/// Task work order (task route) belonging to a parent or child WO.
class WoTask {
  final String wonum;
  final String? taskid;
  final String description;
  final String? longDesc; // raw long description (html or plain) -> notes column
  final String? measurement; // meter point / reading text, when available
  final String? status;

  const WoTask({
    required this.wonum,
    required this.description,
    this.taskid,
    this.longDesc,
    this.measurement,
    this.status,
  });
}

/// Planned labor row (WPLABOR) / assignment row.
class PlannedLaborRow {
  final String laborcode;
  final String? name;
  final String? craft;
  final String? skilllevel;
  final String? hours;

  const PlannedLaborRow(this.laborcode,
      {this.name, this.craft, this.skilllevel, this.hours});
}

/// Planned material row (WPMATERIAL).
class PlannedMaterialRow {
  final String item;
  final String? description;
  final String? qty;

  /// Storeroom bin holding the item (INVRESERVE.BINNUM, resolved through
  /// the row's reservation), e.g. `A-9-3`.
  final String? binnum;
  final String? storeroom;

  const PlannedMaterialRow(this.item,
      {this.description, this.qty, this.binnum, this.storeroom});
}

/// Planned tool row (WPTOOL).
class PlannedToolRow {
  final String item;
  final String? description;
  final String? qty;
  final String? hours;
  final String? rate;

  const PlannedToolRow(this.item, {this.description, this.qty, this.hours, this.rate});
}

/// One child work order with its own tasks and planned materials.
class WoChildPacket {
  final WoRecord header;
  final List<WoTask> tasks;
  final List<PlannedMaterialRow> materials;

  const WoChildPacket({
    required this.header,
    required this.tasks,
    this.materials = const [],
  });
}

/// A complete printable packet for one parent work order.
///
/// [header] keys (all optional):
/// wonum, description, longdesc (raw html/plain), status, worktype,
/// wopriority, siteid, orgid, assetnum, assetdesc, location, jpnum, pmnum,
/// supervisor, schedstart, schedfinish, targstartdate, targcompdate,
/// reportdate, conditions, duration, estlabor, estmat, esttool, estserv.
class WoPacket {
  final WoRecord header;
  final List<WoTask> tasks;
  final List<PlannedLaborRow> labor;
  final List<PlannedLaborRow> assignments;
  final List<PlannedMaterialRow> materials;
  final List<PlannedToolRow> tools;
  final List<WoChildPacket> children;

  /// Extra note printed on the cover (e.g. design-review placeholder notice).
  final String? demoNote;

  const WoPacket({
    required this.header,
    required this.tasks,
    this.labor = const [],
    this.assignments = const [],
    this.materials = const [],
    this.tools = const [],
    this.children = const [],
    this.demoNote,
  });
}

/// Maps characters the fonts may not have (or that render poorly) to plain
/// ASCII equivalents.
const Map<int, String> _charReplacements = {
  0x00A0: ' ', // no-break space
  0x2010: '-',
  0x2011: '-',
  0x2012: '-',
  0x2013: '-',
  0x2014: '-',
  0x2015: '-',
  0x2022: '-',
  0x2032: "'",
  0x2033: '"',
  0x2190: '<-',
  0x2192: '->',
  0x2248: '~',
  0x2260: '!=',
  0x2264: '<=',
  0x2265: '>=',
};

/// Code points in the cp1252 upper range (curly quotes, dashes, tm, oe...)
/// that standard PDF fonts encode.
const Set<int> _cp1252Extras = {
  0x20AC, 0x201A, 0x0192, 0x201E, 0x2026, 0x2020, 0x2021, 0x02C6, 0x2030,
  0x0160, 0x2039, 0x0152, 0x017D, 0x2018, 0x2019, 0x201C, 0x201D, 0x02DC,
  0x2122, 0x0161, 0x203A, 0x0153, 0x017E, 0x0178,
};

/// True for characters that never render well in the print pack and are
/// dropped: control characters, combining diacritics (the pdf package does
/// no OpenType shaping, so they would render detached), zero-width /
/// bidi marks, and variation selectors.
bool _isDroppedCodePoint(int r) {
  if (r == 0x0A) return false; // newline is meaningful
  if (r < 0x20) return true; // control
  if (r >= 0x7F && r <= 0x9F) return true; // C1 control
  if (r >= 0x0300 && r <= 0x036F) return true; // combining diacritics
  if (r >= 0x0483 && r <= 0x0489) return true; // combining marks
  if (r >= 0x0591 && r <= 0x05BD) return true; // hebrew points
  if (r >= 0x064B && r <= 0x065F) return true; // arabic points
  if (r == 0x00AD || r == 0x180E) return true; // soft hyphen etc.
  if (r >= 0x200B && r <= 0x200F) return true; // zero width + dir marks
  if (r >= 0x202A && r <= 0x202E) return true; // bidi controls
  if (r >= 0x2060 && r <= 0x2064) return true; // word joiner etc.
  if (r >= 0xFE00 && r <= 0xFE0F) return true; // variation selectors
  if (r == 0xFFFE || r == 0xFFFF) return true; // non-characters
  return false;
}

/// Flattens text so it renders reliably in the PDF: drops the characters
/// from [_isDroppedCodePoint], maps [_charReplacements], and keeps the
/// ranges the embedded Roboto font covers well (ASCII, Latin-1, Latin
/// Extended-A for Polish/Czech/Slovak etc., cp1252 extras). Anything else
/// (geometric shapes, emoji, CJK) is dropped — missing glyphs would render
/// as empty boxes.
String sanitizePdfText(String src) {
  var needsWork = false;
  for (final r in src.runes) {
    if (r > 0x7E || _isDroppedCodePoint(r) || _charReplacements.containsKey(r)) {
      needsWork = true;
      break;
    }
  }
  if (!needsWork) return src;
  final sb = StringBuffer();
  for (final r in src.runes) {
    final repl = _charReplacements[r];
    if (repl != null) {
      sb.write(repl);
      continue;
    }
    if (_isDroppedCodePoint(r)) continue;
    if (r >= 0x20 && r <= 0x7E) {
      sb.writeCharCode(r); // ASCII
      continue;
    }
    if (r >= 0xA0 && r <= 0xFF) {
      sb.writeCharCode(r); // Latin-1
      continue;
    }
    if (r >= 0x0100 && r <= 0x017F) {
      sb.writeCharCode(r); // Latin Extended-A (European)
      continue;
    }
    if (_cp1252Extras.contains(r)) {
      sb.writeCharCode(r); // curly quotes etc.
      continue;
    }
    // anything else: dropped (would render as a box)
  }
  return sb.toString();
}

/// Flattens Maximo CKHTML long descriptions to plain text.
String htmlToPlainText(String? src) {
  if (src == null) return '';
  var s = src.trim();
  if (s.isEmpty) return '';
  s = s
      .replaceAll('</p>', '\n')
      .replaceAll('</div>', '\n')
      .replaceAll('</ul>', '\n')
      .replaceAll('</ol>', '\n')
      .replaceAll('</li>', '\n')
      .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '- ')
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]*>'), ' ');
  s = s
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&bull;', '-');
  s = s.replaceAllMapped(
      RegExp(r'&#(\d+);'), (m) => String.fromCharCode(int.parse(m.group(1)!)));
  final lines = s
      .split('\n')
      .map((l) => l.replaceAll(RegExp(r'[ \t]+'), ' ').trim())
      .where((l) => l.isNotEmpty)
      .toList();
  return sanitizePdfText(lines.join('\n'));
}

/// Typeface set used by the print pack. Pass one loaded from the bundled
/// Roboto TTFs (see the app page / CLI tools); null falls back to the
/// built-in Helvetica (cp1252 only).
class WoPrintFonts {
  final pw.Font base;
  final pw.Font bold;
  final pw.Font italic;
  final pw.Font boldItalic;

  const WoPrintFonts({
    required this.base,
    required this.bold,
    required this.italic,
    required this.boldItalic,
  });
}

// ---------------------------------------------------------------------------
// palette + small helpers
// ---------------------------------------------------------------------------

const _ink = PdfColors.black;
const _muted = PdfColor.fromInt(0xFF5A6064);
const _rule = PdfColor.fromInt(0xFFAFB4B8);
const _fillHeader = PdfColor.fromInt(0xFFE8E9EA);
const _fillBanner = PdfColor.fromInt(0xFFF2F3F4);
const _fillRow = PdfColor.fromInt(0xFFF8F9FA);

const _labelStyle = pw.TextStyle(fontSize: 6.4, color: _muted, letterSpacing: 0.8);

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _v(WoRecord m, String key) {
  final v = m[key];
  if (v == null) return '';
  return sanitizePdfText(v.toString());
}

String _fmtDate(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  return '${_months[dt.month - 1]} ${dt.day} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

String _fmtDateOnly(DateTime dt) =>
    '${_months[dt.month - 1]} ${dt.day}, ${dt.year}';

// ---------------------------------------------------------------------------
// widgets
// ---------------------------------------------------------------------------

pw.Widget _sectionTitle(String title, {double top = 10}) {
  return pw.Padding(
    padding: pw.EdgeInsets.only(top: top, bottom: 3),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title.toUpperCase(),
            style: const pw.TextStyle(
                fontSize: 8.6,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 1.4,
                color: _ink)),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 2),
          child: pw.Divider(color: _ink, thickness: 0.9, height: 0.2),
        ),
      ],
    ),
  );
}

pw.Widget _emptyNote(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 2, bottom: 1),
      child: pw.Text(text,
          style: const pw.TextStyle(
              fontSize: 8, color: _muted, fontStyle: pw.FontStyle.italic)),
    );

pw.Widget _chip(String text) => pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _ink, width: 0.9),
        borderRadius: pw.BorderRadius.circular(2.5),
        color: PdfColors.white,
      ),
      child: pw.Text(sanitizePdfText(text).toUpperCase(),
          style: const pw.TextStyle(
              fontSize: 7.6,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 1.1,
              color: _ink)),
    );

/// Key/value grid, three pairs per row.
pw.Widget _kvGrid(List<(String, String)> kv) {
  const labelW = 58.0;
  final tableRows = <pw.TableRow>[];
  for (var i = 0; i < kv.length; i += 3) {
    final cells = <pw.Widget>[];
    for (var j = i; j < i + 3; j++) {
      final label = j < kv.length ? kv[j].$1 : '';
      final value = j < kv.length ? kv[j].$2 : '';
      cells.add(pw.Padding(
        padding: pw.EdgeInsets.only(right: 5, top: 2.5, bottom: 2.5),
        child: pw.Text(label.toUpperCase(), style: _labelStyle),
      ));
      cells.add(pw.Padding(
        padding: pw.EdgeInsets.only(right: 10, top: 2.5, bottom: 2.5),
        child: pw.Text(
            value.isEmpty ? '-' : sanitizePdfText(value),
            style: const pw.TextStyle(fontSize: 8.4, color: _ink)),
      ));
    }
    tableRows.add(pw.TableRow(children: cells));
  }
  return pw.Table(
    columnWidths: {
      0: const pw.FixedColumnWidth(labelW),
      1: const pw.FlexColumnWidth(),
      2: const pw.FixedColumnWidth(labelW),
      3: const pw.FlexColumnWidth(),
      4: const pw.FixedColumnWidth(labelW),
      5: const pw.FlexColumnWidth(),
    },
    children: tableRows,
  );
}

/// Simple bordered table. Use `width <= 0` for the stretch column.
pw.Widget _table({
  required List<String> headers,
  required List<double> widths,
  required List<List<String>> rows,
  double fontSize = 8.0,
}) {
  final headerRow = pw.TableRow(
    decoration: const pw.BoxDecoration(color: _fillHeader),
    children: [
      for (final h in headers)
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          child: pw.Text(sanitizePdfText(h).toUpperCase(),
              style: const pw.TextStyle(
                  fontSize: 7.4,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 0.6,
                  color: _ink)),
        ),
    ],
  );
  final dataRows = rows.asMap().entries.map((e) {
    final fill = e.key.isOdd ? const pw.BoxDecoration(color: _fillRow) : null;
    return pw.TableRow(
      decoration: fill,
      children: [
        for (final cell in e.value)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3.5),
            // No `lineSpacing` here: with it, dart_pdf's row splitter loops
            // forever when a row has to break across pages — regression
            // covered by the page-spanning packet in wo_print_batch_smoke.
            child: pw.Text(sanitizePdfText(cell),
                style: pw.TextStyle(fontSize: fontSize, color: _ink)),
          ),
      ],
    );
  }).toList();

  return pw.Table(
    border: pw.TableBorder.all(color: _rule, width: 0.5),
    columnWidths: {
      for (var i = 0; i < widths.length; i++)
        i: widths[i] > 0
            ? pw.FixedColumnWidth(widths[i])
            : pw.FlexColumnWidth(-widths[i]),
    },
    children: [headerRow, ...dataRows],
  );
}

pw.Widget _signature(String label) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          height: 20,
          width: 158,
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _rule, width: 0.6)),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 3),
          child: pw.Text(label.toUpperCase(), style: _labelStyle),
        ),
      ],
    );

// dart_pdf's Table splits tables BETWEEN rows only, and defers a row that
// doesn't fit the remaining space to the next page. That's fine visually as
// long as rows are task-sized — one row per task (readers see one task).
// The only exception: a task tall enough to exceed a whole page would defer
// forever (the maxPages crash), so it is subdivided into continuation rows
// marked with '…' in the # column.
const _taskMaxLinesPerRow = 45; // ≈ 460pt — well under a page
const _taskCharsPerLine = 64; // conservative vs the real wrap (~79)

List<List<String>> _tasksRows(List<WoTask> tasks) {
  return [
    for (final t in tasks) ..._taskRowFragments(t),
  ];
}

/// Text of a task as it renders in the table: description, then the long
/// description below it.
String _taskText(WoTask t) =>
    (t.longDesc != null && t.longDesc!.isNotEmpty)
        ? '${t.description}\n${htmlToPlainText(t.longDesc!)}'
        : t.description;

/// Fragments of one task in the table: one row for normal tasks; numbered
/// continuation rows marked `…` only when a single task would overflow a
/// full page.
List<List<String>> _taskRowFragments(WoTask t) {
  final text = _taskText(t);
  if (_estimateLines(text) <= _taskMaxLinesPerRow) {
    return [
      [t.taskid ?? '', text, ''],
    ]; // blank column for the technician's notes / measurements
  }
  final lines = _wrapLines(text);
  final rows = <List<String>>[];
  for (var i = 0; i < lines.length; i += _taskMaxLinesPerRow) {
    final end = (i + _taskMaxLinesPerRow) < lines.length
        ? i + _taskMaxLinesPerRow
        : lines.length;
    rows.add([
      i == 0 ? (t.taskid ?? '') : '…',
      lines.sublist(i, end).join('\n'),
      '',
    ]);
  }
  return rows;
}

/// Lines the text would occupy in the task column at a conservative
/// ~[_taskCharsPerLine] chars per line (the real column fits ~79, so this
/// over-counts height and never under-triggers the full-page guard).
int _estimateLines(String text) {
  var n = 0;
  for (final para in text.split('\n')) {
    n += para.isEmpty ? 1 : (para.length + _taskCharsPerLine - 1) ~/ _taskCharsPerLine;
  }
  return n;
}

/// Word-boundary wrap (hard-breaking rare tokens over a line).
List<String> _wrapLines(String text) {
  final lines = <String>[];
  for (final para in text.split('\n')) {
    if (para.isEmpty) {
      lines.add('');
      continue;
    }
    var line = '';
    for (final word in para.split(' ')) {
      var rest = word;
      while (rest.length > _taskCharsPerLine) {
        if (line.isNotEmpty) {
          lines.add(line);
          line = '';
        }
        lines.add(rest.substring(0, _taskCharsPerLine));
        rest = rest.substring(_taskCharsPerLine);
      }
      if (line.isEmpty) {
        line = rest;
      } else if (line.length + 1 + rest.length <= _taskCharsPerLine) {
        line = '$line $rest';
      } else {
        lines.add(line);
        line = rest;
      }
    }
    if (line.isNotEmpty) lines.add(line);
  }
  return lines;
}

const _taskTableSpec = (
  headers: <String>['#', 'Task', 'Notes / Measurements'],
  // Task column stretches; notes column stays a fixed-width blank
  // write-in area for the technician.
  widths: <double>[30, -1, 170],
);

// ---------------------------------------------------------------------------
// cover (parent) section
// ---------------------------------------------------------------------------

List<pw.Widget> _coverWidgets(WoPacket packet, String printedDate) {
  final h = packet.header;
  final wonum = _v(h, 'wonum');
  final status = _v(h, 'status');
  final body = <pw.Widget>[];

  // title block
  body.add(pw.Padding(
    padding: pw.EdgeInsets.only(bottom: 5),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(wonum,
              style: const pw.TextStyle(fontSize: 21, fontWeight: pw.FontWeight.bold)),
        ]),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          _chip(status.isEmpty ? 'WORK ORDER' : status),
          pw.Padding(
              padding: pw.EdgeInsets.only(top: 4),
              child: pw.Text('Printed $printedDate',
                  style: pw.TextStyle(fontSize: 6.8, color: _muted))),
        ]),
      ],
    ),
  ));
  body.add(pw.Divider(color: _ink, thickness: 1.1, height: 1));
  body.add(pw.Padding(
    padding: pw.EdgeInsets.symmetric(vertical: 7),
    child: pw.Text(_v(h, 'description'), style: pw.TextStyle(fontSize: 10.6, color: _ink)),
  ));

  // info grid
  body.add(_kvGrid([
    ('Site', _v(h, 'siteid')),
    ('Work Type', _v(h, 'worktype')),
    ('Priority', _v(h, 'wopriority') == '' ? '' : 'P${_v(h, 'wopriority')}'),
    (
      'Asset',
      _v(h, 'assetnum').isEmpty
          ? ''
          : _v(h, 'assetdesc').isEmpty
              ? _v(h, 'assetnum')
              : '${_v(h, 'assetnum')} - ${_v(h, 'assetdesc')}'
    ),
    ('Location', _v(h, 'location')),
    ('Conditions', _v(h, 'conditions')),
    ('Job Plan', _v(h, 'jpnum')),
    ('PM', _v(h, 'pmnum')),
    ('Duration (h)', _v(h, 'duration')),
    ('Supervisor', _v(h, 'supervisor')),
    ('Reported', _fmtDate(_v(h, 'reportdate'))),
    (
      'Target',
      _v(h, 'targstartdate') == '' && _v(h, 'targcompdate') == ''
          ? ''
          : '${_fmtDate(_v(h, 'targstartdate'))} - ${_fmtDate(_v(h, 'targcompdate'))}'
    ),
    ('Child WOs', packet.children.isEmpty ? '' : '${packet.children.length}'),
  ]));

  // details / long description
  final longDesc = htmlToPlainText(h['longdesc'] as String?);
  if (longDesc.isNotEmpty) {
    body.add(_sectionTitle('Work Details'));
    body.add(pw.Text(longDesc, style: pw.TextStyle(fontSize: 9.6, color: _ink)));
  }

  // parent tasks
  body.add(_sectionTitle('Tasks'));
  body.add(packet.tasks.isEmpty
      ? _emptyNote('No tasks planned.')
      : _table(
          headers: _taskTableSpec.headers,
          widths: _taskTableSpec.widths,
          rows: _tasksRows(packet.tasks),
        ));

  // labor: assignments replace planned labor when present
  final showAssignments = packet.assignments.isNotEmpty;
  body.add(_sectionTitle(showAssignments ? 'Assigned Labor' : 'Planned Labor'));
  final laborRows = showAssignments ? packet.assignments : packet.labor;
  if (laborRows.isEmpty) {
    body.add(_emptyNote(showAssignments ? 'No assigned labor.' : 'No planned labor.'));
  } else {
    body.add(_table(
      headers: const ['Labor', 'Name', 'Craft', 'Skill', 'Hrs'],
      widths: const [74, -1, 76, 58, 44],
      rows: [
        for (final l in laborRows)
          [
            l.laborcode,
            l.name ?? '',
            l.craft ?? '',
            l.skilllevel ?? '',
            l.hours ?? '',
          ],
      ],
    ));
  }

  // planned materials
  body.add(_sectionTitle('Planned Materials'));
  if (packet.materials.isEmpty) {
    body.add(_emptyNote('No planned materials.'));
  } else {
    body.add(_table(
      headers: ['Item', 'Description', 'Qty', 'Qty Used', 'Bin', 'Storeroom'],
      widths: [70, -1, 40, 42, 56, 76],
      rows: [
        for (final m in packet.materials)
          [
            m.item,
            m.description ?? '',
            m.qty ?? '',
            '', // blank: technician writes the quantity used
            m.binnum ?? '',
            m.storeroom ?? '',
          ],
      ],
    ));
  }

  // planned tools
  body.add(_sectionTitle('Planned Tools'));
  if (packet.tools.isEmpty) {
    body.add(_emptyNote('No planned tools.'));
  } else {
    body.add(_table(
      headers: ['Item', 'Description', 'Qty', 'Hrs', 'Rate'],
      widths: [70, -1, 44, 46, 62],
      rows: [
        for (final t in packet.tools)
          [t.item, t.description ?? '', t.qty ?? '', t.hours ?? '', t.rate ?? ''],
      ],
    ));
  }

  // demo placeholder note (design review only)
  if (packet.demoNote != null && packet.demoNote!.isNotEmpty) {
    body.add(pw.Padding(
      padding: pw.EdgeInsets.only(top: 10),
      child: pw.Container(
        padding: pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _rule, width: 0.5),
          color: _fillRow,
        ),
        child: pw.Text(sanitizePdfText(packet.demoNote!),
            style: pw.TextStyle(fontSize: 7.6, color: _muted, fontStyle: pw.FontStyle.italic)),
      ),
    ));
  }

  // sign-off strip
  body.add(pw.Padding(
    padding: pw.EdgeInsets.only(top: 14),
    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Divider(color: _rule, thickness: 0.6, height: 0.6),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _signature('Completed by / Date'),
          _signature('Time / Hours'),
          _signature('Reviewed by'),
        ],
      ),
    ]),
  ));

  // Flat list, NOT a Column — same reason as the child section: the tables
  // must negotiate page breaks directly with the MultiPage.
  return body;
}

// ---------------------------------------------------------------------------
// child section
// ---------------------------------------------------------------------------

List<pw.Widget> _childWidgets(WoChildPacket child) {
  final h = child.header;
  final longDesc = htmlToPlainText(h['longdesc'] as String?);
  final parts = <pw.Widget>[];

  // banner
  parts.add(pw.Container(
    padding: pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(color: _fillBanner),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(_v(h, 'wonum'),
                style: pw.TextStyle(
                    fontSize: 12.5, fontWeight: pw.FontWeight.bold, color: _ink)),
            pw.Text(_v(h, 'status').toUpperCase(),
                style: pw.TextStyle(
                    fontSize: 7.6,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1,
                    color: _muted)),
          ],
        ),
        pw.Padding(
          padding: pw.EdgeInsets.only(top: 2, bottom: 3),
          child: pw.Text(_v(h, 'description'), style: pw.TextStyle(fontSize: 9, color: _ink)),
        ),
        pw.Text(
          [
            if (_v(h, 'assetnum').isNotEmpty)
              _v(h, 'assetdesc').isNotEmpty
                  ? 'Asset ${_v(h, 'assetnum')} - ${_v(h, 'assetdesc')}'
                  : 'Asset ${_v(h, 'assetnum')}'
            else
              'Asset -',
            if (_v(h, 'location').isNotEmpty) 'Location ${_v(h, 'location')}',
            'Child of ${_v(h, 'parent')}'
          ].join('    |    '),
          style: pw.TextStyle(fontSize: 6.8, color: _muted),
        ),
      ],
    ),
  ));

  if (longDesc.isNotEmpty) {
    parts.add(_sectionTitle('Details'));
    parts.add(pw.Text(longDesc, style: pw.TextStyle(fontSize: 9.2, color: _ink)));
  }

  parts.add(_sectionTitle('Tasks'));
  parts.add(child.tasks.isEmpty
      ? _emptyNote('No tasks planned.')
      : _table(
          headers: _taskTableSpec.headers,
          widths: _taskTableSpec.widths,
          rows: _tasksRows(child.tasks),
        ));

  parts.add(_sectionTitle('Planned Materials'));
  if (child.materials.isEmpty) {
    parts.add(_emptyNote('No planned materials.'));
  } else {
    parts.add(_table(
      headers: ['Item', 'Description', 'Qty', 'Qty Used', 'Bin', 'Storeroom'],
      widths: [70, -1, 40, 42, 56, 76],
      rows: [
        for (final m in child.materials)
          [
            m.item,
            m.description ?? '',
            m.qty ?? '',
            '', // blank: technician writes the quantity used
            m.binnum ?? '',
            m.storeroom ?? '',
          ],
      ],
    ));
  }

  parts.add(pw.Padding(
    padding: pw.EdgeInsets.only(top: 16),
    child: pw.Text('Completed by: ______________    Date: ____________',
        style: pw.TextStyle(fontSize: 7.4, color: _muted)),
  ));

  // Flat list, NOT a Column: MultiPage's page-break negotiation must reach
  // the tasks/materials tables directly. Inside a Column they'd be deferred
  // whole to the next page, leaving the previous page mostly blank.
  return parts;
}

// ---------------------------------------------------------------------------
// entry point
// ---------------------------------------------------------------------------

/// Renders [packets] into one document (no total page label), returns bytes
/// + page count. Each packet's cover starts on a fresh page; footer page
/// numbers run continuously across the whole document.
Future<({Uint8List bytes, int pages})> _renderAll(
  List<WoPacket> packets,
  String printedDate,
  int? totalPages,
  WoPrintFonts? fonts,
) async {
  final doc = pw.Document(
    theme: pw.ThemeData.withFont(
      base: fonts?.base ?? pw.Font.helvetica(),
      bold: fonts?.bold ?? pw.Font.helveticaBold(),
      italic: fonts?.italic ?? pw.Font.helveticaOblique(),
      boldItalic: fonts?.boldItalic ?? pw.Font.helveticaBoldOblique(),
    ),
  );

  for (final packet in packets) {
    final wonum = _v(packet.header, 'wonum');
    // Guard against runaway layout, but scale with the tree: a parent with
    // hundreds of child WOs legitimately produces hundreds of pages.
    final taskCount = packet.tasks.length +
        packet.children.fold<int>(0, (n, c) => n + c.tasks.length);
    final maxPages = 100 + packet.children.length * 3 + taskCount;

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: pw.EdgeInsets.fromLTRB(32, 30, 32, 36),
      maxPages: maxPages,
      build: (ctx) => [
        ..._coverWidgets(packet, printedDate),
        for (final child in packet.children) ...[
          pw.NewPage(),
          ..._childWidgets(child),
        ],
      ],
      footer: (ctx) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            totalPages == null
                ? 'WO $wonum - Page ${ctx.pageNumber}'
                : 'WO $wonum - Page ${ctx.pageNumber} of $totalPages',
            style: pw.TextStyle(fontSize: 6.6, color: _muted),
          ),
          pw.Text('Printed $printedDate',
              style: pw.TextStyle(fontSize: 6.6, color: _muted)),
        ],
      ),
    ));
  }

  final bytes = await doc.save();
  final pages = doc.document.pdfPageList.pages.length;
  return (bytes: bytes, pages: pages);
}

/// Builds the complete print pack PDF for one parent work order.
///
/// Renders twice: the first pass is only used to count pages so the footer
/// can show "Page X of Y".
Future<Uint8List> buildWoPacketPdf(
  WoPacket packet, {
  DateTime? printed,
  WoPrintFonts? fonts,
}) =>
    buildWoBatchPdf([packet], printed: printed, fonts: fonts);

/// Builds one merged PDF for a batch of work order packets (each packet is
/// a cover + one page per child WO, pages numbered continuously).
Future<Uint8List> buildWoBatchPdf(
  List<WoPacket> packets, {
  DateTime? printed,
  WoPrintFonts? fonts,
}) async {
  if (packets.isEmpty) {
    throw ArgumentError('buildWoBatchPdf: no packets to render.');
  }
  final printedDate = _fmtDateOnly(printed ?? DateTime.now());
  final first = await _renderAll(packets, printedDate, null, fonts);
  final second = await _renderAll(packets, printedDate, first.pages, fonts);
  return second.bytes;
}
