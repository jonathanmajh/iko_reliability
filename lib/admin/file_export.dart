//functions for saving data to files
import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'generate_uploads.dart';
import 'package:csv/csv.dart';

///Saves string contents into a file selected by the user. Shows a file picker dialog.
///Returns [true] if file is saved, [false] if canceled, and an exception object if there was an error.
///Saves file in utf-8 with BOM encoding
///
///[contents] - String contents of the file
///[allowedExtentions] - list of allowed file extensions to save as
Future<dynamic> saveFileFromString(String contents,
    {List<String>? allowedExtensions}) async {
  try {
    String? savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save As',
      lockParentWindow: true,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      fileName: '',
    );
    if (savePath == null) {
      return false;
    }
    //add BOM header
    await File(savePath)
        .writeAsBytes([239, 187, 191, ...utf8.encode(contents)]);
    return true;
  } catch (e) {
    print(e.runtimeType);
    return e;
  }
}

///Handles saving the data from the AssetCriticality plutogrid into a csv file.
Future<void> exportAssetCriticalityAsCSV(
    {required PlutoGridStateManager stateManager,
    required BuildContext context}) async {
  String contents = const ListToCsvConverter().convert(generatePlutogrid(
      stateManager,
      excludeFields: const ['hierarchy', 'action']));
  saveFileFromString(contents, allowedExtensions: ['csv']).then((result) {
    if (result.runtimeType == FileSystemException) {
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
    } else if (result == true) {
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
  });
}
