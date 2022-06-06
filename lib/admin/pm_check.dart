import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin/parse_template.dart';
import 'package:flutter_application_1/admin/pm_name_generator.dart';

class PmCheckPage extends StatefulWidget {
  const PmCheckPage({Key? key}) : super(key: key);

  @override
  State<PmCheckPage> createState() => _PmCheckPageState();
}

class _PmCheckPageState extends State<PmCheckPage> {
  final optionListFilePath =
      'http://operations.connect.na.local/support/Reliability/ReliabilityPublished/Templates/PM%20Request%20Template.xlsm';
  Map<String, Map<String, String>> sites = {};
  Map<String, Map<String, dynamic>> observationList = {};
  Map<String, String> workOrderType = {};
  List<PlatformFile> templates = [];
  bool optionOne = false;
  Map<String, dynamic> parsedTemplates = {};

  void _show(toastMsg) {
    final msg = toastMsg;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  void pickTemplates() async {
    print('Picking Files');
    final stopwatch = Stopwatch()..start();
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
    print('loaded files in ${stopwatch.elapsedMilliseconds} milliseconds');
    setState(() {
      templates = files;
      _show(msg);
    });
    if (files.isNotEmpty) {
      setState(() {
        print('Loading files...');
      });

      var temp = await parseSpreadsheets(files);
      setState(() {
        for (var thing in temp) {
          parsedTemplates[thing.keys.first] = thing[thing.keys.first];
        }
        print(
            'Parsed templates in ${stopwatch.elapsedMilliseconds} milliseconds');
      });
      parseAllTemplates();
    }
  }

  Future<List<dynamic>> parseSpreadsheets(List<PlatformFile> files) async {
    List<Future> futures = [];
    for (var file in files) {
      futures.add(
          compute(PreventiveMaintenance().fromExcel, [file.bytes!, file.name]));
    }
    return await Future.wait(futures);
  }

  void parseAllTemplates() {
    print('parsing templates');
    for (String ws in parsedTemplates.keys) {
      for (int pmOrder in parsedTemplates[ws].keys) {
        parseTemplate([ws, pmOrder]);
      }
    }
  }

  void parseTemplate(List<dynamic> parameters) async {
    String ws = parameters[0];
    int templateNumber = parameters[1];
    var result =
        await PMName().generateName(parsedTemplates[ws][templateNumber]);
    setState(() {
      var processed =
          ProcessedTemplate(pmName: result.pmName, pmNumber: result.pmNumber);
      parsedTemplates[ws][templateNumber].uploads = processed;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void toggleOptionOne(bool value) {
    if (optionOne) {
      setState(() {
        optionOne = false;
        // reset table
      });
    } else {
      setState(() {
        optionOne = true;
      });
    }
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
                  'Click "Pick Files" and select PM templates to get started.\nClick "Restart" to remove all PMs\nDetected PMs will appear in below list'),
              ElevatedButton(
                onPressed: () {
                  pickTemplates();
                },
                child: const Text('Pick Files'),
              ),
              ElevatedButton(
                onPressed: () {
                  pickTemplates(); //TODO
                },
                child: const Text('Restart'),
              ),
            ],
          ),
          Expanded(
              child: parsedTemplates.isNotEmpty
                  ? ListView(
                      children: buildPMList(parsedTemplates),
                    )
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
              title: const Text('Option 1'),
              subtitle: const Text(
                  'Option 1 help text, this will be a very long and detailed explaination about what toggling this option entails. reload / re validate should occur after the drawer has been closed'),
              trailing: Switch(value: optionOne, onChanged: toggleOptionOne),
            ),
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
}

List<Widget> buildPMList(parsedTemplates) {
  List<Widget> list = [];
  for (String ws in parsedTemplates.keys) {
    for (int pmOrder in parsedTemplates[ws].keys) {
      list.add(TemplateListItem(
        templateNumber: pmOrder,
        pmName: parsedTemplates[ws][pmOrder].workOrderType,
        filename: ws,
        status: parsedTemplates[ws][pmOrder].uploads == null
            ? 'processing'
            : 'done',
      ));
    }
  }
  return list;
}

class TemplateListItem extends StatelessWidget {
  const TemplateListItem({
    Key? key,
    required this.filename,
    required this.pmName,
    required this.status,
    required this.templateNumber,
  }) : super(key: key);

  final String filename;
  final int templateNumber;
  final String pmName;
  final String status;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
              child: _TemplateDescription(
                filename: filename,
                templateNumber: templateNumber,
                pmName: pmName,
                status: status,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateDescription extends StatelessWidget {
  const _TemplateDescription({
    Key? key,
    required this.filename,
    required this.pmName,
    required this.status,
    required this.templateNumber,
  }) : super(key: key);

  final String filename;
  final int templateNumber;
  final String pmName;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                pmName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Text(
                filename,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                ),
              ),
              Text(
                'Template #$templateNumber',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              statusIndicator(status),
            ],
          ),
        ),
      ],
    );
  }
}

Widget statusIndicator(status) {
  Widget icon;
  String text;
  Color textColor;
  switch (status) {
    case 'processing':
      icon = const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator.adaptive(),
      );

      text = ' Processing';
      textColor = const Color.fromRGBO(33, 150, 243, 1);
      break;
    case 'warning':
      icon = const Icon(Icons.warning_rounded);
      text = ' Warning';
      textColor = const Color.fromRGBO(255, 235, 59, 1);
      break;
    case 'error':
      icon = const Icon(Icons.report_rounded);
      text = ' Error';
      textColor = const Color.fromRGBO(244, 67, 54, 1);
      break;
    case 'done':
      icon = const Icon(Icons.check_circle);
      text = ' Finished';
      textColor = const Color.fromRGBO(76, 175, 80, 1);
      break;
    default:
      icon = const Icon(Icons.help);
      text = ' Unknown';
      textColor = const Color.fromRGBO(255, 235, 59, 1);
  }
  return Row(
    children: [
      icon,
      Text(
        text,
        style: TextStyle(
          fontSize: 20.0,
          color: textColor,
        ),
      )
    ],
  );
}
