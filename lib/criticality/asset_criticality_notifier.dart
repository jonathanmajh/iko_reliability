import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../admin/consts.dart';

///ChangeNotifier for data in AssetCriticalityPage
class AssetCriticalityNotifier extends ChangeNotifier {
  ///Map where the keys are the plutogrid row and the values are the rpns
  Map<String, double> rpnMap = {};

  ///List of cutoff rpns for priorites from very low to very high
  List<double> rpnCutoffs = [];

  ///The id of the currently viewed site on the plutogrid
  String selectedSite = 'NONE';

  ///flag if the priority ranges are up to date. Used to show warnings when exporting
  bool priorityRangesUpToDate = true;

  ///the stateManager of the main plutogrid
  PlutoGridStateManager? stateManager;

  ///Set of the siteids of the currently collapsed assets
  Set<String> collapsedAssets = {};

  ///list of rpns. Not ordered
  List<double> get rpnList => List<double>.of(rpnMap.values);

  ///upper bound for work order dates filter in asset criticality (inclusive). null if no filter
  DateTime? beforeDate;

  /////lower bound for work order dates filter in asset criticality (inclusive)
  DateTime? afterDate;

  ///whether to use beforeDate filter
  bool? usingBeforeDate;

  ///whether to used afterDate filter
  bool? usingAfterDate;

  ///whether to show all sites' work orders or not
  bool? showAllSites;

  ///whether to reload the grid
  bool updateGrid = false;

  ///sets [selectedSite] to [site]. Notifies listeners
  void setSite(String site) {
    selectedSite = site;
    collapsedAssets = {};
    notifyListeners();
  }

  ///sets [rpnMap] to a copy of [newMap]. Notifies listeners
  void setRpnMap(Map<String, double> newMap, {bool notify = true}) {
    rpnMap = Map<String, double>.of(newMap);
    if (notify) notifyListeners();
  }

  ///adds [appendMap] to [rpnMap]. Notifies Listeners
  void addToRpnMap(Map<String, double> appendMap, {bool notify = true}) {
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

  ///sets the rpnCutoffs to the [newCutoffs] and notifies listeners
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

  ///updates the Set of collapsed assets
  void updateCollapsedAssets(PlutoGridStateManager stateManager) {
    Set<String> newCollapsedAssets = {};
    for (PlutoRow row in stateManager.rows) {
      if (!stateManager.isExpandedGroupedRow(row)) {
        newCollapsedAssets.add(row.cells['assetnum']!.value);
      }
    }
    collapsedAssets = newCollapsedAssets;
  }

  ///check if the PlutoRow of an asset is collapsed
  bool assetIsCollapsed(String assetnum) {
    return !collapsedAssets.contains(assetnum);
  }

  ///function to set the work order settings
  void setWOSettings({
    required DateTime? beforeDate,
    required DateTime? afterDate,
    required bool usingBeforeDate,
    required bool usingAfterDate,
    required bool showAllSites,
    bool notify = true,
  }) {
    this.beforeDate = beforeDate;
    this.afterDate = afterDate;
    this.usingBeforeDate = usingBeforeDate;
    this.usingAfterDate = usingAfterDate;
    this.showAllSites = showAllSites;

    if (notify) notifyListeners();
  }
}
