import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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

  void _show(toastMsg) {
    final msg = toastMsg;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  void pickTemplates() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
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
      ),
      body: ElevatedButton(
        onPressed: () {
          pickTemplates();
        },
        child: const Text('Pick Files'),
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
