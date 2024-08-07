import "dart:math";

import '../bin/db_drift.dart';

///Function/Equation to calculate risk priority number (RPN)
///Currently just a product between all parameters
///returns -1 if any parameter is null
double? rpnFunc(AssetCriticalityWithAsset asset) {
  try {
    return asset.systemCriticality!.score *
        asset.assetCriticality!.frequency *
        (1 - asset.assetCriticality!.earlyDetection) *
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

int ratingFromValue(double value, Map<int, Map<String, dynamic>> definition) {
  if (value == -1) {
    return 0;
  }
  for (var i = 1; i < 11; i++) {
    if (value < definition[i]!['high']!) {
      return i;
    }
  }
  return 1;
}

///To calculate the system score for an asset.
///Uses the root mean squared (RMS) of the asset's ratings of safety, regulatory, economic, throughput, and quality.
///Economic and quality values are integers from 1-5, while the rest are between 1-10.
///System score is used to calculate risk priority number (RPN)
double calculateSystemScore(List<int> ratings) {
  if (ratings.length != 5) {
    throw Exception(
        'Error in parameter [ratings] for function [calculateSystemScore]. Must have a length of 5');
  }
  num sum2 = 0;
  for (int rating in ratings) {
    sum2 += pow(rating, 2);
  }
  return sqrt(sum2 / ratings.length);
}

///returns the sum of all distributions. Should be equal to 100
int calculateTotal(List<int> dists) {
  int sum = 0;
  for (int dist in dists) {
    sum += dist;
  }
  return sum;
}
