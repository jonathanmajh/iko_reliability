import 'package:flutter/material.dart';

Widget templateDescription(
  String filename,
  int templateNumber,
  String pmName,
  String pmNumber,
  String status,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              pmNumber,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              pmName,
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
            statusIndicator(status),
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
