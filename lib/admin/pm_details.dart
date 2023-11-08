//file contains widgets for the details of PMs on the vaildate PMs page (right side of divider)

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iko_reliability_flutter/bin/consts.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'generate_job_plans.dart';
import 'generate_uploads.dart';
import 'template_notifier.dart';
import 'upload_maximo.dart';

class PMDetailView extends StatefulWidget {
  const PMDetailView({Key? key}) : super(key: key);

  @override
  State<PMDetailView> createState() => _PMDetailViewState();
}

class _PMDetailViewState extends State<PMDetailView>
    with SingleTickerProviderStateMixin {
  Map<String, List<List<String>>> uploadDetails = {};
  List<Widget> fabList = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(vsync: this, length: 3); //hard-coded tab length of 3
    _updateFab();
    _tabController.addListener(() {
      _updateFab();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateFab([bool show = false]) {
    final index = _tabController.index;
    List<Widget> temp = [];
    if (index == 0) {
      temp.add(FloatingActionButton(
        heroTag: UniqueKey(),
        onPressed: () {
          _tabController.animateTo(1);
        },
        child: const Icon(Icons.navigate_next),
      ));
    } else if (index == 1) {
      if (show) {
        final templateNotifier = context.read<TemplateNotifier>();
        final uploadNotifier = context.read<UploadNotifier>();
        final maximo = context.read<MaximoServerNotifier>();
        final selected = templateNotifier.getSelectedTemplate();
        final processedTemplate = templateNotifier.getProcessedTemplate(
            selected.selectedFile!, selected.selectedTemplate!);
        temp = [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: FloatingActionButton.extended(
              label: const Text('Preview'),
              icon: const Icon(Icons.visibility),
              heroTag: UniqueKey(),
              onPressed: () async {
                await generateUploadHelper(
                  processedTemplate,
                  templateNotifier,
                  selected.selectedFile!,
                  selected.selectedTemplate!,
                  uploadNotifier,
                );
                _updateFab();
              },
            ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: FloatingActionButton.extended(
                label: const Text('Upload'),
                icon: const Icon(Icons.cloud_upload),
                heroTag: UniqueKey(),
                onPressed: () async {
                  await generateUploadHelper(
                    processedTemplate,
                    templateNotifier,
                    selected.selectedFile!,
                    selected.selectedTemplate!,
                    uploadNotifier,
                  );
                  _updateFab();
                  try {
                    await uploadPMToMaximo(
                      maximo.maximoServerSelected,
                      selected.selectedFile!,
                      selected.selectedTemplate!,
                      templateNotifier,
                      uploadNotifier,
                    );
                  } catch (e) {
                    templateNotifier.addStatusMessage(selected.selectedFile!,
                        selected.selectedTemplate!, '$e');
                    ScaffoldMessenger.of(navigatorKey.currentContext!)
                        .showSnackBar(SnackBar(content: Text('$e')));
                  }
                },
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
        temp.add(
          FloatingActionButton(
            heroTag: UniqueKey(),
            onPressed: () {
              _updateFab(true);
            },
            child: const Icon(Icons.add),
          ),
        );
      }
    } else {
      // index = 2
      if (show) {
        temp = [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: FloatingActionButton.extended(
              heroTag: UniqueKey(),
              onPressed: () {},
              label: const Text('Export'),
              icon: const Icon(Icons.file_open_rounded),
            ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: FloatingActionButton.extended(
                heroTag: UniqueKey(),
                onPressed: () {},
                label: const Text('Import'),
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
        temp.add(
          FloatingActionButton(
            heroTag: UniqueKey(),
            onPressed: () {
              _updateFab(true);
            },
            child: const Icon(Icons.add),
          ),
        );
      }
    }
    setState(() {
      fabList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateNotifier>(builder: (context, value, child) {
      final selected = value.getSelectedTemplate();
      if (selected.selectedFile == null) {
        return const Text('No Template Selected');
      }
      ThemeData themeData = Theme.of(context);
      return Scaffold(
          appBar: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                  icon: Icon(
                Icons.tune,
                color: (themeData.colorScheme.brightness == Brightness.dark)
                    ? themeData.indicatorColor
                    : themeData.primaryColor,
              )),
              Tab(
                  icon: Icon(
                Icons.cloud_upload,
                color: (themeData.colorScheme.brightness == Brightness.dark)
                    ? themeData.indicatorColor
                    : themeData.primaryColor,
              )),
              Tab(
                  icon: Icon(
                Icons.edit_note,
                color: (themeData.colorScheme.brightness == Brightness.dark)
                    ? themeData.indicatorColor
                    : themeData.primaryColor,
              )),
            ],
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: fabList,
          ),
          body: Consumer<UploadNotifier>(
            builder: (context, uploadNotifier, child) {
              return TabBarView(
                controller: _tabController,
                children: [
                  const PMDetails(),
                  uploadDetailsTab(value, uploadNotifier, context),
                  ElevatedButton(
                    onPressed: () {
                      copyExportDetails(value, uploadNotifier);
                    },
                    child: const Text('Copy details to clipboard'),
                  ),
                ],
              );
            },
          ));
    });
  }
}

//no need to change upload log colors
List<Widget> generateUploadDetailsList(
  Map<String, List<List<String>>> uploadDetails,
  bool result, // if highlighting will be applied
  BuildContext context,
) {
  List<Widget> cards = [];
  int warnings = 0;
  int errors = 0;
  int info = 0;
  var themeData = Theme.of(context);
  for (final table in uploadDetails.keys) {
    //table header
    String header = tableHeaders[table]!.join(',');
    List<Widget> rows = [];
    rows.add(Container(
        width: double.maxFinite,
        color: themeData.colorScheme.onBackground,
        child: Text((header),
            style: TextStyle(color: themeData.colorScheme.background))));
    //table details
    if (uploadDetails[table]!.isNotEmpty) {
      for (final row in uploadDetails[table]!) {
        if (result) {
          final textColor =
              status[row.last] ?? themeData.colorScheme.background;
          if (row.last == '!') {
            errors++;
          } else if (row.last == '~') {
            warnings++;
          } else if (row.last == '+') {
            info++;
          }
          rows.add(Container(
              width: double.maxFinite,
              color: textColor,
              child: Text(
                row.join(','),
                style: TextStyle(
                    fontFamily: 'RobotoMono',
                    color: themeData.colorScheme.onBackground),
              )));
        } else {
          rows.add(Text(
            row.join(','),
            style: TextStyle(
                fontFamily: 'RobotoMono',
                color: themeData.colorScheme.onBackground),
          ));
        }
      }
      cards.add(Card(
          child: ExpansionTile(
        title: Text(table),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      )));
    }
  }
  cards.add(Text('Errors: $errors, Warnings: $warnings, Uploaded: $info'));
  return cards;
}

const status = {
  '+': Colors.green,
  '~': Colors.yellow,
  '!': Colors.red,
};

class PMDetails extends StatefulWidget {
  const PMDetails({Key? key}) : super(key: key);

  @override
  State<PMDetails> createState() => _PMDetailsState();
}

class _PMDetailsState extends State<PMDetails> {
  TextEditingController pmNameFieldController = TextEditingController();
  TextEditingController autoNameFieldController = TextEditingController();
  TextEditingController suggestNameFieldController = TextEditingController();
  TextEditingController pmNumberFieldController = TextEditingController();
  TextEditingController fmecaPackageController = TextEditingController();
  TextEditingController routeNameFieldController = TextEditingController();
  TextEditingController routeNumberFieldController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    pmNameFieldController.dispose();
    autoNameFieldController.dispose();
    suggestNameFieldController.dispose();
    fmecaPackageController.dispose();
    pmNumberFieldController.dispose();
    routeNameFieldController.dispose();
    routeNumberFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateNotifier>(
        builder: (context, templateNotifier, child) {
      final selected = templateNotifier.getSelectedTemplate();
      if (selected.selectedFile == null) {
        return const Text('No Template Selected');
      }
      final processedTemplate = templateNotifier.getProcessedTemplate(
          selected.selectedFile!, selected.selectedTemplate!);
      pmNameFieldController.text = processedTemplate?.description ?? 'TBD...';
      suggestNameFieldController.text = templateNotifier.getTemplateSuggestName(
              selected.selectedFile!, selected.selectedTemplate!) ??
          '';
      autoNameFieldController.text = templateNotifier.getTemplateAutoName(
          selected.selectedFile!, selected.selectedTemplate!);
      fmecaPackageController.text =
          processedTemplate?.jobplan.ikoPmpackage ?? '';
      pmNumberFieldController.text = processedTemplate?.pmNumber ?? 'TBD...';
      routeNameFieldController.text =
          processedTemplate?.route?.description ?? '';
      routeNumberFieldController.text =
          processedTemplate?.route?.routeNumber ?? '';

      return ListView(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          primary: false,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                    child: TextField(
                        controller: pmNumberFieldController,
                        decoration: InputDecoration(
                          labelText:
                              'PM Number (NO DUPLICATE CHECK IF CHANGED)',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              templateNotifier.setPMNumber(
                                pmNumberFieldController.text,
                                selected.selectedFile!,
                                selected.selectedTemplate!,
                                // hasRouteCode,
                              );
                            },
                            icon: const Icon(Icons.save),
                          ),
                        ))),
                VerticalDivider(
                  width: 10,
                  thickness: 1,
                  indent: 5,
                  endIndent: 5,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                Expanded(
                    child: TextField(
                  controller: fmecaPackageController,
                  decoration: InputDecoration(
                    labelText: 'Edit FMECA Package',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        templateNotifier.setPMPackage(
                            fmecaPackageController.text,
                            selected.selectedFile!,
                            selected.selectedTemplate!);
                      },
                      icon: const Icon(Icons.save),
                    ),
                  ),
                )),
              ],
            ),
            Divider(
              // spacer
              height: 10,
              thickness: 0,
              indent: 0,
              endIndent: 0,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                    child: TextField(
                        controller: routeNameFieldController,
                        decoration: InputDecoration(
                            labelText: 'Edit Route Name',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () {
                                templateNotifier.setRouteName(
                                  pmNameFieldController.text,
                                  selected.selectedFile!,
                                  selected.selectedTemplate!,
                                  // hasRouteCode,
                                );
                              },
                              icon: const Icon(Icons.save),
                            )))),
                const Icon(Icons.link),
                Expanded(
                    child: TextField(
                  controller: routeNumberFieldController,
                  decoration: InputDecoration(
                    labelText: 'Edit Route Code',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        if (routeNumberFieldController.text.isNotEmpty &&
                            routeNameFieldController.text.isNotEmpty) {
                          templateNotifier.setRouteInfo(
                            routeNumberFieldController.text,
                            routeNameFieldController.text,
                            selected.selectedFile!,
                            selected.selectedTemplate!,
                            Provider.of<MaximoServerNotifier>(context,
                                    listen: false)
                                .maximoServerSelected,
                          );
                        }
                      },
                      icon: const Icon(Icons.sync),
                    ),
                  ),
                )),
              ],
            ),
            Divider(
              // spacer
              height: 10,
              thickness: 0,
              indent: 0,
              endIndent: 0,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            TextField(
                controller: pmNameFieldController,
                maxLength: 100,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                decoration: InputDecoration(
                  labelText: 'Edit PM Name',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      templateNotifier.setPMName(
                        pmNameFieldController.text,
                        selected.selectedFile!,
                        selected.selectedTemplate!,
                        // hasRouteCode,
                      );
                    },
                    icon: const Icon(Icons.save),
                  ),
                )),
            Divider(
              // spacer
              height: 10,
              thickness: 0,
              indent: 0,
              endIndent: 0,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                    child: TextFormField(
                        controller: suggestNameFieldController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Suggested PM Name',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: "Use suggested name",
                            onPressed: () {
                              if (suggestNameFieldController.text != '') {
                                pmNameFieldController.text =
                                    suggestNameFieldController.text;
                                templateNotifier.setPMName(
                                    pmNameFieldController.text,
                                    selected.selectedFile!,
                                    selected.selectedTemplate!);
                              }
                            },
                            icon: const Icon(Icons.eject),
                          ),
                        ))),
                VerticalDivider(
                  width: 10,
                  thickness: 1,
                  indent: 5,
                  endIndent: 5,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                Expanded(
                    child: TextFormField(
                  controller: autoNameFieldController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Auto-Generated PM Name',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: "Use auto-generated name",
                      onPressed: () {
                        pmNameFieldController.text =
                            autoNameFieldController.text;
                        templateNotifier.setPMName(pmNameFieldController.text,
                            selected.selectedFile!, selected.selectedTemplate!);
                      },
                      icon: const Icon(Icons.eject),
                    ),
                  ),
                )),
              ],
            ),
          ]);
    });
  }
}

Widget uploadDetailsTab(TemplateNotifier templateNotifier,
    UploadNotifier uploadNotifier, BuildContext context) {
  final selected = templateNotifier.getSelectedTemplate();
  final details = generateUploadDetailsList(
    uploadNotifier.getUploadDetails(
        selected.selectedFile!, selected.selectedTemplate!),
    (['done', 'uploading', 'retry'].contains(templateNotifier.getStatus(
            selected.selectedFile!, selected.selectedTemplate!)))
        ? true
        : false,
    context,
  );
  final statusMessages = templateNotifier.getStatusMessages(
      selected.selectedFile!, selected.selectedTemplate!);
  return ListView(
    padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
    primary: false,
    children: [
      statusMessages.isNotEmpty
          ? Card(
              child: ExpansionTile(
                title: const Text('Processing Log'),
                children: <Widget>[
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: statusMessages.length,
                    prototypeItem: ListTile(
                      title: Text(statusMessages.first),
                    ),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(statusMessages[index]),
                      );
                    },
                  ),
                ],
              ),
            )
          : Container(),
      Card(
        child: ExpansionTile(
          title: const Text('Upload Details'),
          subtitle: details.removeLast(),
          children: details,
        ),
      )
    ],
  );
}

void copyExportDetails(
    TemplateNotifier templateNotifier, UploadNotifier uploadNotifier) {
  final selected = templateNotifier.getSelectedTemplate();
  final details = uploadNotifier.getUploadDetails(
      selected.selectedFile!, selected.selectedTemplate!);
  String allData = '';
  for (final tables in details.keys) {
    allData = '''
$allData\n
$tables
${const ListToCsvConverter().convert([tableHeaders[tables]])}
${const ListToCsvConverter().convert(details[tables])}
''';
  }
  Clipboard.setData(ClipboardData(text: allData)).then((_) {
    return;
  });
}

Future<void> generateUploadHelper(
  PMMaximo? processedTemplate,
  TemplateNotifier templateNotifier,
  String file,
  int template,
  UploadNotifier uploadNotifier,
) async {
  if (processedTemplate != null) {
    var upload = await generateUploads(processedTemplate);
    templateNotifier.clearStatusMessage(file, template);
    if (upload.containsKey('Errors')) {
      final errors = upload.remove('Errors');
      for (final msg in errors!) {
        templateNotifier.addStatusMessage(file, template, msg[0]);
      }
    }
    uploadNotifier.setUploadDetails(
      file,
      template,
      upload,
    );
  }
}
