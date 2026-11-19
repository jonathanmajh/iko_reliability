import 'package:flutter/foundation.dart';

/// ChangeNotifier for the current Maximo server/environment selection.
class MaximoServerNotifier extends ChangeNotifier {
  // The currently selected Maximo server.
  String maximoServerSelected = 'PROD';

  /// Sets the selected Maximo server and notifies listeners.
  void setServer(String server) {
    maximoServerSelected = server;
    notifyListeners();
  }
}
