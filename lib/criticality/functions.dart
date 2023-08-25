import "dart:math";

import "../admin/db_drift.dart";

///Function/Equation to calculate risk priority number (RPN)
///Currently just a product between all parameters
///returns -1 if any parameter is null
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

int ratingFromValue(double value, Map<int, Map<String, dynamic>> definition) {
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

///returns a list of rpn maximum values (inclusive) for rpn assessments (e.g. very low, medium, high, etc) in order to have the
///closest percent distribution to that listed in {rpnPercentDist}
///Params:
/// - rpnList: list of all the rpns (without 0 or -1 values)
/// - rpnPercentDist: desired rpn percent distribution in rpn assessments. Listed from least serious (very low) to most serious (very high)
/// - tolerance: a percentage. if the difference between the desired and actual percent distribution is greater than the tolerance, use a different distribution
/// Returns list of rpn maximum values for each distribution range, from very low to very high
List<double> calculateRPNDistRange(
    List<double> rpnList, List<int> rpnPercentDist,
    {double tolerance = 10}) {
  /* 
  duplicates must be found as consider the following example:
    say the rpns are [1, 2, 3, 3, 3, 4, 5, 6, 7, 8] and we want to get 30% dist for very low.
    index = rpns.length * 30% - 1 = 2, so the cutoff point should be at rpn = rpns[2] = 3
    however, since there are duplicates of the cutoff point, the actual cutoff point will be at index = 4
    hence the distrubution will be 50%.
    if we set rpn = 2 as the cutoff point, the distrubution will be 20%, which is closer to 30% than 50% is
  */

  ///searches for duplicates of the item at index a in an ordered list.
  ///returns a List<int> of length 2 of the indicies of the furthest duplicate of item at index. result = [first, last]
  ///recursive(ish) function (don't use optional param {searchDownwardsThruList} when calling)
  dynamic searchForDuplicate(List orderedRpnList, int index,
      {bool? searchDownwardsThruList}) {
    if (searchDownwardsThruList == null) {
      return <int>[
        searchForDuplicate(orderedRpnList, index - 1,
            searchDownwardsThruList: true),
        searchForDuplicate(orderedRpnList, index - 1,
            searchDownwardsThruList: false)
      ];
      //recursive conditions
    } else if (searchDownwardsThruList) {
      try {
        if (orderedRpnList[index] == orderedRpnList[index + 1]) {
          return (searchForDuplicate(orderedRpnList, index - 1,
              searchDownwardsThruList: true));
        } else {
          return index + 1;
        }
      } catch (e) {
        return index + 1;
      }
    } else {
      try {
        if (orderedRpnList[index] == orderedRpnList[index - 1]) {
          return (searchForDuplicate(orderedRpnList, index + 1,
              searchDownwardsThruList: false));
        } else {
          return index - 1;
        }
      } catch (e) {
        return index - 1;
      }
    }
  }

  List<double> percentDist = List.from(rpnPercentDist
      .map((i) => i.toDouble())
      .toList()
      .reversed); //order list from highest to lowest priority. Will process from lowest to highest, but Dart only has list.removeLast
  List<double> list = List<double>.of(rpnList); //copy the ordered rpn list.
  list.sort((a, b) => b.compareTo(
      a)); //reversed (highest to lowest) for now, to use List.removelast. Since ordered, should be more efficient than removeWhere()
  while (list.isNotEmpty && list.last <= 0) {
    //remove all not yet calculated rpns
    list.removeLast();
  }
  if (Set.from(list).length < 5) {
    throw Exception(
        'Need at least 5 distinct RPNs to calculate distributions. Currently have ${Set.from(list).length} distinct RPN values.');
  }
  list = List.from(list.reversed); //reverse the list back to lowest to highest
  List<double> rangeDist = [];
  double diff = 100000.01; //some large number
  double targetDist = 0;

  while (percentDist.length > 1) {
    targetDist += percentDist.removeLast();
    //get supposed index position of the cutoff RPN in [list]
    int index = (list.length * targetDist / 100).round() - 1;
    //check for duplicates of the value at i
    List<int> duplicates = searchForDuplicate(list, index);
    if (duplicates[0] == index && duplicates[1] == index) {
      //no duplicates, list[index] is cutoff RPN for current dist
      //calculate the difference between ideal percent distribution and actual
      diff = targetDist - ((list.length - index - 1) / list.length * 100);
    } else {
      //duplicates exist, three possible cutoff RPNs: RPN at list[index], the RPN right before it, and the RPN after it. Use whatever results in percent distribution closer to [targetDist]
      int? indexDwn = (duplicates[0] - 1) >= 0
          ? searchForDuplicate(list, duplicates[0] - 1)[0]
          : null; //lower index on list, RPN right above list[index]. Note that list is from greatest to least. Must account for dupes
      int indexMid = duplicates[0];
      int? indexUp =
          (duplicates[1] + 1) < list.length ? (duplicates[1] + 1) : null;

      if (indexDwn != null) {
        index = indexDwn;
        diff = targetDist - ((index + 1) / list.length * 100);
      }
      if (indexUp != null) {
        double tempDiff = targetDist - ((indexUp + 1) / list.length * 100);
        if (tempDiff.abs() < diff.abs()) {
          diff = tempDiff;
          index = indexUp;
        }
      }
      double tempDiff = targetDist - ((indexMid + 1) / list.length * 100);
      if (tempDiff.abs() < diff.abs()) {
        diff = tempDiff;
        index = indexMid;
      }
    }
    if (diff.abs() > tolerance) {
      //when actual percent distripution becomes way off
      throw Exception(
          'RPN values cannot fit specified distribution. Tolerance $tolerance% exceeded.\nEnsure RPN numbers are spreadout. Diff: ${diff.toInt()}%, RPN: ${list[index]}, Target: ${targetDist.toInt()}%');
    }

    //add to cutoff RPN to [rangeDist]
    rangeDist.add(list[index]);
    //modify the remaining percent distributions with the difference
    for (int i = 0; i < percentDist.length; i++) {
      percentDist[i] += diff / (percentDist.length);
    }
  }

  //make highest priority cutoff RPN include all RPNs
  rangeDist.add(list.last);

  //cannot have duplicates in [rangeDist]
  if (Set.from(rangeDist).length != rangeDist.length) {
    throw Exception(
        'Duplicate values in [rangeDist]. rangeDist = \n$rangeDist');
  }
  return rangeDist;
}

///returns the sum of all distributions. Should be equal to 100
int calculateTotal(List<int> dists) {
  int sum = 0;
  for (int dist in dists) {
    sum += dist;
  }
  return sum;
}
