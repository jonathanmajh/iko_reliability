import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iko_reliability/admin/parse_template.dart';
import 'package:iko_reliability/admin/pm_name_generator.dart';

import 'asset_storage.dart';
import 'generate_job_plans.dart';
import 'generate_uploads.dart';
import 'maximo_jp_pm.dart';
import 'observation_list_storage.dart';

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
  String maximoServerSelected = 'TEST';
  List<dynamic> _selected = [];
  Map<String, dynamic> parsedTemplates = {};
  String temp = '';

  void _show(toastMsg) {
    final msg = toastMsg;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  List<Widget> detailedView(List<dynamic> state) {
    if (state.isNotEmpty) {
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
                title:
                    Text(parsedTemplates[state[0]][state[1]].maximo.pmNumber)),
            ListTile(
                title: Text(
                    parsedTemplates[state[0]][state[1]].maximo.description)),
            ListTile(
                title: Text(
                    parsedTemplates[state[0]][state[1]].maximo.assetNumber)),
            ListTile(
                title: Text(parsedTemplates[state[0]][state[1]]
                    .maximo
                    .leadTime
                    .toString())),
            ElevatedButton(
              onPressed: () {
                final thing =
                    generateUploads(parsedTemplates[state[0]][state[1]].maximo);
                setState(() {
                  temp = writeToCSV(thing);
                });
              },
              child: const Text('ConvertToTemplate'),
            ),
            Text(temp)
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
      futures
          .add(compute(ParsedTemplate().fromExcel, [file.bytes!, file.name]));
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
    var result = await generateName(
        parsedTemplates[ws][templateNumber], maximoServerSelected);
    setState(() {
      parsedTemplates[ws][templateNumber].uploads = result;
    });
    generatePM(parsedTemplates[ws][templateNumber], maximoServerSelected)
        .then((value) {
      setState(() {
        parsedTemplates[ws][templateNumber].maximo = value;
      });
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
                  pickTemplates();
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
                onPressed: () async {
                  final thing = await findAvailablePMNumber(
                      'S4790W1INRM', 'GJ', maximoServerSelected, 'INR', 1);
                  print(thing);
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
              title: const Text('Option 1'),
              subtitle: const Text('Option 1 help text'),
              trailing: Switch(value: optionOne, onChanged: toggleOptionOne),
            ),
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
          parsedTemplates[ws][pmOrder].uploads?.pmName ??
              parsedTemplates[ws][pmOrder].pmName,
          parsedTemplates[ws][pmOrder].uploads?.pmNumber ??
              parsedTemplates[ws][pmOrder].pmNumber,
          parsedTemplates[ws][pmOrder].uploads == null ? 'processing' : 'done',
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
            if (parsedTemplates[filename][templateNumber].maximo != null) {
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

Widget templateDescription(
  String filename,
  int templateNumber,
  String pmName,
  String pmNumber,
  String status,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              pmNumber,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
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
