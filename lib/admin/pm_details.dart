import 'package:flutter/material.dart';
import 'package:iko_reliability/admin/consts.dart';
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
    TextEditingController pmNameFieldController = TextEditingController();
    TextEditingController fmecaPackageController = TextEditingController();
    TextEditingController pmNumberFieldController = TextEditingController();
    return Consumer<TemplateNotifier>(builder: (context, value, child) {
      final selected = value.getSelectedTemplate();
      bool notProcessed = false;
      if (selected.selectedFile == null) {
        return const Text('No Template Selected');
      }
      final statusMessages = value.getStatusMessages(
          selected.selectedFile!, selected.selectedTemplate!);
      final processedTemplate = value.getProcessedTemplate(
          selected.selectedFile!, selected.selectedTemplate!);
      if (processedTemplate == null) {
        notProcessed = true;
      }
      pmNameFieldController.text = processedTemplate?.description ?? 'TBD...';
      fmecaPackageController.text =
          processedTemplate?.jobplan.ikoPmpackage ?? '';
      pmNumberFieldController.text = processedTemplate?.pmNumber ?? 'TBD...';
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
              Consumer<MaximoServerNotifier>(builder: (context, maximo, child) {
                return ElevatedButton(
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(),
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
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('$e')));
                            }
                          },
                    child: Row(
                      children: const [
                        Icon(Icons.cloud_upload),
                        Text(' Upload'),
                      ],
                    ));
              }),
              ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ))),
                onPressed: (() {}),
                child: Text('Lines Uploaded: ${value.getUploadedLines()}'),
              ),
            ],
          ),
          const Divider(
            height: 15,
            thickness: 1,
            indent: 10,
            endIndent: 10,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              primary: false,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                        child: TextField(
                            readOnly: true,
                            controller: pmNumberFieldController,
                            decoration: const InputDecoration(
                              labelText: 'PM Number (Read Only)',
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
                  decoration: const InputDecoration(
                    labelText: 'Edit PM Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                Card(
                  child: ExpansionTile(
                    title: const Text('Processing Log'),
                    children: <Widget>[
                      statusMessages.isEmpty
                          ? const Center(
                              child: Divider(
                                height: 15,
                                thickness: 1,
                                indent: 10,
                                endIndent: 10,
                                color: Color.fromARGB(0, 0, 0, 0),
                              ),
                            )
                          : ListView.builder(
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
                ),
                Card(
                    child: ExpansionTile(
                        title: const Text('Upload Details'),
                        children: generateUploadDetailsList(
                            value.getUploadDetails(selected.selectedFile!,
                                selected.selectedTemplate!),
                            (value.getStatus(selected.selectedFile!,
                                            selected.selectedTemplate!) ==
                                        'done') ||
                                    (value.getStatus(selected.selectedFile!,
                                            selected.selectedTemplate!) ==
                                        'uploading')
                                ? true
                                : false)))
              ],
            ),
          )
        ],
      );
    });
  }
}

List<Widget> generateUploadDetailsList(
    Map<String, List<List<String>>> uploadDetails, bool result) {
  List<Widget> cards = [];
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
  return cards;
}

const status = {
  '+': Colors.green,
  '~': Colors.yellow,
  '!': Colors.red,
};
