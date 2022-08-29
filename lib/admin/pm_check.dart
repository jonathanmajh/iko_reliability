import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iko_reliability/admin/parse_template.dart';
import 'package:iko_reliability/admin/pm_name_generator.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'asset_storage.dart';
import 'generate_job_plans.dart';
import 'maximo_jp_pm.dart';
import 'observation_list_storage.dart';
import 'pm_details.dart';
import 'template_notifier.dart';
import 'pm_widgets.dart';

class PmCheckPage extends StatefulWidget {
  const PmCheckPage({Key? key}) : super(key: key);

  @override
  State<PmCheckPage> createState() => _PmCheckPageState();
}

class _PmCheckPageState extends State<PmCheckPage> {
  List<PlatformFile> templates = [];
  String uploadDetails = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PM Verify and Upload"),
        // keep back button with a right side hamburger menu
        leading: (ModalRoute.of(context)?.canPop ?? false)
            ? const BackButton()
            : null,
      ),
      body: Column(
        children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Flexible(
                child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Click "Pick Files" and select PM templates to get started. '
                'Click "Restart" to remove all PMs '
                'Detected PMs will appear in below list '
                'Click on detected PMs to view details ',
                overflow: TextOverflow.ellipsis,
              ),
            )),
            ElevatedButton(
              onPressed: () {
                pickTemplates(context);
              },
              child: const Text('Open PM Template'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<TemplateNotifier>().clearTemplates();
              },
              child: const Text('Clear Templates'),
            ),
          ]),
          const Divider(
            height: 20,
            thickness: 3,
            indent: 0,
            endIndent: 0,
            color: Colors.black,
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
                        children: buildPMList(value),
                      );
                    })),
                const VerticalDivider(
                  width: 20,
                  thickness: 1,
                  indent: 5,
                  endIndent: 5,
                  color: Colors.grey,
                ),
                const Expanded(child: PMDetailView())
              ]))
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
                child: Text(
              'PM Settings',
              style: TextStyle(fontSize: 24),
            )),
            ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Maximo Environment'),
                subtitle:
                    const Text('Toggle which environment to apply changes to'),
                trailing: Consumer<MaximoServerNotifier>(
                    builder: (context, value, child) {
                  return DropdownButton(
                    value: value.maximoServerSelected,
                    onChanged: (String? newValue) {
                      changeMaximoEnvironment(newValue);
                    },
                    items: maximoServerDomains.keys
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  );
                })),
            const ListTile(
                leading: Icon(Icons.message),
                title: Text('Load Asset'),
                subtitle: Text('Clear and Load Assets from Spreadsheet'),
                trailing: ElevatedButton(
                  onPressed: loadHierarchy,
                  child: Text('Load Asset'),
                )),
            const ListTile(
                leading: Icon(Icons.message),
                title: Text('Load Observation'),
                subtitle:
                    Text('Clear and Load Observation list from spreadsheet'),
                trailing: ElevatedButton(
                  onPressed: loadObservationList,
                  child: Text('Load Asset'),
                )),
            const ListTile(
              // a spacer
              title: Text(''),
            ),
            Center(
                child: ElevatedButton(
              onPressed: _closeEndDrawer,
              child: const Text('Close Drawer'),
            )),
          ],
        ),
      ),
    );
  }

// for displaying bottom status notifications
  void _show(toastMsg) {
    final msg = toastMsg;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  void pickTemplates(BuildContext context) async {
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
    print('loaded files in ${stopwatch.elapsedMilliseconds} milliseconds');
    if (files.isEmpty) {
      setState(() {
        print('No files selected files...');
      });
    } else {
      setState(() {
        print('Processing files...');
      });
      final template = context.read<TemplateNotifier>();
      final maximo = context.read<MaximoServerNotifier>();
      processAllTemplates(template, files, maximo.maximoServerSelected);
    }
  }

  void changeMaximoEnvironment(String? value) {
    if (value == null) {
      return;
    }
    var maximo = context.read<MaximoServerNotifier>();
    maximo.setServer(value);
  }

  void _closeEndDrawer() {
    Navigator.of(context).pop();
  }
}

Future<List<dynamic>> parseSpreadsheets(List<PlatformFile> files) async {
  List<Future> futures = [];
  for (var file in files) {
    futures.add(compute(
        ParsedTemplate(pmName: 'Error', pmNumber: 'Error').fromExcel,
        [file.bytes!, file.name]));
  }
  return await Future.wait(futures);
}

void processAllTemplates(TemplateNotifier context, List<PlatformFile> files,
    String maximoServerSelected) async {
  var stopwatch = Stopwatch()..start();

  var parsedTmpts = await parseSpreadsheets(files);
  for (var thing in parsedTmpts) {
    for (var template in thing.keys) {
      for (var templateNumber in thing[template].keys) {
        context.setParsedTemplate(
            template, templateNumber, thing[template][templateNumber]);
      }
    }
  }
  print('Parsed templates in ${stopwatch.elapsedMilliseconds} milliseconds');
  stopwatch = Stopwatch()..start();

  for (String ws in context.getFiles()) {
    for (int templateNumber in context.getTemplates(ws)) {
      // TODO this is no longer async :(
      final value = await generateName(
        context.getParsedTemplate(ws, templateNumber),
        maximoServerSelected,
      );
      print('setting pm name');
      context.setNameTemplate(ws, templateNumber, value);

      final value2 = await generatePM(
        context.getParsedTemplate(ws, templateNumber),
        context.getPMName(ws, templateNumber),
        maximoServerSelected,
      );
      context.setProcessedTemplate(ws, templateNumber, value2);
      print('done');
    }
  }
  print('Processed templates in ${stopwatch.elapsedMilliseconds} milliseconds');
}
