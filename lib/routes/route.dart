import 'package:auto_route/auto_route.dart';
import 'package:iko_reliability_flutter/home_page.dart';

import '../admin/timesheet.dart';
import '../creation/asset.dart';
import '../admin/contractor.dart';
import '../admin/pm_check.dart';
import '../admin/pm_meter_update.dart';
import '../criticality/asset_criticality.dart';
import '../criticality/spare_criticality.dart';
import '../criticality/system_criticality.dart';

part 'route.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  // @override
  // RouteType get defaultRouteType => RouteType.material(); //.cupertino, .adaptive ..etc
  AppRouter({super.navigatorKey});

  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: "/", page: HomeRoute.page, initial: true),
        // AutoRoute(path: "/test", page: MyTestPage),
        // AutoRoute(path: "/readbook", page: EpubPage),
        AutoRoute(path: "/asset", page: AssetRoute.page),
        AutoRoute(path: "/criticality/asset", page: AssetCriticalityRoute.page),
        AutoRoute(
            path: "/criticality/system", page: SystemCriticalityRoute.page),
        AutoRoute(path: "/contractor", page: ContractorRoute.page),
        AutoRoute(path: "/pm/check", page: PmCheckRoute.page),
        AutoRoute(path: "/pm/update-meter", page: PmMeterUpdateRoute.page),
        AutoRoute(path: '/criticality/spare', page: SpareCriticalityRoute.page),
        AutoRoute(path: "/timesheet", page: TimesheetRoute.page),
      ];
}
