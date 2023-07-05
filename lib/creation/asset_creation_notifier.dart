import 'package:flutter/material.dart';

import '../admin/consts.dart';

class AssetCreationNotifier extends ChangeNotifier {
  String selectedSite = 'NONE';

  Set<String> loading = {};

  void setSite(String site) {
    selectedSite = site;
    notifyListeners();
  }

  void addLoading(String string){
    loading.add(string);
    notifyListeners();
  }

  void removingLoading(String string){
    loading.remove(string);
    notifyListeners();
  }

  void clearLoading(){
    loading.clear();
    notifyListeners();
  }

  /*Future<bool> uploadAsset(String assetNum) async{
    
  }*/

  static String getSiteDescription(String siteid) {
    if (siteid == 'NONE') {
      return 'Select a site';
    } else {
      return siteIDAndDescription[siteid]!;
    }
  }
}
