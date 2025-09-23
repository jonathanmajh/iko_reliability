import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iko_reliability_flutter/admin/parse_template.dart';
import 'package:iko_reliability_flutter/admin/pm_name_generator.dart';
import 'package:iko_reliability_flutter/bin/consts.dart';
import 'package:iko_reliability_flutter/bin/process_state_notifier.dart';
import 'package:iko_reliability_flutter/notifiers/maximo_server_notifier.dart';
import 'package:provider/provider.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import '../bin/drawer.dart';
import '../main.dart';
import '../bin/end_drawer.dart';
import 'generate_job_plans.dart';
import 'pm_details.dart';
import 'template_notifier.dart';
import 'pm_widgets.dart';
import 'upload_maximo.dart';

/// Intent to move to the previous PM in the PM check page.
class PreviousPMIntent extends Intent {
  const PreviousPMIntent();
}

/// Intent to move to the next PM in the PM check page.
class NextPMIntent extends Intent {
  const NextPMIntent();
}

/// PM Check page for verifying and uploading PM templates.
@RoutePage()
class PmCheckPage extends StatefulWidget {
  /// Constructs the PM Check page.
  const PmCheckPage({super.key});

  @override
  State<PmCheckPage> createState() => _PmCheckPageState();
}

/// State for the PM Check page, manages template uploads and FAB actions.
class _PmCheckPageState extends State<PmCheckPage> {
  List<FileDetails> templates = [];
  String uploadDetails = '';
  List<Widget> fabList = [];

  @override
  void initState() {
    super.initState();
    _updateFab();
  }

  void _updateFab() {
    List<Widget> temp = [];
    if (fabList.length == 1) {
      // populate with 3 options
      temp = [
        Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: FloatingActionButton.extended(
              heroTag: UniqueKey(),
              onPressed: () async {
                final templateNotifier = context.read<TemplateNotifier>();
                if (!templateNotifier.loadingFiles) {
                  final uploadNotifier = context.read<UploadNotifier>();
                  final maximo = context.read<MaximoServerNotifier>();
                  for (final filename in templateNotifier.getFiles()) {
                    for (final template
                        in templateNotifier.getTemplates(filename)) {
                      var processedTemplate = templateNotifier
                          .getProcessedTemplate(filename, template);
                      await generateUploadHelper(
                        processedTemplate,
                        templateNotifier,
                        filename,
                        template,
                        uploadNotifier,
                      );
                      uploadPMToMaximo(
                        maximo.maximoServerSelected,
                        filename,
                        template,
                        templateNotifier,
                        uploadNotifier,
                      );
                    }
                  }
                } else {
                  _show(
                      'Please Wait Until Templates have been loaded before uploading');
                }
                _updateFab();
              },
              label: const Text('Upload All'),
              tooltip: 'Upload All PMs',
              icon: const Icon(Icons.cloud_upload),
            )),
        Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: FloatingActionButton.extended(
              heroTag: UniqueKey(),
              onPressed: () {
                copyTemplates(context.read<TemplateNotifier>().getAllPmnum());
                _updateFab();
              },
              label: const Text('Copy'),
              tooltip: 'Copy filenames and PM number to clipboard',
              icon: const Icon(Icons.content_copy),
            )),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: FloatingActionButton.extended(
            heroTag: UniqueKey(),
            onPressed: () async {
              var processNotifier = Provider.of<ProcessStateNotifier>(context,
                  listen: false); //for recording PM file loading process state
              try {
                processNotifier.addTask('loadPMFilesState');
                await pickTemplates();
                _updateFab();
              } finally {
                processNotifier.removeTask('loadPMFilesState');
              }
            },
            tooltip: 'Select files to load PM templates',
            label: const Text('Open'),
            icon: const Icon(Icons.file_open_rounded),
          ),
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: FloatingActionButton.extended(
              heroTag: UniqueKey(),
              onPressed: () {
                context.read<TemplateNotifier>().clearTemplates();
                numberNotifier.clear();
                _updateFab();
              },
              tooltip: 'Clear PM templates',
              label: const Text('Clear'),
              icon: const Icon(Icons.delete_sweep),
            )),
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

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowUp): PreviousPMIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown): NextPMIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          PreviousPMIntent: CallbackAction<PreviousPMIntent>(
            onInvoke: (PreviousPMIntent intent) => {
              Provider.of<TemplateNotifier>(context, listen: false)
                  .selectPreviousTemplate()
            },
          ),
          NextPMIntent: CallbackAction<NextPMIntent>(
            onInvoke: (NextPMIntent intent) => {
              Provider.of<TemplateNotifier>(context, listen: false)
                  .selectNextTemplate()
            },
          ),
        },
        child: Focus(
            autofocus: true,
            child: Scaffold(
              drawer: const Drawer(
                //navigation drawer
                child: NavDrawer(),
              ),
              appBar: AppBar(
                title: const Text("PM Verify and Upload"),
                // keep back button with a right side hamburger menu
                actions: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      tooltip: MaterialLocalizations.of(context)
                          .openAppDrawerTooltip,
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
                  Divider(
                    height: 10,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  Expanded(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                        SizedBox(
                            width: 550,
                            child: Consumer<TemplateNotifier>(
                                builder: (context, value, child) {
                              return DropRegion(
                                // Formats this region can accept.
                                formats: Formats.standardFormats,
                                hitTestBehavior: HitTestBehavior.opaque,
                                onDropOver: (event) {
                                  // You can inspect local data here, as well as formats of each item.
                                  // However on certain platforms (mobile / web) the actual data is
                                  // only available when the drop is accepted (onPerformDrop).
                                  final item = event.session.items.first;
                                  if (item.localData is Map) {
                                    // This is a drag within the app and has custom local data set.
                                  }
                                  if (item.canProvide(Formats.plainText)) {
                                    // this item contains plain text.
                                  }
                                  // This drop region only supports copy operation.
                                  if (event.session.allowedOperations
                                      .contains(DropOperation.copy)) {
                                    return DropOperation.copy;
                                  } else {
                                    return DropOperation.none;
                                  }
                                },
                                onDropEnter: (event) {
                                  // This is called when region first accepts a drag. You can use this
                                  // to display a visual indicator that the drop is allowed.
                                },
                                onDropLeave: (event) {
                                  // Called when drag leaves the region. Will also be called after
                                  // drag completion.
                                  // This is a good place to remove any visual indicators.
                                },
                                onPerformDrop: (event) async {
                                  // Called when user dropped the item. You can now request the data.
                                  // Note that data must be requested before the performDrop callback
                                  // is over.
                                  for (final item in event.session.items) {
                                    // data reader is available now
                                    final reader = item.dataReader;

                                    if (reader != null) {
                                      reader.getFile(null, (file) async {
                                        var fileDetails = FileDetails(
                                            name: file.fileName!,
                                            bytes: await file.readAll());
                                        processDroppedFiles(
                                            value, [fileDetails]);
                                      });
                                    }
                                  }
                                },
                                child: ListView(
                                  children: buildPMList(value, context),
                                ),
                              );
                            })),
                        VerticalDivider(
                          width: 20,
                          thickness: 1,
                          indent: 5,
                          endIndent: 5,
                          color: Theme.of(context).dividerColor,
                        ),
                        const Expanded(child: PMDetailView()),
                        VerticalDivider(
                          width: 8,
                          thickness: 1,
                          indent: 5,
                          endIndent: 5,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ]))
                ],
              ),
              endDrawer: const EndDrawer(),
            )),
      ),
    );
  }

// for displaying bottom status notifications
  void _show(String toastMsg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(toastMsg),
    ));
  }

  void copyTemplates(Map<String, List<String>> data) {
    String allData = '';
    for (String filename in data.keys) {
      allData = '$allData\n$filename';
      for (String pmnum in data[filename]!) {
        allData = '$allData\n - $pmnum';
      }
    }
    Clipboard.setData(ClipboardData(text: allData)).then((_) {
      return;
    });
  }

  /// Opens file picker to select PM template files.
  Future<void> pickTemplates() async {
    final template = context.read<TemplateNotifier>();
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, withData: true);
    List<PlatformFile> files = [];
    String msg = '';
    if (result != null) {
      files = result.files.map((files) => (files)).toList();
      msg = 'Selected ${files.length} files';
    } else {
      msg = 'File selector cancelled';
    }
    if (msg.isNotEmpty) {
      _show(msg);
    }
    List<FileDetails> filesDetails = [];
    for (var file in files) {
      filesDetails.add(FileDetails(
        name: file.name,
        bytes: file.bytes!,
      ));
    }
    processDroppedFiles(template, filesDetails);
  }

  /// process files selected by file picker or dropped
  Future<void> processDroppedFiles(
      TemplateNotifier templateNotifier, List<FileDetails> files) async {
    final maximo = context.read<MaximoServerNotifier>();
    setState(() {
      templates = files;
      _show('Processing ${files.length} files');
    });
    if (files.isEmpty) {
      setState(() {
        debugPrint('No files selected...');
      });
    } else {
      setState(() {
        debugPrint('Processing files...');
      });
      processAllTemplates(templateNotifier, files, maximo.maximoServerSelected);
    }
  }
}

///parsing spreadsheets for PMs
Future<List<dynamic>> parseSpreadsheets(List<FileDetails> files) async {
  List<Future> futures = [];
  for (var file in files) {
    futures.add(compute(
        ParsedTemplate(pmName: 'Error', pmNumber: 'Error', nextDueDate: '')
            .fromExcel,
        file));
  }
  return await Future.wait(futures);
}

///processes loaded PM template files
void processAllTemplates(TemplateNotifier templateNotifier,
    List<FileDetails> files, String maximoServerSelected) async {
  templateNotifier.setLoading(true);
  var parsedTmpts = await parseSpreadsheets(files);
  for (var thing in parsedTmpts) {
    for (var template in thing.keys) {
      //process each selected file
      for (var templateNumber in thing[template].keys) {
        //process each template in a file
        templateNotifier.setParsedTemplate(
            template, templateNumber, thing[template][templateNumber]);
      }
    }
  }
  for (var thing in parsedTmpts) {
    for (String ws in thing.keys) {
      for (int templateNumber in thing[ws].keys) {
        try {
          final value = await generateName(
            templateNotifier.getParsedTemplate(ws, templateNumber),
            maximoServerSelected,
          );
          templateNotifier.setNameTemplate(ws, templateNumber, value);
          final value2 = await generatePM(
            templateNotifier.getParsedTemplate(ws, templateNumber),
            templateNotifier.getPMName(ws, templateNumber),
            maximoServerSelected,
          );
          templateNotifier.setProcessedTemplate(ws, templateNumber, value2);
        } catch (e) {
          debugPrint(e.toString());
          templateNotifier.addStatusMessage(ws, templateNumber, '$e');
        }
      }
    }
  }

  templateNotifier.setLoading(false);
}
