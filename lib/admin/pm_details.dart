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

class _PMDetailViewState extends State<PMDetailView> {
  Map<String, List<List<String>>> uploadDetails = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateNotifier>(builder: (context, value, child) {
      final selected = value.getSelectedTemplate();
      if (selected.selectedFile == null) {
        return const Text('No Template Selected');
      }
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car)),
              Tab(icon: Icon(Icons.directions_transit)),
              Tab(icon: Icon(Icons.directions_bike)),
            ],
          ),
          body: TabBarView(
            children: [
              PMDetails(),
              Icon(Icons.directions_car),
              uploadDetailsTab(value),
            ],
          ),
        ),
      );
    });
  }
}

List<Widget> generateUploadDetailsList(
    Map<String, List<List<String>>> uploadDetails, bool result) {
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
  TextEditingController fmecaPackageController = TextEditingController();
  TextEditingController pmNumberFieldController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    pmNameFieldController.dispose();
    fmecaPackageController.dispose();
    pmNumberFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemplateNotifier>(builder: (context, value, child) {
      final selected = value.getSelectedTemplate();
      bool notProcessed = false;
      if (selected.selectedFile == null) {
        return const Text('No Template Selected');
      }
      final processedTemplate = value.getProcessedTemplate(
          selected.selectedFile!, selected.selectedTemplate!);
      if (processedTemplate == null) {
        notProcessed = true;
      }
      pmNameFieldController.text = processedTemplate?.description ?? 'TBD...';
      fmecaPackageController.text =
          processedTemplate?.jobplan.ikoPmpackage ?? '';
      pmNumberFieldController.text = processedTemplate?.pmNumber ?? 'TBD...';
      return Expanded(
          child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              primary: false,
              children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                      ),
                    ))),
                    onPressed: () {
                      if (pmNameFieldController.text.isNotEmpty) {
                        value.setPMName(pmNameFieldController.text,
                            selected.selectedFile!, selected.selectedTemplate!);
                      }
                      if (pmNumberFieldController.text.isNotEmpty) {
                        value.setPMNumber(pmNumberFieldController.text,
                            selected.selectedFile!, selected.selectedTemplate!);
                      }
                      value.setPMPackage(fmecaPackageController.text,
                          selected.selectedFile!, selected.selectedTemplate!);
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.sync),
                        Text(' Update PM'),
                      ],
                    )),
                ElevatedButton(
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(),
                    ))),
                    onPressed: notProcessed
                        ? null
                        : () {
                            value.setUploadDetails(
                                selected.selectedFile!,
                                selected.selectedTemplate!,
                                generateUploads(processedTemplate!));
                          },
                    child: Row(
                      children: const [
                        Icon(Icons.visibility),
                        Text(' Preview'),
                      ],
                    )),
                Consumer<MaximoServerNotifier>(
                    builder: (context, maximo, child) {
                  return ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                      ))),
                      onPressed: notProcessed
                          ? null
                          : () async {
                              value.setUploadDetails(
                                  selected.selectedFile!,
                                  selected.selectedTemplate!,
                                  generateUploads(processedTemplate!));
                              try {
                                await uploadToMaximo(
                                    maximo.maximoServerSelected,
                                    selected.selectedFile!,
                                    selected.selectedTemplate!,
                                    value);
                              } catch (e) {
                                value.addStatusMessage(selected.selectedFile!,
                                    selected.selectedTemplate!, '$e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('$e')));
                              }
                            },
                      child: Row(
                        children: const [
                          Icon(Icons.cloud_upload),
                          Text(' Upload'),
                        ],
                      ));
                }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                    child: TextField(
                        controller: pmNumberFieldController,
                        decoration: const InputDecoration(
                          labelText:
                              'PM Number (NO DUPLICATE CHECK IF CHANGED)',
                          border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: 'Edit PMECA Package',
                    border: OutlineInputBorder(),
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
                  counterText:
                      pmNameFieldController.text.length > 100 ? null : '',
                  suffixText: null),
            ),
          ]));
    });
  }
}

Widget uploadDetailsTab(TemplateNotifier value) {
  final selected = value.getSelectedTemplate();
  final details = generateUploadDetailsList(
      value.getUploadDetails(
          selected.selectedFile!, selected.selectedTemplate!),
      (value.getStatus(selected.selectedFile!, selected.selectedTemplate!) ==
                  'done') ||
              (value.getStatus(
                      selected.selectedFile!, selected.selectedTemplate!) ==
                  'uploading')
          ? true
          : false);
  final statusMessages = value.getStatusMessages(
      selected.selectedFile!, selected.selectedTemplate!);
  return Expanded(
    child: ListView(
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
    ),
  );
}
