import 'package:flutter/material.dart';

import 'template_notifier.dart';

Widget templateDescription(
  String filename,
  int templateNumber,
  TemplateNotifier context,
) {
  final template = context.getFullTemplate(filename, templateNumber);
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              template.nameTemplate?.pmNumber ??
                  template.parsedTemplate.pmNumber,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              template.nameTemplate?.pmName ?? template.parsedTemplate.pmName,
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
            statusIndicator(template.templateStatus),
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

List<Widget> buildPMList(TemplateNotifier context) {
  List<Widget> list = [];
  for (String ws in context.getFiles()) {
    for (int templateNumber in context.getTemplates(ws)) {
      list.add(templateListItem(
        ws,
        templateNumber,
        context,
      ));
    }
  }
  return list;
}

Widget templateListItem(
  String filename,
  int templateNumber,
  TemplateNotifier context,
) {
  return SizedBox(
      height: 100,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          context.setSelectedTemplate(filename, templateNumber);
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
                  context,
                ),
              ),
            ),
          ],
        ),
      ));
}
