//functions for saving data to files
import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

import '../admin/generate_uploads.dart';
import 'package:csv/csv.dart';

import '../main.dart';

///Saves string contents into a file selected by the user. Shows a file picker dialog.
///Returns [true] if file is saved, [false] if canceled, and an exception object if there was an error.
///Saves file in utf-8 with BOM encoding
///
///[contents] - String contents of the file
///[allowedExtentions] - list of allowed file extensions to save as
Future<dynamic> saveFileFromString(String contents,
    {List<String>? allowedExtensions, BuildContext? context}) async {
  try {
    String? savePath;
    String? fileName;
    do {
      savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save As',
        lockParentWindow: true,
        type: (allowedExtensions != null) ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        fileName: fileName ??
            ((allowedExtensions != null && allowedExtensions.isNotEmpty)
                ? '.${allowedExtensions.first}'
                : ''),
      );
      if (savePath == null) {
        return false;
      }
      //check file type
      if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
        int indexOfLastBackslash = savePath.lastIndexOf('\\');
        int indexOfLastPeriod = savePath.lastIndexOf(".");
        if (indexOfLastPeriod > indexOfLastBackslash) {
          if (!allowedExtensions
              .contains(savePath.substring(indexOfLastPeriod + 1))) {
            fileName = savePath.substring(indexOfLastBackslash + 1);
            debugPrint('File type not supported');
            if (context != null) {
              await showDialog(
                  context: navigatorKey.currentContext!,
                  builder: (context) => AlertDialog(
                        title: const Text('Unsupported File Type'),
                        content: Text(
                            'File extension must be one of the following:\n\t$allowedExtensions\nTry again.'),
                        actions: [
                          ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Ok'))
                        ],
                      ));
            }
          } else {
            fileName = null;
          }
        } else {
          savePath += '.${allowedExtensions.first}';
          fileName = null;
        }
      }
      //repeat filepicker if improper file type given
    } while (fileName != null);
    //add BOM header
    await File(savePath)
        .writeAsBytes([239, 187, 191, ...utf8.encode(contents)]);
    return true;
  } catch (e) {
    return e;
  }
}

///Handles saving the data from the AssetCriticality Trinagrid into a csv file.
Future<void> exportAssetCriticalityAsCSV(
    {required TrinaGridStateManager stateManager,
    required BuildContext context}) async {
  String contents = const ListToCsvConverter().convert(generateTrinagrid(
      stateManager,
      excludeFields: const ['hierarchy', 'action']));
  saveFileFromString(contents, allowedExtensions: ['csv'], context: context)
      .then((result) {
    if (result.runtimeType == FileSystemException) {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Could not save file'),
                  content: Text(result
                      .toString()
                      .substring(result.toString().indexOf(' ') + 1)),
                  actions: [
                    Center(
                      child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Ok')),
                    )
                  ],
                ));
      }
    } else if (result == true) {
      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Save Complete'),
                  actions: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Ok'),
                      ),
                    )
                  ],
                ));
      }
    }
  });
}
