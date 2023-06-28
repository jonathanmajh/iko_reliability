import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../admin/consts.dart';

///ChangeNotifier for data in AssetCriticalityPage
class AssetCriticalityNotifier extends ChangeNotifier {
  //TODO: handle plutogrid hide/close toggle
  ///Map where the keys are the plutogrid row and the values are the rpns
  Map<int, double> rpnMap = {};
  List<double> rpnCutoffs = [];
  String selectedSite = 'NONE';
  bool priorityRangesUpToDate = true;
  PlutoGridStateManager? stateManager;

  ///list of rpns. Not ordered
  List<double> get rpnList => List<double>.of(rpnMap.values);

  ///sets [selectedSite] to [site]. Notifies listeners
  void setSite(String site) {
    selectedSite = site;
    notifyListeners();
  }

  ///sets [rpnMap] to a copy of [newMap]. Notifies listeners
  void setRpnMap(Map<int, double> newMap, {bool notify = true}) {
    rpnMap = Map<int, double>.of(newMap);
    if (notify) notifyListeners();
  }

  ///adds [appendMap] to [rpnMap]. Notifies Listeners
  void addToRpnMap(Map<int, double> appendMap, {bool notify = true}) {
    rpnMap.addAll(appendMap);
    if (notify) notifyListeners();
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

  void setRpnCutoffs(List<double> newCutoffs) {
    rpnCutoffs = List.of(newCutoffs);
    notifyListeners();
  }

  ///finds the risk priority for a given rpn
  String rpnFindDistribution(double rpn) {
    try {
      if (rpnCutoffs.length != 5) {
        throw Exception('Unexpected format for List [rpnCutoffs]');
      }
      if (rpn <= 0) throw Exception('Negative RPN');
      for (int i = 0; i < rpnPossibleDistributions.length; i++) {
        if (rpn <= rpnCutoffs[i]) return rpnPossibleDistributions[i];
      }
      debugPrint('[rpnFindDistribution] overflow');
      return rpnPossibleDistributions[4];
    } catch (e) {
      return '---';
    }
  }
}
