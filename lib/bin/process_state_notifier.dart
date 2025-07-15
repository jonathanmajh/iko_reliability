import 'dart:core';
import 'package:flutter/material.dart';

/// Notifier for tracking and managing application processing states and database tasks.
class ProcessStateNotifier extends ChangeNotifier {
  ///Map of the currently running processes where the index of the ProcessStates are the keys
  List<String> processStates = [];

  ///If the processing dialog is currently open
  bool alertDialogShowing = false;

  ProcessStateNotifier();

  void addTask(String taskName) {
    processStates.add(taskName);
    notifyListeners();
  }

  void removeTask(String taskName) {
    processStates.remove(taskName);
    notifyListeners();
  }

  ///checks if an application process is running. Returns [true] if at least one process is running.
  bool processRunning() {
    if (processStates.isNotEmpty) return true;
    return false;
  }
}
