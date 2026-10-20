import 'dart:ui' show ImageFilter;

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iko_reliability_flutter/admin/extract_maximo.dart';
import 'package:iko_reliability_flutter/admin/extract_notifier.dart';
import 'package:iko_reliability_flutter/admin/template_notifier.dart';
import 'package:iko_reliability_flutter/bin/consts.dart';
import 'package:iko_reliability_flutter/bin/process_state_notifier.dart';
import 'package:iko_reliability_flutter/notifiers/maximo_server_notifier.dart';
import 'package:iko_reliability_flutter/settings/settings_notifier.dart';
import 'package:provider/provider.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import '../bin/drawer.dart';
import '../bin/end_drawer.dart';
import '../main.dart';

/// Intent to move to the previous PM in the PM extract list.
class PreviousExtractIntent extends Intent {
  const PreviousExtractIntent();
}

/// Intent to move to the next PM in the PM extract list.
class NextExtractIntent extends Intent {
  const NextExtractIntent();
}

/// PM Extract page: enter a list of PM numbers + site IDs and extract the
/// existing PMs (with job plans and routes) from Maximo.
@RoutePage()
class PmExtractPage extends StatefulWidget {
  /// Constructs the PM Extract page.
  const PmExtractPage({super.key});

  @override
  State<PmExtractPage> createState() => _PmExtractPageState();
}

/// State for the PM Extract page, manages input parsing, fetching and export.
class _PmExtractPageState extends State<PmExtractPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _listController = ScrollController();
  String fallbackSite = '';
  bool dropHover = false;
  List<Widget> fabList = [];

  @override
  void initState() {
    super.initState();
    _updateFab();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _listController.dispose();
    super.dispose();
  }

  // Moves the selection to the previous PM and keeps the row visible.
  void _selectPrevious() {
    final notifier = context.read<ExtractNotifier>();
    final before = _selectedRowTop();
    notifier.selectPrevious();
    if (_selectedRowTop() != before) {
      _ensureSelectedVisible();
    }
  }

  // Moves the selection to the next PM and keeps the row visible.
  void _selectNext() {
    final notifier = context.read<ExtractNotifier>();
    final before = _selectedRowTop();
    notifier.selectNext();
    if (_selectedRowTop() != before) {
      _ensureSelectedVisible();
    }
  }

  /// Pixel offset of the top of the selected row in the extract list. Rows
  /// are a fixed height of 105 px (100 px item + 5 px divider), with a
  /// 100 px spinner row at the top while fetching.
  double? _selectedRowTop() {
    final notifier = context.read<ExtractNotifier>();
    final index = notifier.extracts
        .indexWhere((element) => element.key == notifier.selectedKey);
    if (index < 0) {
      return null;
    }
    return (notifier.fetching ? 100.0 : 0.0) + index * 105.0;
  }

  // Scrolls the extract list so the selected row is in view (used when
  // navigating with the arrow keys).
  void _ensureSelectedVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_listController.hasClients) {
        return;
      }
      final top = _selectedRowTop();
      if (top == null) {
        return;
      }
      const rowHeight = 105.0;
      final position = _listController.position;
      final offset = _listController.offset;
      if (top >= offset && top + rowHeight <= offset + position.viewportDimension) {
        return; // row is already fully visible
      }
      final target = (top + rowHeight / 2 - position.viewportDimension / 2)
          .clamp(0.0, position.maxScrollExtent);
      _listController.animateTo(
        target,
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
      );
    });
  }

  void _updateFab() {
    List<Widget> temp = [];
    if (fabList.length == 1) {
      temp = [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: FloatingActionButton.extended(
            heroTag: UniqueKey(),
            onPressed: () async {
              await _fetchExtracts();
              _updateFab();
            },
            label: const Text('Fetch'),
            tooltip: 'Extract the listed PMs from Maximo',
            icon: const Icon(Icons.cloud_download),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: FloatingActionButton.extended(
            heroTag: UniqueKey(),
            onPressed: () async {
              await _exportToExcel();
              _updateFab();
            },
            label: const Text('Export'),
            tooltip: 'Export extracted PMs to Excel',
            icon: const Icon(Icons.table_view),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: FloatingActionButton.extended(
            heroTag: UniqueKey(),
            onPressed: () async {
              await _exportToImportTemplate();
              _updateFab();
            },
            label: const Text('Import'),
            tooltip: 'Export extracted PMs in the PM import template format',
            icon: const Icon(Icons.upload_outlined),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: FloatingActionButton.extended(
            heroTag: UniqueKey(),
            onPressed: () async {
              await _loadSelectedToTemplates();
              _updateFab();
            },
            label: const Text('Load'),
            tooltip: 'Load selected PM into the PM Check template editor',
            icon: const Icon(Icons.input_rounded),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: FloatingActionButton.extended(
            heroTag: UniqueKey(),
            onPressed: () {
              _inputController.clear();
              context.read<ExtractNotifier>().clear();
              _updateFab();
            },
            tooltip: 'Clear input and extracted PMs',
            label: const Text('Clear'),
            icon: const Icon(Icons.delete_sweep),
          ),
        ),
        FloatingActionButton(
          heroTag: UniqueKey(),
          onPressed: () {
            _updateFab();
          },
          child: const Icon(Icons.close),
        ),
      ];
    } else {
      temp = [
        FloatingActionButton(
          heroTag: UniqueKey(),
          onPressed: () {
            _updateFab();
          },
          child: const Icon(Icons.add),
        )
      ];
    }

    setState(() {
      fabList = temp;
    });
  }

  // Parses the input field into PM + site pairs and fetches them from Maximo.
  Future<void> _fetchExtracts() async {
    final extractNotifier = context.read<ExtractNotifier>();
    if (extractNotifier.fetching) {
      _show('Please wait, extraction already in progress');
      return;
    }
    final fallback = fallbackSite.isEmpty ? null : fallbackSite;
    final parsed = parsePmInputLines(_inputController.text, fallback);
    if (parsed.valid.isEmpty && parsed.invalid.isEmpty) {
      _show('Enter PM numbers first, one per line (e.g. "AA A0001D1INRE")');
      return;
    }
    String msg = 'Extracting ${parsed.valid.length} PMs';
    if (parsed.invalid.isNotEmpty) {
      msg =
          '$msg, ${parsed.invalid.length} invalid lines skipped:\n${parsed.invalid.take(5).join('\n')}';
    }
    _show(msg);
    if (parsed.valid.isEmpty) {
      return;
    }
    final maximo = context.read<MaximoServerNotifier>();
    extractNotifier.addPairs(parsed.valid);
    final processNotifier = context.read<ProcessStateNotifier>();
    try {
      processNotifier.addTask('extractPMState');
      await fetchExtracts(parsed.valid, maximo.maximoServerSelected,
          extractNotifier);
      final summary = _summarize(extractNotifier);
      _show(summary);
    } catch (e) {
      _show('Extraction failed: $e');
    } finally {
      processNotifier.removeTask('extractPMState');
    }
  }

  String _summarize(ExtractNotifier notifier) {
    int extracted = 0;
    int notFound = 0;
    int errors = 0;
    for (final store in notifier.extracts) {
      if (store.status == 'extracted') {
        extracted++;
      } else if (store.status == 'not found') {
        notFound++;
      } else if (store.status == 'error') {
        errors++;
      }
    }
    return 'Extracted: $extracted, Not Found: $notFound, Errors: $errors';
  }

  // Writes all extracted PMs to an Excel workbook.
  Future<void> _exportToExcel() async {
    final notifier = context.read<ExtractNotifier>();
    final result = await exportExtractsToExcel(notifier.extracts);
    _show(result);
  }

  // Writer for all extracted PMs in the PM import template format.
  Future<void> _exportToImportTemplate() async {
    final notifier = context.read<ExtractNotifier>();
    final result = await exportExtractsToImportTemplate(notifier.extracts);
    _show(result);
  }

  // Best effort population of the PM Check template editor from the
  // currently selected extracted PM.
  Future<void> _loadSelectedToTemplates() async {
    final notifier = context.read<ExtractNotifier>();
    final store = notifier.getSelected();
    if (store == null || store.pm.isEmpty) {
      _show('Select an extracted PM first');
      return;
    }
    final templateNotifier = context.read<TemplateNotifier>();
    final maximo = context.read<MaximoServerNotifier>();
    final includeFrequency = context
        .read<SettingsNotifier>()
        .getSetting(ApplicationSetting.includeFrequencyInDescriptions) as bool?;
    await populateTemplateFromExtract(
      store,
      templateNotifier,
      maximo.maximoServerSelected,
      includeFrequency ?? true,
    );
    _show('Loaded ${store.key} into the PM Check page template editor');
  }

  // Opens a file picker to load a text / csv file with PM + site lines.
  Future<void> _pickInputFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: false, withData: true, type: FileType.custom,
        allowedExtensions: ['txt', 'csv']);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final content = String.fromCharCodes(file.bytes ?? []);
      setState(() {
        _inputController.text = content;
      });
      _show('Loaded ${file.name} into the input');
    }
  }

  void _show(String toastMsg) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(
      content: Text(toastMsg),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowUp): PreviousExtractIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown): NextExtractIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          PreviousExtractIntent: CallbackAction<PreviousExtractIntent>(
            onInvoke: (PreviousExtractIntent intent) => {_selectPrevious()},
          ),
          NextExtractIntent: CallbackAction<NextExtractIntent>(
            onInvoke: (NextExtractIntent intent) => {_selectNext()},
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            drawer: const Drawer(
              child: NavDrawer(),
            ),
            appBar: AppBar(
              title: const Text("PM Extract"),
              actions: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    tooltip:
                        MaterialLocalizations.of(context).openAppDrawerTooltip,
                  ),
                ),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fabList,
            ),
            body: Column(
              children: <Widget>[
                // input section
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        tooltip: 'Load PM list from a text or csv file',
                        onPressed: _pickInputFile,
                        icon: const Icon(Icons.file_open_rounded),
                      ),
                      const VerticalDivider(
                        width: 10,
                        thickness: 1,
                        indent: 5,
                        endIndent: 5,
                      ),
                      Expanded(
                        child: DropRegion(
                          formats: Formats.standardFormats,
                          hitTestBehavior: HitTestBehavior.opaque,
                          onDropOver: (event) {
                            setState(() {
                              dropHover = true;
                            });
                            return event.session.allowedOperations
                                    .contains(DropOperation.copy)
                                ? DropOperation.copy
                                : DropOperation.none;
                          },
                          onDropLeave: (event) {
                            setState(() {
                              dropHover = false;
                            });
                          },
                          onPerformDrop: (event) async {
                            setState(() {
                              dropHover = false;
                            });
                            for (final item in event.session.items) {
                              final reader = item.dataReader;
                              if (reader != null) {
                                reader.getFile(null, (file) async {
                                  final content =
                                      String.fromCharCodes(await file.readAll());
                                  setState(() {
                                    _inputController.text = content;
                                  });
                                  _show(
                                      'Loaded ${file.fileName} into the input');
                                });
                              }
                            }
                          },
                          child: Stack(
                            children: [
                              TextField(
                                controller: _inputController,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  hintText:
                                      'One PM per line: "AA A0001D1INRE" or "A0001D1INRE" (site below)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              if (dropHover)
                                Positioned.fill(
                                  child: BackdropFilter(
                                    filter:
                                        ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                    child: Container(
                                      alignment: Alignment.center,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface
                                          .withValues(alpha: 0.2),
                                      child: Text(
                                        'Drop PM list file here',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const VerticalDivider(
                        width: 10,
                        thickness: 1,
                        indent: 5,
                        endIndent: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Site for lines without a site'),
                          DropdownButton<String>(
                            value:
                                fallbackSite.isEmpty ? null : fallbackSite,
                            hint: const Text('Select site'),
                            items: [
                              for (final entry
                                  in siteIDAndDescription.entries)
                                if (entry.key != 'All')
                                  DropdownMenuItem(
                                    value: entry.key,
                                    child: Text(
                                        '${entry.key} - ${entry.value}'),
                                  ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                fallbackSite = value ?? '';
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 10,
                  thickness: 1,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        width: 550,
                        child: Consumer<ExtractNotifier>(
                          builder: (context, notifier, child) {
                            return ListView(
                              controller: _listController,
                              children: buildExtractList(notifier, context),
                            );
                          },
                        ),
                      ),
                      VerticalDivider(
                        width: 20,
                        thickness: 1,
                        indent: 5,
                        endIndent: 5,
                        color: Theme.of(context).dividerColor,
                      ),
                      const Expanded(child: ExtractDetailView()),
                      VerticalDivider(
                        width: 8,
                        thickness: 1,
                        indent: 5,
                        endIndent: 5,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            endDrawer: const EndDrawer(),
          ),
        ),
      ),
    );
  }
}

/// Builds the left pane list of extracted PM pairs.
List<Widget> buildExtractList(
    ExtractNotifier notifier, BuildContext context) {
  List<Widget> list = [];
  if (notifier.fetching) {
    list.add(const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 100,
            width: 100,
            child: CircularProgressIndicator.adaptive(),
          )
        ]));
  }
  for (final store in notifier.extracts) {
    list.add(extractListItem(store, notifier, context));
    list.add(Divider(
      height: 5,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: Theme.of(context).dividerColor,
    ));
  }
  if (notifier.extracts.isEmpty && !notifier.fetching) {
    list.addAll(instructionListItem(
        'Enter PM numbers + site IDs above, then click Fetch',
        context,
        Icons.cloud_download));
    list.addAll(instructionListItem(
        'Lines can be "AA A0001D1INRE" or "A0001D1INRE" with the site selected on the right',
        context,
        Icons.format_list_bulleted));
    list.addAll(instructionListItem(
        'Export extracted PMs to Excel', context, Icons.table_view));
  }
  return list;
}

/// One PM pair row in the extract list.
Widget extractListItem(
    ExtractStore store, ExtractNotifier notifier, BuildContext context) {
  Color vertCol = Colors.grey;
  var boxDecoration = BoxDecoration(
      border: Border.all(),
      borderRadius: const BorderRadius.all(Radius.circular(20)));
  if (notifier.selectedKey == store.key) {
    Color containerCol = Theme.of(context).colorScheme.secondaryContainer;
    vertCol = Colors.redAccent;
    boxDecoration = BoxDecoration(
        color: containerCol,
        border: Border.all(color: containerCol),
        borderRadius: const BorderRadius.all(Radius.circular(20)));
  }
  return SizedBox(
    height: 100,
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        notifier.setSelected(store.key);
      },
      child: Container(
        decoration: boxDecoration,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 120, child: extractStatusIndicator(store, context)),
            VerticalDivider(
              width: 20,
              thickness: 1,
              indent: 10,
              endIndent: 10,
              color: vertCol,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    store.pmnum,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    store.description ?? 'Not extracted yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 2.0)),
                  Text(
                    'Site: ${store.siteid}',
                    style: TextStyle(
                        fontSize: 12.0,
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Status icon + text for an extracted PM pair. Styled like the status
/// indicator used on the PM Check page (pm_widgets.statusIndicator).
Widget extractStatusIndicator(ExtractStore store, BuildContext context) {
  Widget icon;
  String text;
  Color textColor = Theme.of(context).colorScheme.onSurface;
  switch (store.status) {
    case 'fetching':
    case 'extracting':
      icon = const SizedBox(
        height: 35,
        width: 35,
        child: CircularProgressIndicator.adaptive(),
      );
      text = 'Fetching';
      textColor = const Color.fromRGBO(33, 150, 243, 1);
      break;
    case 'extracted':
      text = 'Extracted';
      textColor = const Color.fromRGBO(76, 175, 80, 1);
      icon = Icon(Icons.check_circle, color: textColor, size: 35);
      break;
    case 'not found':
      text = 'Not Found';
      textColor = const Color.fromRGBO(255, 235, 59, 1);
      icon = Icon(Icons.search_off_rounded, color: textColor, size: 35);
      break;
    case 'error':
      text = 'Error';
      textColor = const Color.fromRGBO(244, 67, 54, 1);
      icon = Icon(Icons.report_rounded, color: textColor, size: 35);
      break;
    default:
      text = 'Queued';
      icon = Icon(Icons.schedule, color: textColor, size: 35);
  }
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      icon,
      Text(
        text,
        style: TextStyle(fontSize: 20.0, color: textColor),
      )
    ],
  );
}

/// Simple instruction row shown when the list is empty.
List<Widget> instructionListItem(
    String instruction, BuildContext context, IconData? icon) {
  return [
    SizedBox(
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 70,
                      child: Icon(
                        icon,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 35,
                      ),
                    ),
                    VerticalDivider(
                      width: 20,
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                      color: Colors.redAccent,
                    ),
                    Expanded(
                      child: Text(
                        instruction,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    ),
    Divider(
      height: 5,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: Theme.of(context).dividerColor,
    )
  ];
}

/// Right pane showing the full detail of the selected extracted PM with
/// tabs for PM header, job plan and route.
class ExtractDetailView extends StatefulWidget {
  const ExtractDetailView({super.key});

  @override
  State<ExtractDetailView> createState() => _ExtractDetailViewState();
}

class _ExtractDetailViewState extends State<ExtractDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExtractNotifier>(builder: (context, notifier, child) {
      final store = notifier.getSelected();
      if (store == null) {
        return const Text('Select a PM to see extracted details');
      }
      if (store.status == 'not found') {
        return Text(
            '${store.pmnum} at site ${store.siteid} was not found in Maximo');
      }
      if (store.status == 'error') {
        return Text(
            'Failed to extract ${store.pmnum} at site ${store.siteid}: ${store.errorMessage}');
      }
      return Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.tune)),
              Tab(icon: Icon(Icons.fact_check)),
              Tab(icon: Icon(Icons.route_rounded)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _pmHeaderTab(store),
                _jobPlanTab(store),
                _routeTab(store),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _fieldRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }

  Widget _pmHeaderTab(ExtractStore store) {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        for (final header in tableHeaders['PM']!)
          _fieldRow(
              header, stripHtml(fieldOf(store.pm, header.toLowerCase())), context),
      ],
    );
  }

  Widget _jobPlanTab(ExtractStore store) {
    if (store.jobplan == null) {
      return const Text('No job plan referenced by this PM');
    }
    final jp = store.jobplan!;
    List<Widget> rows = [];
    rows.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        fieldOf(jp, 'jpnum') ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    ));
    for (final header in [
      'DESCRIPTION',
      'STATUS',
      'PERSONGROUP',
      'IKO_CONDITIONS',
      'PRIORITY',
      'IKO_WORKTYPE',
      'TEMPLATETYPE',
      'JPDURATION',
      'PLUSCREVNUM',
      'ORGID',
      'SITEID',
    ]) {
      rows.add(_fieldRow(header, fieldOf(jp, header.toLowerCase()) ?? '', context));
    }
    rows.add(_childTableCard(
        'Tasks (${store.jobtasks.length})',
        ['JPTASK', 'METERNAME', 'ASSETNUM', 'DESCRIPTION'],
        store.jobtasks));
    rows.add(_childTableCard(
        'Labor (${store.joblabors.length})',
        ['CRAFT', 'QUANTITY', 'LABORHRS', 'LABORCODE'],
        store.joblabors));
    rows.add(_childTableCard(
        'Materials (${store.jobmaterials.length})',
        ['ITEMNUM', 'ITEMQTY', 'COST'],
        store.jobmaterials));
    rows.add(_childTableCard(
        'Services (${store.jobservices.length})',
        ['ITEMNUM', 'ITEMQTY', 'COMPANY', 'COST'],
        store.jobservices));
    return ListView(
      padding: const EdgeInsets.all(10),
      children: rows,
    );
  }

  Widget _routeTab(ExtractStore store) {
    if (store.route == null) {
      return const Text('No route referenced by this PM');
    }
    final route = store.route!;
    List<Widget> rows = [];
    rows.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        fieldOf(route, 'route') ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    ));
    for (final header in [
      'DESCRIPTION',
      'ROUTESTOPSBECOME',
      'SITEID',
      'ORGID',
    ]) {
      rows.add(
          _fieldRow(header, fieldOf(route, header.toLowerCase()) ?? '', context));
    }
    // one card per stop; stops with an extracted job plan show its details
    rows.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('Stops (${store.routeStops.length})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    ));
    for (final stop in store.routeStops) {
      rows.add(_stopCard(store, stop));
    }
    return ListView(
      padding: const EdgeInsets.all(10),
      children: rows,
    );
  }

  /// Card for a single route stop. The job plan linked to the stop (if
  /// extracted) is shown with its tasks, labour, materials and services.
  Widget _stopCard(ExtractStore store, dynamic stop) {
    final jpnum = fieldOf(stop, 'jpnum') ?? '';
    final plan = jpnum.isEmpty ? null : store.stopJobPlans[jpnum];
    final seq = fieldOf(stop, 'stopsequence') ?? '';
    final asset = fieldOf(stop, 'assetnum') ?? '';
    String title;
    if (plan != null) {
      title = 'Stop $seq: $asset - ${plan.description?.isNotEmpty == true ? plan.description : jpnum}';
    } else if (jpnum.isEmpty) {
      title = 'Stop $seq: $asset (no job plan)';
    } else {
      title = 'Stop $seq: $asset - $jpnum (job plan not extracted)';
    }
    return Card(
      child: ExpansionTile(
        title: Text(title),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (plan != null) ...[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: SelectableText(
                  'JP: ${plan.jpnum ?? jpnum} - ${plan.description ?? ''}',
                  style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 12)),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: SelectableText(jpnum.isEmpty
                  ? 'No linked job plan'
                  : 'Linked job plan $jpnum was not extracted',
                  style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurface)),
            ),
          ],
          if (plan != null && plan.jobtasks.isNotEmpty)
            _childTableCard('Job Plan Tasks',
                ['JPTASK', 'DESCRIPTION', 'METERNAME'], plan.jobtasks),
          if (plan != null && plan.joblabors.isNotEmpty)
            _childTableCard('Job Plan Labour',
                ['CRAFT', 'QUANTITY', 'LABORHRS'], plan.joblabors),
          if (plan != null && plan.jobmaterials.isNotEmpty)
            _childTableCard('Job Plan Materials',
                ['ITEMNUM', 'ITEMQTY', 'COST'], plan.jobmaterials),
          if (plan != null && plan.jobservices.isNotEmpty)
            _childTableCard('Job Plan Services',
                ['ITEMNUM', 'COST', 'COMPANY'], plan.jobservices),
        ],
      ),
    );
  }

  /// Expandable card listing child rows (tasks / labor / materials) with a
  /// column header row, styled like the upload detail tables in pm_details.
  Widget _childTableCard(String title, List<String> headers, List<dynamic> rows) {
    final themeData = Theme.of(context);
    return Card(
      child: ExpansionTile(
        title: Text(title),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rows.isNotEmpty)
            Container(
              width: double.maxFinite,
              color: themeData.colorScheme.onSurface,
              child: Text(headers.join(','),
                  style: TextStyle(color: themeData.colorScheme.surface)),
            ),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: SelectableText(
                stripHtml(headers.map((h) => rowValue(row, h)).join(',')),
                style: TextStyle(
                    fontFamily: 'RobotoMono',
                    color: themeData.colorScheme.onSurface),
              ),
            ),
        ],
      ),
    );
  }
}
