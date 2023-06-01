import 'dart:core';

import 'package:flutter/material.dart';

///records the application processing states
class ProcessStateNotifier extends ChangeNotifier {
  static const int
      //add new processes here
      loginState = 0, // for login
      loadAssetState = 1, //for loading site assets
      loadPMFilesState =
          2, //for loading PMs from files in 'PM Verify and Upload' page
      uploadPMFilesState = 3, //for uploading PMs in 'PM Verify and Upload' page

      largestState =
          3; //the largest state int. Update this when creating new state int consts. (Could use dart:mirrors instead)

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
      {bool checkProcesses = false, bool notifyListeners = true}) {
    if (processStates.containsKey(process)) {
      processStates[process] = value;
      if (notifyListeners) {
        super.notifyListeners();
      }
      return checkProcesses ? processRunning() : true;
    }
    debugPrint("Error: process $process does not exist");
    return true;
  }
}
