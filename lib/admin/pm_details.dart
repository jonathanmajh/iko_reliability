import 'package:flutter/material.dart';
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
  String uploadDetails = '';

  @override
  Widget build(BuildContext context) {
    TextEditingController pmNameFieldController = TextEditingController();
    TextEditingController fmecaPackageController = TextEditingController();
    return Consumer<TemplateNotifier>(builder: (context, value, child) {
      final selected = value.getSelectedTemplate();
      if (selected.selectedFile == null) {
        return const Text('No Tempalte Selected');
      }
      final processedTemplate = value.getProcessedTemplate(
          selected.selectedFile!, selected.selectedTemplate!);
      pmNameFieldController.text = processedTemplate!.description;
      fmecaPackageController.text =
          processedTemplate.jobplan.ikoPmpackage ?? '';
      return Expanded(
          child: ListView(
        primary: false,
        children: [
          ListTile(title: Text(processedTemplate.pmNumber)),
          ListTile(title: Text(processedTemplate.description)),
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
              if (pmNameFieldController.text.isNotEmpty) {
                value.setPMName(pmNameFieldController.text,
                    selected.selectedFile!, selected.selectedTemplate!);
              }
              value.setPMPackage(fmecaPackageController.text,
                  selected.selectedFile!, selected.selectedTemplate!);
            },
            child: const Text('Update PM'),
          ),
          ElevatedButton(
            onPressed: () {
              final thing = generateUploads(processedTemplate);
              setState(() {
                uploadDetails = writeToCSV(thing);
              });
            },
            child: const Text('ConvertToTemplate'),
          ),
          Consumer<MaximoServerNotifier>(builder: (context, value, child) {
            return ElevatedButton(
              onPressed: () async {
                final thing = await uploadToMaximo(
                    generateUploads(processedTemplate),
                    value.maximoServerSelected);
                print('done');
                setState(() {
                  uploadDetails = writeToCSV(thing);
                });
                // print(thing);
              },
              child: const Text('Just DO IT'),
            );
          }),
          SelectableText(uploadDetails),
        ],
      ));
    });
  }
}
