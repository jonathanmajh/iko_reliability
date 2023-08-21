import "dart:math";

import "../admin/db_drift.dart";

///Function/Equation to calculate risk priority number (RPN)
///Currently just a product between all parameters
///returns null if any parameter is null
double? rpnFunc(AssetCriticalityWithAsset asset) {
  try {
    double system = sqrt(
        (asset.systemCriticality!.safety * asset.systemCriticality!.safety +
                asset.systemCriticality!.regulatory *
                    asset.systemCriticality!.regulatory +
                asset.systemCriticality!.economic *
                    asset.systemCriticality!.economic +
                asset.systemCriticality!.throughput *
                    asset.systemCriticality!.throughput +
                asset.systemCriticality!.quality *
                    asset.systemCriticality!.quality) /
            5);
    return system *
        asset.assetCriticality!.frequency *
        asset.assetCriticality!.downtime;
  } catch (e) {
    return -1;
  }
}

///Function/Equation to calculate the score of a system.
///Just the root mean square between all parameters
double systemScoreFunc(int safety, int regulatory, int economic, int throughput,
        int quality) =>
    sqrt((safety * safety +
            regulatory * regulatory +
            economic * economic +
            throughput * throughput +
            quality * quality) /
        5);
