// Work Order Print — batch printing for released work orders.
//
// Replaces the OOTB BIRT report (woprint2.rptdesign) for normal users:
// pick released parent work orders (by site filter or a pasted list),
// fetch their full trees (child WOs, tasks, planned data), then either
// print the merged pack directly, save a merged + per-WO PDFs, or save
// just the merged pack as a single PDF.

import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../bin/consts.dart';
import '../bin/drawer.dart';
import '../bin/end_drawer.dart';
import '../notifiers/maximo_server_notifier.dart';
import '../settings/settings_notifier.dart';
import 'wo_fetch.dart';
import 'wo_packet.dart';

@RoutePage()
class WoPrintPage extends StatefulWidget {
  const WoPrintPage({super.key});

  @override
  State<WoPrintPage> createState() => _WoPrintPageState();
}

/// One selectable row in the work order picker grid.
class WoListRow {
  final Map<String, dynamic> record;

  WoListRow(this.record);

  String get wonum => '${record['wonum'] ?? ''}';
  String get description => '${record['description'] ?? ''}';
  String get status => '${record['status'] ?? ''}';
  String get assetnum => '${record['assetnum'] ?? ''}';
  String get parent => '${record['parent'] ?? ''}';

  /// When the WO last changed status (ISO datetime or '').
  String get statusDate => '${record['statusdate'] ?? ''}';

  /// When the WO is scheduled to start (ISO datetime or '').
  String get schedStart => '${record['schedstart'] ?? ''}';

  /// Target start (ISO datetime or '').
  String get targetStart => '${record['targstartdate'] ?? ''}';

  String get target {
    final t = '${record['targstartdate'] ?? ''}';
    final dt = DateTime.tryParse(t);
    if (dt == null) return '';
    return DateFormat('MMM d').format(dt);
  }

  /// Only released parents can be printed.
  bool get printable => status == 'RELEASED' && parent.isEmpty;

  String get statusLabel {
    if (status.isEmpty) return 'not found';
    if (parent.isNotEmpty) return 'child of $parent';
    return status;
  }
}

class _WoPrintPageState extends State<WoPrintPage> {
  bool _pasteMode = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _pasteController = TextEditingController();

  List<WoListRow> _rows = <WoListRow>[];
  final Set<String> _selected = <String>{};

  // optional date filters (picked in a date selector, matched on the
  // date portion of the work order fields)
  DateTime? _releasedOn; // WORKORDER.STATUSDATE (+ status RELEASED)
  DateTime? _targetOn; // WORKORDER.TARGSTARTDATE
  DateTime? _scheduledOn; // WORKORDER.SCHEDSTART

  bool _loadingList = false;
  bool _generating = false;
  String _status = 'Ready';

  /// Bundled Roboto TTFs for the PDF (loaded once, cached). Null = the
  /// renderer falls back to built-in Helvetica.
  WoPrintFonts? _fonts;
  bool _fontsFailed = false;

  Future<WoPrintFonts?> _loadFonts() async {
    if (_fonts != null || _fontsFailed) return _fonts;
    try {
      Future<pw.Font> load(String asset) async =>
          pw.Font.ttf(await rootBundle.load(asset));
      _fonts = WoPrintFonts(
        base: await load('fonts/Roboto-Regular.ttf'),
        bold: await load('fonts/Roboto-Bold.ttf'),
        italic: await load('fonts/Roboto-Italic.ttf'),
        boldItalic: await load('fonts/Roboto-BoldItalic.ttf'),
      );
    } catch (e) {
      _fontsFailed = true; // Helvetica fallback (cp1252)
    }
    return _fonts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pasteController.dispose();
    super.dispose();
  }

  MaximoServerNotifier get _maximo =>
      Provider.of<MaximoServerNotifier>(context, listen: false);

  SelectedSiteNotifier get _siteNotifier =>
      Provider.of<SelectedSiteNotifier>(context, listen: false);

  String get _env => _maximo.maximoServerSelected;

  String get _site => _siteNotifier.selectedSite;

  /// The site must be a real site (not 'All') — packets are per site.
  bool get _siteValid => _site.isNotEmpty && _site != 'All';

  List<WoListRow> get _filteredRows {
    final q = _searchController.text.trim().toLowerCase();
    Iterable<WoListRow> result = _rows;
    if (q.isNotEmpty) {
      result = result.where((r) =>
          r.wonum.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q));
    }
    if (_releasedOn != null) {
      result = result.where((r) => _sameDate(r.statusDate, _releasedOn!));
    }
    if (_targetOn != null) {
      result = result.where((r) => _sameDate(r.targetStart, _targetOn!));
    }
    if (_scheduledOn != null) {
      result = result.where((r) => _sameDate(r.schedStart, _scheduledOn!));
    }
    return result.toList();
  }

  /// True when [iso] falls on the same calendar day as [picked].
  bool _sameDate(String iso, DateTime picked) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return false;
    return dt.year == picked.year && dt.month == picked.month && dt.day == picked.day;
  }

  // ---- list loading ---------------------------------------------------------

  Future<void> _loadReleased() async {
    if (!_siteValid) {
      setState(
          () => _status = 'Select a site on the home page first (not "All").');
      return;
    }
    setState(() {
      _loadingList = true;
      _status = 'Loading released work orders for site $_site...';
      _rows = <WoListRow>[];
      _selected.clear();
    });
    try {
      final raw = await WoPrintFetcher(env: _env, site: _site)
          .fetchReleasedWorkOrderRows(onStatus: (s) {
        if (mounted) setState(() => _status = s);
      });
      raw.sort((a, b) => '${a['wonum']}'.compareTo('${b['wonum']}'));
      final loaded = raw.map(WoListRow.new).toList();
      final printable = loaded.where((r) => r.printable).length;
      setState(() {
        _rows = loaded;
        _status =
            'Loaded ${loaded.length} parent WO(s) from ${raw.length} fetched '
            'rows for site $_site ($printable released and printable).';
      });
    } on WoPrintFetchException catch (e) {
      setState(() => _status = 'Failed: $e');
    } catch (e) {
      setState(() => _status = 'Failed to load released work orders: $e');
    } finally {
      if (mounted) setState(() => _loadingList = false);
    }
  }

  Future<void> _checkPastedList() async {
    if (!_siteValid) {
      setState(
          () => _status = 'Select a site on the home page first (not "All").');
      return;
    }
    final wonums = _pasteController.text
        .toUpperCase()
        .split(RegExp(r'[\s,;]+'))
        .where((w) => w.isNotEmpty)
        .toSet()
        .toList();
    if (wonums.isEmpty) {
      setState(() => _status = 'Paste at least one work order number.');
      return;
    }
    setState(() {
      _loadingList = true;
      _status = 'Checking ${wonums.length} work order(s)...';
      _rows = <WoListRow>[];
      _selected.clear();
    });
    try {
      final found = await WoPrintFetcher(env: _env, site: _site)
          .fetchWorkOrderRowsForWonums(wonums);
      final byWonum = {for (final r in found) '${r['wonum']}': r};
      // show every requested wonum, so misses are visible
      final display = <Map<String, dynamic>>[
        for (final w in wonums)
          byWonum[w] ?? {'wonum': w, 'description': '', 'status': ''},
      ];
      setState(() {
        _rows = display.map(WoListRow.new).toList();
        final printable = _rows.where((r) => r.printable).length;
        _status =
            'Checked ${wonums.length} work order(s) - '
            '$printable released and printable.';
      });
    } on WoPrintFetchException catch (e) {
      setState(() => _status = 'Failed: $e');
    } catch (e) {
      setState(() => _status = 'Failed to check pasted list: $e');
    } finally {
      if (mounted) setState(() => _loadingList = false);
    }
  }

  // ---- selection ------------------------------------------------------------

  void _toggle(WoListRow row, bool? value) {
    setState(() {
      if (value ?? false) {
        _selected.add(row.wonum);
      } else {
        _selected.remove(row.wonum);
      }
    });
  }

  void _selectShownPrintable() {
    setState(() {
      for (final r in _filteredRows) {
        if (r.printable) _selected.add(r.wonum);
      }
    });
  }

  void _selectNone() => setState(_selected.clear);

  // ---- generation -----------------------------------------------------------

  /// Fetches packets for the current selection (shared by print and save).
  /// Returns null (and updates [_status]) on any problem.
  Future<List<WoPacket>?> _generatePackets() async {
    if (!_siteValid) {
      setState(
          () => _status = 'Select a site on the home page first (not "All").');
      return null;
    }
    final wonums = _selected.toList();
    if (wonums.isEmpty) {
      setState(() => _status = 'Select at least one released work order.');
      return null;
    }
    setState(() {
      _generating = true;
      _status = 'Fetching work order data (${wonums.length} parent(s))...';
    });
    try {
      final batch = await WoPrintFetcher(env: _env, site: _site)
          .fetchPackets(wonums, onStatus: (s) {
        if (mounted) setState(() => _status = s);
      });
      if (!mounted) return null;
      setState(() {
        _generating = false;
        if (batch.packets.isEmpty) {
          _status = 'No printable work orders found.';
        }
        final notes = <String>[
          if (batch.notFound.isNotEmpty)
            '${batch.notFound.length} not found: '
                '${batch.notFound.take(5).join(', ')}'
                '${batch.notFound.length > 5 ? '...' : ''}',
          if (batch.skippedChildren.isNotEmpty)
            '${batch.skippedChildren.length} skipped (child WOs, not parents): '
                '${batch.skippedChildren.take(5).join(', ')}',
        ];
        if (notes.isNotEmpty && batch.packets.isNotEmpty) {
          _status = 'Note: ${notes.join('; ')}';
        }
      });
      return batch.packets.isEmpty ? null : batch.packets;
    } on WoPrintFetchException catch (e) {
      setState(() {
        _generating = false;
        _status = 'Fetch failed: $e';
      });
      return null;
    } catch (e) {
      setState(() {
        _generating = false;
        _status = 'Failed to build print pack: $e';
      });
      return null;
    }
  }

  /// Prints the merged pack of all selected work orders.
  Future<void> _printSelected() async {
    final packets = await _generatePackets();
    if (packets == null || !mounted) return;
    setState(() => _status = 'Rendering print pack PDF...');
    try {
      final fonts = await _loadFonts();
      final bytes = await buildWoBatchPdf(packets, fonts: fonts);
      await Printing.layoutPdf(onLayout: (format) async => bytes);
      if (mounted) {
        setState(
            () => _status = 'Print dialog closed - '
                '${packets.length} work order packet(s) in the pack.');
      }
    } catch (e) {
      if (mounted) setState(() => _status = 'Print failed: $e');
    }
  }

  /// Saves the merged pack + one PDF per work order into a chosen folder,
  /// then opens the folder in File Explorer.
  Future<void> _savePdfs() async {
    final packets = await _generatePackets();
    if (packets == null || !mounted) return;
    setState(() => _status = 'Rendering print pack PDF...');
    try {
      final fonts = await _loadFonts();
      final merged = await buildWoBatchPdf(packets, fonts: fonts);
      final dir = await FilePicker.getDirectoryPath(
          dialogTitle: 'Choose a folder for the PDF files');
      if (dir == null || !mounted) {
        setState(() => _status = 'Save cancelled');
        return;
      }
      setState(() => _status = 'Writing PDF files...');
      final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      await File('$dir\\WO_Print_Pack_$ts.pdf').writeAsBytes(merged);
      var written = 1;
      for (final packet in packets) {
        final wonum = '${packet.header['wonum']}';
        final bytes = await buildWoPacketPdf(packet, fonts: fonts);
        await File('$dir\\$wonum.pdf').writeAsBytes(bytes);
        written++;
      }
      final opened = await _openWithDefaultHandler(dir);
      if (mounted) {
        setState(() => _status = 'Wrote $written PDF file(s) to $dir'
            '${opened ? ' - folder opened' : ' (could not open the folder)'}');
      }
    } catch (e) {
      setState(() => _status = 'Save failed: $e');
    }
  }

  /// Opens [path] with the Windows default handler: a folder opens in
  /// File Explorer, a file opens in its associated application (e.g. the
  /// PDF viewer). Returns false if the launch failed — Explorer returns
  /// a non-zero exit code even on success, so the code is not checked.
  Future<bool> _openWithDefaultHandler(String path) async {
    try {
      await Process.run('explorer.exe', [path]);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Saves the merged pack of all selected work orders as a single PDF
  /// file picked in a Save As dialog, then opens the PDF in its default
  /// viewer.
  Future<void> _saveSinglePdf() async {
    final packets = await _generatePackets();
    if (packets == null || !mounted) return;
    setState(() => _status = 'Rendering print pack PDF...');
    try {
      final fonts = await _loadFonts();
      final bytes = await buildWoBatchPdf(packets, fonts: fonts);
      final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final path = await FilePicker.saveFile(
        dialogTitle: 'Save all selected work orders as one PDF',
        lockParentWindow: true,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        fileName: 'WO_Print_Pack_$ts.pdf',
      );
      if (path == null || !mounted) {
        setState(() => _status = 'Save cancelled');
        return;
      }
      setState(() => _status = 'Writing PDF file...');
      final file = path.toLowerCase().endsWith('.pdf') ? path : '$path.pdf';
      await File(file).writeAsBytes(bytes);
      final opened = await _openWithDefaultHandler(file);
      if (mounted) {
        setState(() => _status = 'Wrote 1 PDF file: $file'
            '${opened ? ' - opened' : ' (could not open it)'}');
      }
    } catch (e) {
      setState(() => _status = 'Save failed: $e');
    }
  }

  // ---- UI -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(
        //navigation drawer
        child: NavDrawer(),
      ),
      endDrawer: const EndDrawer(),
      appBar: AppBar(
        title: const Text('Work Order Print'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildSelectionPanel(),
            const SizedBox(height: 8),
            _buildDateFilters(),
            _buildStatsRow(),
            const Divider(height: 1),
            Expanded(child: _buildRowsArea()),
            if (_loadingList)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _buildActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final siteLabel = _site.isEmpty
        ? 'no site selected'
        : siteIDAndDescription[_site] == null
            ? _site
            : '$_site - ${siteIDAndDescription[_site]}';
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
                value: false, icon: Icon(Icons.filter_alt), label: Text('Filter')),
            ButtonSegment(
                value: true, icon: Icon(Icons.paste), label: Text('Pasted list')),
          ],
          selected: {_pasteMode},
          onSelectionChanged: (s) => setState(() => _pasteMode = s.first),
        ),
        Chip(
          avatar: const Icon(Icons.dns, size: 16),
          label: Text(_env),
          visualDensity: VisualDensity.compact,
        ),
        Chip(
          avatar: const Icon(Icons.place, size: 16),
          label: Text(siteLabel),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildSelectionPanel() {
    if (_pasteMode) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _pasteController,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                labelText: 'Work order numbers (comma, space or newline separated)',
                hintText: 'W24J12811, W24J12812',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: FilledButton.icon(
              onPressed: _loadingList ? null : _checkPastedList,
              icon: const Icon(Icons.check),
              label: const Text('Check list'),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              prefixIcon: Icon(Icons.search),
              labelText: 'Search loaded list (wonum or description)',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: _loadingList ? null : _loadReleased,
          icon: const Icon(Icons.refresh),
          label: const Text('Load released WOs'),
        ),
      ],
    );
  }

  /// One optional date filter chip: pick a date in the selector, WOs whose
  /// field falls on that calendar day stay in the list. Delete icon clears.
  Widget _dateFilterChip(
      String label, DateTime? value, void Function(DateTime?) onPicked) {
    return FilterChip(
      label: Text(value == null
          ? '$label: any'
          : '$label: ${DateFormat('MMM d, y').format(value)}'),
      selected: value != null,
      onSelected: (_) async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onPicked(picked);
      },
      onDeleted: value == null ? null : () => onPicked(null),
      deleteIcon: const Icon(Icons.close, size: 16),
    );
  }

  Widget _buildDateFilters() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          _dateFilterChip('Released on', _releasedOn,
              (d) => setState(() => _releasedOn = d)),
          _dateFilterChip('Target start', _targetOn,
              (d) => setState(() => _targetOn = d)),
          _dateFilterChip('Scheduled', _scheduledOn,
              (d) => setState(() => _scheduledOn = d)),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '${_filteredRows.length} of ${_rows.length} shown - '
            '${_selected.length} selected',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          TextButton(
            onPressed: _filteredRows.isEmpty ? null : _selectShownPrintable,
            child: const Text('Select all'),
          ),
          TextButton(
            onPressed: _selected.isEmpty ? null : _selectNone,
            child: const Text('Select none'),
          ),
        ],
      ),
    );
  }

  Widget _buildRowsArea() {
    if (_rows.isEmpty) {
      return Center(
        child: Text(
          _loadingList
              ? 'Loading...'
              : _pasteMode
                  ? 'Paste work order numbers above, then press "Check list".'
                  : 'Press "Load released WOs" to list the released work '
                      'orders for the selected site.',
          textAlign: TextAlign.center,
        ),
      );
    }
    final filtered = _filteredRows;
    return ListView.builder(
      itemCount: filtered.length + 1,
      itemBuilder: (context, i) => i == 0
          ? _rowHeader()
          : _rowTile(filtered[i - 1]),
    );
  }

  Widget _rowHeader() {
    final headerStyle = Theme.of(context)
        .textTheme
        .labelMedium
        ?.copyWith(fontWeight: FontWeight.bold);
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 40),
          SizedBox(width: 110, child: Text('WONUM', style: headerStyle)),
          Expanded(
              flex: 4,
              child: Text('DESCRIPTION', style: headerStyle)),
          Expanded(
              flex: 1,
              child: Text('ASSET', style: headerStyle)),
          SizedBox(
              width: 70, child: Text('TARGET', style: headerStyle)),
          SizedBox(width: 130, child: Text('STATUS', style: headerStyle)),
        ],
      ),
    );
  }

  Widget _rowTile(WoListRow row) {
    final printable = row.printable;
    final selected = _selected.contains(row.wonum);
    final muted = Theme.of(context).textTheme.bodySmall;
    return InkWell(
      onTap: printable ? () => _toggle(row, !selected) : null,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.35)
              : null,
          border: Border(
              bottom:
                  BorderSide(color: Theme.of(context).dividerColor, width: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Checkbox(
                value: selected,
                onChanged: printable ? (v) => _toggle(row, v) : null,
              ),
            ),
            SizedBox(
              width: 110,
              child: Text(row.wonum,
                  style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 12)),
            ),
            Expanded(
              flex: 4,
              child: Text(
                row.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: printable ? null : muted?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                row.assetnum,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
                width: 70,
                child: Text(row.target, style: muted)),
            SizedBox(
              width: 130,
              child: Text(
                row.statusLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: muted?.copyWith(
                    color: printable
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          FilledButton.icon(
            onPressed: _generating ? null : _printSelected,
            icon: const Icon(Icons.print),
            label: const Text('Print selected'),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: _generating ? null : _savePdfs,
            icon: const Icon(Icons.save),
            label: const Text('Save PDFs...'),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: _generating ? null : _saveSinglePdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Save PDF...'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _generating
                ? Row(
                    children: [
                      const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_status)),
                    ],
                  )
                : Text(
                    _status,
                    style: _status.startsWith('Failed') || _status.startsWith('Fetch')
                        ? TextStyle(
                            color: Theme.of(context).colorScheme.error)
                        : null,
                  ),
          ),
        ],
      ),
    );
  }
}
