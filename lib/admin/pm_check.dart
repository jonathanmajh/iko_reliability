import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:iko_reliability/admin/parse_template.dart';
import 'package:iko_reliability/admin/pm_name_generator.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'asset_storage.dart';
import 'end_drawer.dart';
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
          const Divider(
            height: 10,
            thickness: 1,
            indent: 0,
            endIndent: 0,
            color: Colors.white,
          ),
          Expanded(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                SizedBox(
                    width: 550,
                    child: Consumer<TemplateNotifier>(
                        builder: (context, value, child) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    pickTemplates(context);
                                  },
                                  child: const Text('Open PM Template'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<TemplateNotifier>()
                                        .clearTemplates();
                                    var box = Hive.box('jpNumber');
                                    box.clear();
                                    box = Hive.box('pmNumber');
                                    box.clear();
                                    box = Hive.box('routeNumber');
                                    box.clear();
                                  },
                                  child: const Text('Clear Templates'),
                                ),
                              ]),
                          const Divider(
                            height: 15,
                            thickness: 1,
                            indent: 10,
                            endIndent: 10,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          Expanded(
                              child: ListView(
                            children: buildPMList(value),
                          ))
                        ],
                      );
                    })),
                const VerticalDivider(
                  width: 20,
                  thickness: 1,
                  indent: 5,
                  endIndent: 5,
                  color: Colors.grey,
                ),
                const Expanded(child: PMDetailView()),
                const VerticalDivider(
                  width: 8,
                  thickness: 1,
                  indent: 5,
                  endIndent: 5,
                  color: Colors.white,
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
  var parsedTmpts = await parseSpreadsheets(files);
  for (var thing in parsedTmpts) {
    for (var template in thing.keys) {
      for (var templateNumber in thing[template].keys) {
        context.setParsedTemplate(
            template, templateNumber, thing[template][templateNumber]);
      }
    }
  }
  for (var thing in parsedTmpts) {
    for (String ws in thing.keys) {
      for (int templateNumber in thing[ws].keys) {
        // TODO this is no longer async :(
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
      }
    }
  }
}
