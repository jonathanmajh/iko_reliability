import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:iko_reliability_flutter/admin/parse_template.dart';
import 'package:iko_reliability_flutter/admin/pm_name_generator.dart';
import 'package:iko_reliability_flutter/admin/process_state_notifier.dart';
import 'package:provider/provider.dart';

import 'consts.dart';
import '../main.dart';
import 'end_drawer.dart';
import 'generate_job_plans.dart';
import 'pm_details.dart';
import 'template_notifier.dart';
import 'pm_widgets.dart';
import 'upload_maximo.dart';

class PmCheckPage extends StatefulWidget {
  const PmCheckPage({Key? key}) : super(key: key);

  @override
  State<PmCheckPage> createState() => _PmCheckPageState();
}

class _PmCheckPageState extends State<PmCheckPage> {
  List<PlatformFile> templates = [];
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
                      uploadToMaximo(
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
                processNotifier.setProcessState(
                    ProcessStates.loadPMFilesState, true);
                await pickTemplates(context);
                _updateFab();
              } finally {
                processNotifier.setProcessState(
                    ProcessStates.loadPMFilesState, false);
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
                var box = Hive.box('jpNumber');
                box.clear();
                box = Hive.box('pmNumber');
                box.clear();
                box = Hive.box('routeNumber');
                box.clear();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("PM Verify and Upload"),
        // keep back button with a right side hamburger menu
        leading: (ModalRoute.of(context)?.canPop ?? false)
            ? const BackButton()
            : null,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
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
            color: Theme.of(context).colorScheme.background,
          ),
          Expanded(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                SizedBox(
                    width: 550,
                    child: Consumer<TemplateNotifier>(
                        builder: (context, value, child) {
                      return ListView(
                        children: buildPMList(value, context),
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
                  color: Theme.of(context).colorScheme.background,
                ),
              ]))
        ],
      ),
      endDrawer: const EndDrawer(),
    );
  }

// for displaying bottom status notifications
  void _show(toastMsg) {
    final msg = toastMsg;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
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

  Future<void> pickTemplates(BuildContext context) async {
    Stopwatch stopwatch = Stopwatch()..start();
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
    setState(() {
      templates = files;
      _show(msg);
    });
    debugPrint('loaded files in ${stopwatch.elapsedMilliseconds} milliseconds');
    if (files.isEmpty) {
      setState(() {
        debugPrint('No files selected files...');
      });
    } else {
      setState(() {
        debugPrint('Processing files...');
      });
      final template = context.read<TemplateNotifier>();
      final maximo = context.read<MaximoServerNotifier>();
      processAllTemplates(template, files, maximo.maximoServerSelected);
    }
  }
}

///parsing spreadsheets for PMs
Future<List<dynamic>> parseSpreadsheets(List<PlatformFile> files) async {
  List<Future> futures = [];
  for (var file in files) {
    futures.add(compute(
        ParsedTemplate(pmName: 'Error', pmNumber: 'Error').fromExcel,
        [file.bytes!, file.name]));
  }
  return await Future.wait(futures);
}

///processes loaded PM template files
void processAllTemplates(TemplateNotifier context, List<PlatformFile> files,
    String maximoServerSelected) async {
  context.setLoading(true);
  var parsedTmpts = await parseSpreadsheets(files);
  for (var thing in parsedTmpts) {
    for (var template in thing.keys) {
      //process each selected file
      for (var templateNumber in thing[template].keys) {
        //process each template in a file
        context.setParsedTemplate(
            template, templateNumber, thing[template][templateNumber]);
      }
    }
  }
  for (var thing in parsedTmpts) {
    for (String ws in thing.keys) {
      for (int templateNumber in thing[ws].keys) {
        // TODO this is no longer async :(
        try {
          final value = await generateName(
            context.getParsedTemplate(ws, templateNumber),
            maximoServerSelected,
          );
          context.setNameTemplate(ws, templateNumber, value);
          final value2 = await generatePM(
            context.getParsedTemplate(ws, templateNumber),
            context.getPMName(ws, templateNumber),
            maximoServerSelected,
          );
          context.setProcessedTemplate(ws, templateNumber, value2);
        } catch (e) {
          debugPrint(e.toString());
          context.addStatusMessage(ws, templateNumber, '$e');
        }
      }
    }
  }

  context.setLoading(false);
}
