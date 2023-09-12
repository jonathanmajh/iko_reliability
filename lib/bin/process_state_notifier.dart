import 'dart:core';

import 'consts.dart';
import 'package:flutter/material.dart';

//TODO: listen to more processes and set it so that application shows a warning when user tries to close
// app while processes are still running. Also to show undismissible dialog windows to prevent user
// input from messing with the processes.

///records the application processing states
class ProcessStateNotifier extends ChangeNotifier {
  ///Map of the currently running processes where the index of the ProcessStates are the keys
  Map<int, bool> processStates = <int, bool>{};

  ///If the processing dialog is currently open
  bool alertDialogShowing = false;

  ProcessStateNotifier() {
    //create all process states during initialization

    for (ProcessStates process in ProcessStates.values) {
      processStates[process.index] = false;
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
  bool setProcessState(ProcessStates process, bool value,
      {bool checkProcesses = false, bool notifyListeners = true}) {
    if (processStates.containsKey(process.index)) {
      processStates[process.index] = value;
      if (notifyListeners) {
        super.notifyListeners();
      }
      return checkProcesses ? processRunning() : true;
    }
    debugPrint("Error: process $process does not exist");
    return true;
  }

  ///Creates a dialog to show that the app is processing. Allows user to cancel processes
  ///and ignores user attempts to change data during processes
  Future<void> processingDialog(BuildContext context) {
    alertDialogShowing = true;
    return showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Loading...'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
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

  ///Closes the Processing dialog
  void popProcessingDialog(context) {
    if (alertDialogShowing) {
      Navigator.pop(context);
      alertDialogShowing = false;
    }
  }
}
