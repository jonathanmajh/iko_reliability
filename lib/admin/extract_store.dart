/// Raw data extracted from Maximo for one PM pair, plus the job plans
/// linked to its route stops.
///
/// Kept free of Flutter imports so that pure Dart tooling (e.g. unit tests)
/// can use it. The notifier implementation lives in extract_notifier.dart.
class ExtractStore {
  final String siteid;
  final String pmnum;
  String status;
  String errorMessage;
  Map<String, dynamic> pm; // raw iko_pm record from Maximo
  Map<String, dynamic>? jobplan; // raw iko_jobplan record
  List<dynamic> jobtasks = []; // nested iko_jobtask rows
  List<dynamic> joblabors = []; // nested iko_joblabor rows
  List<dynamic> jobmaterials = []; // nested iko_jobmaterial rows
  List<dynamic> jobservices = []; // nested iko_jobservice rows
  Map<String, dynamic>? route; // raw iko_route record
  List<dynamic> routeStops = []; // nested iko_route_stop rows
  Map<String, FetchedJobPlan> stopJobPlans =
      {}; // job plans linked to route stops, keyed by jpnum

  ExtractStore({
    required this.siteid,
    required this.pmnum,
    this.status = 'queued',
    this.errorMessage = '',
    Map<String, dynamic>? pm,
  }) : pm = pm ?? {};

  String get key => '$siteid|$pmnum';

  String? get description =>
      pm.containsKey('description') ? pm['description']?.toString() : null;
}

/// Job plan fetched from Maximo with its nested child collections.
class FetchedJobPlan {
  final Map<String, dynamic> jobplan;
  List<dynamic> jobtasks = [];
  List<dynamic> joblabors = [];
  List<dynamic> jobmaterials = [];
  List<dynamic> jobservices = [];

  FetchedJobPlan(this.jobplan);

  String? get jpnum =>
      jobplan.containsKey('jpnum') ? jobplan['jpnum']?.toString() : null;
  String? get description => jobplan.containsKey('description')
      ? jobplan['description']?.toString()
      : null;
}
