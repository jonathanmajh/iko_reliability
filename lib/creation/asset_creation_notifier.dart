import 'package:flutter/material.dart';

import '../admin/consts.dart';

class AssetCreationNotifier extends ChangeNotifier {
  String selectedSite = 'NONE';

  void setSite(String site) {
    selectedSite = site;
    notifyListeners();
  }

  static String getSiteDescription(String siteid) {
    if (siteid == 'NONE') {
      return 'Select a site';
    } else {
      return siteIDAndDescription[siteid]!;
    }
  }
}