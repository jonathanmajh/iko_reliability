import 'package:flutter/material.dart';

import 'template_notifier.dart';

Widget templateDescription(
  String filename,
  int templateNumber,
  TemplateNotifier templateNotifier,
  BuildContext context,
) {
  Color vertCol = Colors.grey;
  BoxDecoration? boxDecoration;
  final selected = templateNotifier.getSelectedTemplate();
  if (selected.selectedFile == filename &&
      selected.selectedTemplate == templateNumber) {
    Color containerCol = Theme.of(context).colorScheme.secondaryContainer;
    vertCol = Colors.redAccent;
    boxDecoration = BoxDecoration(
        color: containerCol,
        border: Border.all(color: containerCol),
        borderRadius: const BorderRadius.all(Radius.circular(20)));
  }
  return Container(
    decoration: boxDecoration,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              statusIndicator(
                  templateNotifier.getStatus(filename, templateNumber), context)
            ],
          ),
        ),
        VerticalDivider(
          width: 20,
          thickness: 1,
          indent: 10,
          endIndent: 10,
          color: vertCol,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                templateNotifier.getTemplateNumber(filename, templateNumber),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                templateNotifier.getTemplateName(filename, templateNumber),
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
                style: TextStyle(
                  fontSize: 12.0,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                'Template #$templateNumber',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget statusIndicator(String status, BuildContext context) {
  Widget icon;
  String text;
  Color textColor;
  switch (status) {
    case 'processing':
      icon = const SizedBox(
        height: 35,
        width: 35,
        child: CircularProgressIndicator.adaptive(),
      );
      text = 'Processing';
      textColor = const Color.fromRGBO(33, 150, 243, 1);
      break;
    case 'uploading':
      icon = const SizedBox(
        height: 35,
        width: 35,
        child: CircularProgressIndicator.adaptive(),
      );
      text = 'Uploading';
      textColor = const Color.fromRGBO(33, 150, 243, 1);
      break;
    case 'warning':
      text = 'Warning';
      textColor = const Color.fromRGBO(255, 235, 59, 1);
      icon = Icon(
        Icons.warning_rounded,
        color: textColor,
        size: 35,
      );
      break;
    case 'retry':
      text = 'Retry';
      textColor = const Color.fromARGB(255, 255, 166, 0);
      icon = Icon(
        Icons.sync_problem,
        color: textColor,
        size: 35,
      );
      break;
    case 'processing-done':
      text = 'Generated';
      textColor = Theme.of(context).colorScheme.onSurface;
      icon = Icon(
        Icons.pause_circle_filled,
        color: textColor,
        size: 35,
      );
      break;
    case 'error':
      text = 'Error';
      textColor = const Color.fromRGBO(244, 67, 54, 1);
      icon = Icon(
        Icons.report_rounded,
        color: textColor,
        size: 35,
      );
      break;
    case 'done':
      text = 'Finished';
      textColor = const Color.fromRGBO(76, 175, 80, 1);
      icon = Icon(
        Icons.check_circle,
        color: textColor,
        size: 35,
      );
      break;
    default:
      text = 'Unknown';
      textColor = const Color.fromRGBO(255, 235, 59, 1);
      icon = Icon(
        Icons.help,
        color: textColor,
        size: 35,
      );
  }
  return Column(
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

///Widget for listing PMs uploaded from file
List<Widget> buildPMList(
    TemplateNotifier templateNotify, BuildContext context) {
  List<Widget> list = [];
  for (String ws in templateNotify.getFiles()) {
    for (int templateNumber in templateNotify.getTemplates(ws)) {
      list.add(templateListItem(
        ws,
        templateNumber,
        templateNotify,
        context,
      ));
      list.add(Divider(
        height: 5,
        thickness: 1,
        indent: 20,
        endIndent: 20,
        color: Theme.of(context).dividerColor,
      ));
    }
  }
  if (templateNotify.getLoading()) {
    list.add(const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 100,
            width: 100,
            child: CircularProgressIndicator.adaptive(),
          )
        ]));
  }
  if (list.isEmpty) {
    list.add(const Text('Open PM Template - Select and parse template files'));
    list.add(const Text('Clear Templates - Clears all templates from program'));
    list.add(const Text('Parsed PMs will appear in below list'));
    list.add(const Text('Click on PMs in list to view details'));
  }
  return list;
}

Widget templateListItem(
  String filename,
  int templateNumber,
  TemplateNotifier templateNotifier,
  BuildContext context,
) {
  return SizedBox(
    height: 100,
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        templateNotifier.setSelectedTemplate(filename, templateNumber);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              child: templateDescription(
                filename,
                templateNumber,
                templateNotifier,
                context,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
