import 'package:auto_route/auto_route.dart';

import '../admin/asset.dart';
import '../admin/contractor.dart';
import '../admin/pm_check.dart';
import '../admin/pm_meter_update.dart';
import '../admin/timesheet.dart';
import '../criticality/asset_criticality.dart';
import '../criticality/system_criticality.dart';
import '../main.dart';
import '../test/test.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(path: "/", page: HomePage, initial: true),
    AutoRoute(path: "/test", page: MyTestPage),
    // AutoRoute(path: "/readbook", page: EpubPage),
    AutoRoute(path: "/asset", page: AssetPage),
    AutoRoute(path: "/asset/criticality", page: AssetCriticalityPage),
    AutoRoute(path: "/asset/system-criticality", page: SystemCriticalityPage),
    AutoRoute(path: "/contractor", page: ContractorPage),
    AutoRoute(path: "/pm/check", page: PmCheckPage),
    AutoRoute(path: "/pm/update-meter", page: PmMeterUpdatePage),
    AutoRoute(path: "/timesheet", page: TimesheetView),
  ],
)
class $AppRouter {}
