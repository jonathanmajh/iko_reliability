import 'upload_maximo.dart';

class AssetMeterMaximo {
  final String assetNumber;
  final String meter;

  const AssetMeterMaximo({
    required this.assetNumber,
    required this.meter,
  });
}

class JobPlanMeterCheckMaximo {
  final String orgid;
  final String siteid;
  final String metername;
  final String jpnum;
  final String jptask;
  final String description;
  final String details;
  final String worktype;
  final String assetnum;

  const JobPlanMeterCheckMaximo({
    required this.orgid,
    required this.siteid,
    required this.metername,
    required this.jpnum,
    required this.jptask,
    required this.description,
    required this.details,
    required this.worktype,
    required this.assetnum,
  });
}

Future<List<JobPlanMeterCheckMaximo>> getJobtasks(
    String meterName, String env) async {
  final url = 'IKO_JOBTASK_METER?metername=$meterName';
  final result = await maximoRequest(url, 'api', env);
  List<JobPlanMeterCheckMaximo> list = [];
  if (!result.containsKey('jobtasks')) {
    return list;
  }
  for (final jobtask in result['jobtasks']) {
    list.add(JobPlanMeterCheckMaximo(
      orgid: jobtask['orgid'],
      siteid: jobtask['siteid'],
      metername: jobtask['metername'],
      jpnum: jobtask['jpnum'],
      jptask: jobtask['jptask'],
      description: jobtask['description'],
      details: jobtask['details'],
      worktype: jobtask['worktype'],
      assetnum: jobtask['assetnum'],
    ));
  }
  return list;
}

List<String> assetMeterPairs(
    List<JobPlanMeterCheckMaximo> jobplans, String meterName) {
  List<String> result = [];
  for (final jobplan in jobplans) {
    final meterCount =
        jobplan.metername.substring(jobplan.metername.length - 2);
    final pair = '${jobplan.assetnum}$meterName$meterCount';
    result.add(pair);
  }
  return result;
}
