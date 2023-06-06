import 'dart:core';
import 'dart:io';

import 'consts.dart';
import 'package:flutter/material.dart';
import 'package:iko_reliability_flutter/settings/theme_manager.dart';
import 'package:provider/provider.dart';

///records the application processing states
class ProcessStateNotifier extends ChangeNotifier {

  Map<int, bool> processStates = <int, bool>{};

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

  void popProcessingDialog(context) {
    if (alertDialogShowing) {
      Navigator.pop(context);
      alertDialogShowing = false;
    }
  }
}
