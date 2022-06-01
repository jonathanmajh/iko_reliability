import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin/parse_template.dart';

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
    if (files.isNotEmpty) {
      setState(() {
        print('Loading files...');
      });
      final stopwatch = Stopwatch()..start();
      var temp = await parseSpreadsheets(files);
      setState(() {
        print('Parsed files in ${stopwatch.elapsedMilliseconds} milliseconds');
        for (var thing in temp) {
          parsedTemplates[thing.keys.first] = thing[thing.keys.first];
        }
      });
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

List<ListTile> buildPMList(parsedTemplates) {
  List<ListTile> list = [];
  for (String ws in parsedTemplates.keys) {
    for (int pmOrder in parsedTemplates[ws].keys) {
      list.add(ListTile(
        leading: Text(pmOrder.toString()),
        title: Text(parsedTemplates[ws][pmOrder].workOrderType),
        subtitle: Text(ws),
      ));
    }
  }
  return list;
}
