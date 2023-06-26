import "dart:math";

///Function/Equation to calculate risk priority number (RPN)
///Currently just a product between all parameters
///returns null if any parameter is null
double? rpnFunc(double? system, int? freq, int? impact) {
  try {
    return system! * freq! * impact!;
  } catch (e) {
    print('error: ${e.toString()}');
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
