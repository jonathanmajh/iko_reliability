import 'package:flutter/material.dart';

import '../admin/consts.dart';

class SiteChangeNotifier extends ChangeNotifier {
  String selectedSite = 'NONE';

  String getSiteDescription([String? siteid]) {
    siteid ??= selectedSite;
    if (siteid == 'NONE') {
      return 'No Site Selected';
    } else {
      return 'Site ${siteIDAndDescription[siteid]!}';
    }
  }


  bool setSite(String siteID) {
    if (!siteIDAndDescription.keys.contains(siteID)) {
      return false;
    }
    selectedSite = siteID;
    notifyListeners();
    return true;
  }
}
