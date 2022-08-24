import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iko_reliability/admin/parse_template.dart';
import 'package:iko_reliability/admin/pm_name_generator.dart';
import 'package:provider/provider.dart';

import 'asset_storage.dart';
import 'generate_job_plans.dart';
import 'generate_uploads.dart';
import 'maximo_jp_pm.dart';
import 'observation_list_storage.dart';
import 'template_notifier.dart';
import 'upload_maximo.dart';
import 'pm_widgets.dart';

class PmCheckPage extends StatefulWidget {
  const PmCheckPage({Key? key}) : super(key: key);

  @override
  State<PmCheckPage> createState() => _PmCheckPageState();
}

class _PmCheckPageState extends State<PmCheckPage> {
  List<PlatformFile> templates = [];
  String maximoServerSelected = 'TEST';
  List<dynamic> _selected = [];
  Map<String, dynamic> parsedTemplates = {};
  String uploadDetails = '';
  final pmNameFieldController = TextEditingController();
  final fmecaPackageController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    pmNameFieldController.dispose();
    fmecaPackageController.dispose();
    super.dispose();
  }

// for displaying bottom status notifications
  void _show(toastMsg) {
    final msg = toastMsg;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  List<Widget> detailedView(List<dynamic> state) {
    if (state.isNotEmpty) {
      pmNameFieldController.text =
          parsedTemplates[state[0]][state[1]].processedTemplate.description;
      fmecaPackageController.text = parsedTemplates[state[0]][state[1]]
              .processedTemplate
              .jobplan
              .ikoPmpackage ??
          '';
      return [
        GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              setState(() {
                _selected = [];
              });
            },
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.keyboard_double_arrow_right),
                  Icon(Icons.keyboard_double_arrow_right),
                  Icon(Icons.keyboard_double_arrow_right),
                ])),
        Expanded(
            child: ListView(
          primary: false,
          children: [
            ListTile(
                title: Text(parsedTemplates[state[0]][state[1]]
                    .processedTemplate
                    .pmNumber)),
            ListTile(
                title: Text(parsedTemplates[state[0]][state[1]]
                    .processedTemplate
                    .description)),
            ListTile(
                title: Text(parsedTemplates[state[0]][state[1]]
                    .processedTemplate
                    .assetNumber)),
            ListTile(
                title: Text(parsedTemplates[state[0]][state[1]]
                    .processedTemplate
                    .leadTime
                    .toString())),
            ListTile(
              title: const Text('Edit Pm Name'),
              subtitle: TextField(
                controller: pmNameFieldController,
              ),
            ),
            ListTile(
              title: const Text('Enter FMECA Package'),
              subtitle: TextField(
                controller: fmecaPackageController,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                parsedTemplates[state[0]][state[1]]
                    .processedTemplate
                    .description = pmNameFieldController.text;
                parsedTemplates[state[0]][state[1]]
                    .processedTemplate
                    .jobplan
                    .description = pmNameFieldController.text;
                if (parsedTemplates[state[0]][state[1]]
                        .processedTemplate
                        .route !=
                    null) {
                  parsedTemplates[state[0]][state[1]]
                      .processedTemplate
                      .route
                      .description = pmNameFieldController.text;
                }
                if (fmecaPackageController.text.isNotEmpty) {
                  parsedTemplates[state[0]][state[1]]
                      .processedTemplate
                      .fmecaPM = true;
                  parsedTemplates[state[0]][state[1]]
                      .processedTemplate
                      .jobplan
                      .ikoPmpackage = fmecaPackageController.text;
                } else {
                  parsedTemplates[state[0]][state[1]]
                      .processedTemplate
                      .fmecaPM = false;
                  parsedTemplates[state[0]][state[1]]
                      .processedTemplate
                      .jobplan
                      .ikoPmpackage = null;
                }
                setState(() {});
              },
              child: const Text('Update PM'),
            ),
            ElevatedButton(
              onPressed: () {
                final thing = generateUploads(
                    parsedTemplates[state[0]][state[1]].processedTemplate);
                setState(() {
                  uploadDetails = writeToCSV(thing);
                });
              },
              child: const Text('ConvertToTemplate'),
            ),
            ElevatedButton(
              onPressed: () async {
                final thing = await uploadToMaximo(
                    generateUploads(
                        parsedTemplates[state[0]][state[1]].processedTemplate),
                    maximoServerSelected);
                print('done');
                setState(() {
                  uploadDetails = writeToCSV(thing);
                });
                // print(thing);
              },
              child: const Text('Just DO IT'),
            ),
            SelectableText(uploadDetails)
          ],
        ))
      ];
    } else {
      return const [
        VerticalDivider(
          width: 20,
          thickness: 1,
          indent: 20,
          endIndent: 0,
          color: Colors.grey,
        )
      ];
    }
  }

  void pickTemplates(TemplateNotifier context) async {
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
      processAllTemplates(context, files, maximoServerSelected);
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  // }

  void changeMaximoEnvironment(String? value) {
    if (value == null) {
      return;
    }
    setState(() {
      maximoServerSelected = value;
      // TODO reset table generated information
    });
  }

  void _closeEndDrawer() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PM Verify and Upload"),
        leading: (ModalRoute.of(context)?.canPop ?? false)
            ? const BackButton()
            : null,
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                  'Click "Pick Files" and select PM templates to get started.'
                  '\nClick "Restart" to remove all PMs'
                  '\nDetected PMs will appear in below list'
                  '\nClick on detected PMs to view details'),
              ElevatedButton(
                onPressed: () {
                  pickTemplates(context.read<TemplateNotifier>());
                },
                child: const Text('Pick Files'),
              ),
              ElevatedButton(
                onPressed: () {
                  loadHierarchy();
                },
                child: const Text('LoadAssets'),
              ),
              ElevatedButton(
                onPressed: () {
                  loadObservationList();
                },
                child: const Text('LoadObservation'),
              ),
              ElevatedButton(
                onPressed: () {
                  final thing = getObservation('CYLA00');
                  print(thing);
                  print(thing.observations);
                },
                child: const Text('GetObservation'),
              ),
            ],
          ),
          Expanded(
              child: parsedTemplates.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                            Expanded(
                                child: ListView(
                              children: buildPMList(parsedTemplates),
                            ))
                          ] +
                          detailedView(_selected))
                  : const Text("Waiting for Data"))
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
                trailing: DropdownButton(
                  value: maximoServerSelected,
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
                )),
            const ListTile(
                leading: Icon(Icons.message),
                title: Text('Load Asset'),
                subtitle: Text('Clear and Load Assets from Spreadsheet'),
                trailing: ElevatedButton(
                  onPressed: loadHierarchy,
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

  List<Widget> buildPMList(parsedTemplates) {
    List<Widget> list = [];
    for (String ws in parsedTemplates.keys) {
      for (int pmOrder in parsedTemplates[ws].keys) {
        list.add(templateListItem(
          ws,
          pmOrder,
          parsedTemplates[ws][pmOrder].generatedPmName?.pmName ??
              parsedTemplates[ws][pmOrder].pmName,
          parsedTemplates[ws][pmOrder].generatedPmName?.pmNumber ??
              parsedTemplates[ws][pmOrder].pmNumber,
          parsedTemplates[ws][pmOrder].generatedPmName == null
              ? 'processing'
              : 'done',
        ));
      }
    }
    return list;
  }

  Widget templateListItem(
    String filename,
    int templateNumber,
    String pmName,
    String pmNumber,
    String status,
  ) {
    return SizedBox(
        height: 100,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (parsedTemplates[filename][templateNumber].processedTemplate !=
                null) {
              setState(() {
                _selected = [filename, templateNumber];
              });
            } else {
              _show('Template is still being parsed...');
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
                  child: templateDescription(
                    filename,
                    templateNumber,
                    pmName,
                    pmNumber,
                    status,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

Future<List<dynamic>> parseSpreadsheets(List<PlatformFile> files) async {
  List<Future> futures = [];
  for (var file in files) {
    futures.add(compute(ParsedTemplate().fromExcel, [file.bytes!, file.name]));
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
      generateName(context.getParsedTemplate(ws, templateNumber),
              maximoServerSelected)
          .then((value) => () {
                context.setNameTemplate(ws, templateNumber, value);
              });

      generatePM(context.getParsedTemplate(ws, templateNumber),
              context.getPMName(ws, templateNumber), maximoServerSelected)
          .then((value) => () {
                context.setProcessedTemplate(ws, templateNumber, value);
              });
    }
  }
  print('Processed templates in ${stopwatch.elapsedMilliseconds} milliseconds');
}
