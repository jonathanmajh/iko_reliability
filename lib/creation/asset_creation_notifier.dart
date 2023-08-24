import 'package:flutter/material.dart';
import '../admin/upload_maximo.dart';

import '../admin/db_drift.dart';
import '../main.dart';

class AssetCreationNotifier extends ChangeNotifier {
  String selectedSite = 'NONE';

  Map<String, AssetWithUpload> siteAssets = {};
  Map<String, String> pendingAssets = {};
  Map<String, String> failedAssets = {};
  Map<String, List<Asset>> parentAssets = {};

  Future<void> setSite(String site, [bool notify = true]) async {
    if (site == 'NONE') {
      return;
    }

    siteAssets.clear();
    parentAssets.clear();
    pendingAssets.clear();

    final dbrows = await database!
        .getSiteAssetUploads(site); //todo make it able to load other sites
    for (var row in dbrows) {
      if (row.asset.newAsset == 1) {
        pendingAssets[row.asset.assetnum] = 'new';
      } else if (row.asset.newAsset == -1) {
        pendingAssets[row.asset.assetnum] = 'fail';
      }
      siteAssets[row.asset.assetnum] = row;
      if (parentAssets.containsKey(row.asset.parent ?? 'Top')) {
        parentAssets[row.asset.parent ?? 'Top']!.add(row.asset);
      } else {
        parentAssets[row.asset.parent ?? "Top"] = [row.asset];
      }
    }

    selectedSite = site;

    if (notify) {
      notifyListeners();
    }

    return;
  }

  Future<String> addAsset(
    String assetNum,
    String description,
    String parent, {
    String? site,
    String? sjpDescription,
    String? installationDate,
    String? vendor,
    String? manufacturer,
    String? modelNum,
    int? assetCriticality,
  }) async {
    if (siteAssets.containsKey(assetNum)) {
      throw ('Upload Fail! Asset $assetNum already exists');
    }

    print('adding asset');
    var id = await database!.addNewAsset(
      assetNum,
      (site ?? selectedSite),
      description,
      parent,
      sjpDescription,
      installationDate,
      vendor,
      manufacturer,
      modelNum,
      assetCriticality,
    );

    var newAsset = await database!.getAsset(site ?? selectedSite, assetNum);

    siteAssets[assetNum] = id;
    pendingAssets[assetNum] = 'new';

    if (!parentAssets.containsKey(parent)) {
      parentAssets[parent] = [];
    }

    parentAssets[parent]!.add(newAsset);

    print('done adding asset');
    notifyListeners();
    return id.asset.assetnum;
  }

  Future<String> deleteAsset(String assetNum, String site) async {
    if (!siteAssets.containsKey(assetNum)) {
      throw 'Asset $assetNum does not exist';
    }
    if (parentAssets.containsKey(assetNum)) {
      throw 'Asset $assetNum has children';
    }
    if (siteAssets[assetNum]!.asset.newAsset == 0) {
      //TODO: != 1?
      throw 'Asset already exists in Maximo, cannot delete';
    }

    pendingAssets.remove(assetNum);

    var parent = siteAssets[assetNum]!.asset.parent;
    parentAssets[parent]!.remove(siteAssets[assetNum]!);
    if (parentAssets[parent]!.isEmpty) {
      parentAssets.remove(parent);
    }
    siteAssets.remove(assetNum);

    var id = await database!.deleteAsset(assetNum, site);
    return id;
  }

  Set<String> getChildAssetnums(String assetnum) {
    List<Asset>? directChilds = parentAssets[assetnum];

    //exit condition

    if (directChilds == null || directChilds.isEmpty) {
      return <String>{};
    }

    Set<String> childSet = {};

    for (Asset child in directChilds) {
      childSet.add(child.assetnum);
      childSet.addAll(getChildAssetnums(child.assetnum));
    }

    return childSet;
  }

  Future<void> uploadAssets(String env) async {
    if (pendingAssets.isEmpty) {
      return;
    }
    for (var entry in pendingAssets.entries) {
      var assetNum = entry.key;

      if (entry.value == 'success' || entry.value == 'duplicate') {
        continue;
      }

      try {
        pendingAssets[assetNum] = 'pending';
        notifyListeners();
        print('something');
        var result =
            await uploadAssetToMaximo(siteAssets[assetNum]!, env, this);
        var assetcheck = await database!.getAsset(selectedSite, assetNum);
        print(assetcheck.toString());
        if (result['result'] == 'success') {
          pendingAssets[assetNum] = 'success';
          await database!.setAssetStatus(assetNum, selectedSite, 0);
        } else if (result['result'] == 'duplicate') {
          pendingAssets[assetNum] = 'duplicate';
          await database!.setAssetStatus(assetNum, selectedSite, 0);
        }
        assetcheck = await database!.getAsset(selectedSite, assetNum);
        print(assetcheck.toString());
        failedAssets.remove(assetNum);
        notifyListeners();
        continue;
      } on List catch (e) {
        //e[0] is the error message (e.g. invalid request) while e[1] is a map which allows you to see exactly which part of the upload failed
        print(e[0]); //Print warning msg

        var result = e[1];
        var error = result['postResponse'] == 'null'
            ? 'Preview mode on'
            : '${result['failReason']}: ${result['postResponse']['warningmsg'].replaceAll('\n', '')}';
        failedAssets[assetNum] = error;
        pendingAssets[assetNum] = 'warning';
        await database!.setAssetStatus(assetNum, selectedSite, -1);
        print(error);

        notifyListeners();
        continue;
      } catch (e) {
        print(e);
        pendingAssets[assetNum] = 'fail';
        notifyListeners();
        continue;
      }
    }
    //notifyListeners();
  }
}
