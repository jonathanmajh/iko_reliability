import 'package:flutter/material.dart';

import '../admin/consts.dart';

///ChangeNotifier for data in AssetCriticalityPage
class AssetCriticalityNotifier extends ChangeNotifier {
  List<double> rpnList = [];
  String selectedSite = 'NONE';

  ///sets [selectedSite] to [site]. Notifies listeners
  void setSite(String site) {
    selectedSite = site;
    notifyListeners();
  }

  ///sets [rpnList] to a copy of [newList]. Notifies listeners
  void setRpnList(List<double> newList) {
    rpnList = List.of(newList);
    notifyListeners();
  }

  ///adds [appendList] to the end of [rpnList]. Notifies Listeners
  void addToRpnList(List<double> appendList) {
    rpnList.addAll(appendList);
    notifyListeners();
  }

  ///gets the site description from a siteid.
  ///Necessary b/c additional 'entry' of {'NONE': 'Select a site'} is needed, not just [siteIDAndDescription]
  static String getSiteDescription(String siteid) {
    if (siteid == 'NONE') {
      return 'Select a site';
    } else {
      return siteIDAndDescription[siteid]!;
    }
  }
}
