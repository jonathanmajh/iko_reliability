import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iko_reliability_flutter/admin/consts.dart';
import 'package:provider/provider.dart';

import '../main.dart';
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
  static const List<Tab> myTabs = <Tab>[
    Tab(
        icon: Icon(
      Icons.tune,
      color: Color.fromRGBO(255, 0, 0, 1),
    )),
    Tab(
        icon: Icon(
      Icons.cloud_upload,
      color: Color.fromRGBO(255, 0, 0, 1),
    )),
    Tab(
        icon: Icon(
      Icons.edit_note,
      color: Color.fromRGBO(255, 0, 0, 1),
    )),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: myTabs.length);
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
              heroTag: UniqueKey(),
              onPressed: () async {
                if (processedTemplate != null) {
                  var upload = await generateUploads(processedTemplate);
                  if (upload.containsKey('Errors')) {
                    final errors = upload.remove('Errors');
                    for (final msg in errors!) {
                      templateNotifier.addStatusMessage(selected.selectedFile!,
                          selected.selectedTemplate!, msg[0]);
                    }
                  }
                  uploadNotifier.setUploadDetails(
                    selected.selectedFile!,
                    selected.selectedTemplate!,
                    upload,
                  );
                }
                _updateFab();
              },
              label: const Text('Preview'),
              icon: const Icon(Icons.visibility),
            ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: FloatingActionButton.extended(
                heroTag: UniqueKey(),
                onPressed: () async {
                  var upload = await generateUploads(processedTemplate!);
                  if (upload.containsKey('Errors')) {
                    final errors = upload.remove('Errors');
                    for (final msg in errors!) {
                      templateNotifier.addStatusMessage(selected.selectedFile!,
                          selected.selectedTemplate!, msg[0]);
                    }
                  }
                  uploadNotifier.setUploadDetails(
                    selected.selectedFile!,
                    selected.selectedTemplate!,
                    upload,
                  );
                  _updateFab();
                  try {
                    await uploadToMaximo(
                      maximo.maximoServerSelected,
                      selected.selectedFile!,
                      selected.selectedTemplate!,
                      templateNotifier,
                      uploadNotifier,
                    );
                  } catch (e) {
                    templateNotifier.addStatusMessage(selected.selectedFile!,
                        selected.selectedTemplate!, '$e');
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('$e')));
                  }
                },
                label: const Text('Upload'),
                icon: const Icon(Icons.cloud_upload),
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
      return Scaffold(
          appBar: TabBar(
            controller: _tabController,
            tabs: myTabs,
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
                  uploadDetailsTab(value, uploadNotifier),
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

List<Widget> generateUploadDetailsList(
  Map<String, List<List<String>>> uploadDetails,
  bool result, // if highlighting will be applied
) {
  List<Widget> cards = [];
  int warnings = 0;
  int errors = 0;
  int info = 0;
  for (final table in uploadDetails.keys) {
    List<Widget> rows = [];
    rows.add(Container(
        width: double.maxFinite,
        color: Colors.black,
        child: Text((tableHeaders[table]!.join(',')),
            style: const TextStyle(color: Colors.white))));
    if (uploadDetails[table]!.isNotEmpty) {
      for (final row in uploadDetails[table]!) {
        if (result) {
          final textColor = status[row.last] ?? Colors.white;
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
                style: const TextStyle(fontFamily: 'RobotoMono'),
              )));
        } else {
          rows.add(Text(
            row.join(','),
            style: const TextStyle(fontFamily: 'RobotoMono'),
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
  TextEditingController pmNumberFieldController = TextEditingController();
  TextEditingController fmecaPackageController = TextEditingController();
  TextEditingController routeNameFieldController = TextEditingController();
  TextEditingController routeNumberFieldController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    pmNameFieldController.dispose();
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
      bool notProcessed = false;
      if (selected.selectedFile == null) {
        return const Text('No Template Selected');
      }
      final processedTemplate = templateNotifier.getProcessedTemplate(
          selected.selectedFile!, selected.selectedTemplate!);
      if (processedTemplate == null) {
        notProcessed = true;
      }
      pmNameFieldController.text = processedTemplate?.description ?? 'TBD...';
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
                const VerticalDivider(
                  width: 10,
                  thickness: 1,
                  indent: 5,
                  endIndent: 5,
                  color: Colors.white,
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
            const Divider(
              // spacer
              height: 10,
              thickness: 0,
              indent: 0,
              endIndent: 0,
              color: Color.fromARGB(255, 255, 255, 255),
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
                                  .maximoServerSelected);
                        }
                      },
                      icon: const Icon(Icons.sync),
                    ),
                  ),
                )),
              ],
            ),
            const Divider(
              // spacer
              height: 10,
              thickness: 0,
              indent: 0,
              endIndent: 0,
              color: Color.fromARGB(255, 255, 255, 255),
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
          ]);
    });
  }
}

Widget uploadDetailsTab(
    TemplateNotifier templateNotifier, UploadNotifier uploadNotifier) {
  final selected = templateNotifier.getSelectedTemplate();
  final details = generateUploadDetailsList(
    uploadNotifier.getUploadDetails(
        selected.selectedFile!, selected.selectedTemplate!),
    (['done', 'uploading', 'retry'].contains(templateNotifier.getStatus(
            selected.selectedFile!, selected.selectedTemplate!)))
        ? true
        : false,
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
