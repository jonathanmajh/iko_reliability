import 'dart:core';

import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/settings/theme_manager.dart';
import 'package:provider/provider.dart';

///records the application processing states
class ProcessStateNotifier extends ChangeNotifier {
  static const int
      //add new processes here
      //HUST:oZUoQfjnVS
      loginState = 0, // for login
      loadAssetState = 1, //for loading site assets
      loadPMFilesState =
          2, //for loading PMs from files in 'PM Verify and Upload' page
      uploadPMFilesState = 3, //for uploading PMs in 'PM Verify and Upload' page

      largestState =
          3; //the largest state int. Update this when creating new state int consts. (Could use dart:mirrors instead)

  bool alertDialogShowing = false;

  Map<int, bool> processStates = <int, bool>{};

  ProcessStateNotifier() {
    //create all process states during initialization

    for (int processNum = 0; processNum <= largestState; processNum++) {
      processStates[processNum] = false;
    }
  }

  ///checks if an application process is running. Returns [true] if at least one process is running.
  bool processRunning() {
    for (bool value in processStates.values) {
      if (value) return true;
    }
    return false;
  }

  ///sets the process specified by [process] to [value]. Checks if any processes are running and returns that bool if [checkProcesses] is [true]. Notifies all listeners if [notifyListeners] is [true].
  bool setProcessState(int process, bool value,
      {bool checkProcesses = false,
      bool notifyListeners = true,
      bool createDialog = false,
      bool closeDialog = false,
      BuildContext? context}) {
    if (processStates.containsKey(process)) {
      if (createDialog && value) {
        if (context != null) {
          processingDialog(context);
        } else {
          throw Exception(
              'If [createDialog] is true, then [context] must be given');
        }
      }
      if (closeDialog && !value) {
        if (context != null) {
          popProcessingDialog(context);
        } else {
          throw Exception(
              'If [closeDialog] is true, the [context] must be given');
        }
      }
      processStates[process] = value;
      if (notifyListeners) {
        super.notifyListeners();
      }
      return checkProcesses ? processRunning() : true;
    }
    debugPrint("Error: process $process does not exist");
    return true;
  }

  ///checks whether app should ignore user input.
  bool absorbInput() {
    //TODO: if certain processes are running, should return [true]
    return false;
  }

  Future<void> processingDialog(BuildContext context) {
    alertDialogShowing = true;
    return showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Loading...'),
            content: CircularProgressIndicator(
              color: Colors.red, //Provider.of<ThemeData>(context).primaryColor,
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  //TODO: cancel current process
                  popProcessingDialog(context);
                },
              )
            ],
          );
        },
        barrierDismissible: false);
  }

  void popProcessingDialog(context) {
    if (alertDialogShowing) {
      Navigator.pop(context);
      alertDialogShowing = false;
    }
  }
}
