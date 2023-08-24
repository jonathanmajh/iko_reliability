import 'package:flutter/material.dart';

import '../admin/consts.dart';

class SiteChangeNotifier extends ChangeNotifier {
  String selectedSite = 'NONE';

  bool setSite(String siteID) {
    if (!siteIDAndDescription.keys.contains(siteID)) {
      return false;
    }
    selectedSite = siteID;
    notifyListeners();
    return true;
  }
}
