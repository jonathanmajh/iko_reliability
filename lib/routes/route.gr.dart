// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i10;
import 'package:flutter/material.dart' as _i11;

import '../admin/asset.dart' as _i3;
import '../admin/contractor.dart' as _i6;
import '../admin/pm_check.dart' as _i7;
import '../admin/pm_meter_update.dart' as _i8;
import '../admin/timesheet.dart' as _i9;
import '../criticality/asset_criticality.dart' as _i4;
import '../criticality/system_criticality.dart' as _i5;
import '../main.dart' as _i1;
import '../test/test.dart' as _i2;

class AppRouter extends _i10.RootStackRouter {
  AppRouter([_i11.GlobalKey<_i11.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i10.PageFactory> pagesMap = {
    HomeRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i1.HomePage(),
      );
    },
    MyTestRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i2.MyTestPage(),
      );
    },
    AssetRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i3.AssetPage(),
      );
    },
    AssetCriticalityRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i4.AssetCriticalityPage(),
      );
    },
    SystemCriticalityRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i5.SystemCriticalityPage(),
      );
    },
    ContractorRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i6.ContractorPage(),
      );
    },
    PmCheckRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i7.PmCheckPage(),
      );
    },
    PmMeterUpdateRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i8.PmMeterUpdatePage(),
      );
    },
    TimesheetView.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i9.TimesheetView(),
      );
    },
  };

  @override
  List<_i10.RouteConfig> get routes => [
        _i10.RouteConfig(
          HomeRoute.name,
          path: '/',
        ),
        _i10.RouteConfig(
          MyTestRoute.name,
          path: '/test',
        ),
        _i10.RouteConfig(
          AssetRoute.name,
          path: '/asset',
        ),
        _i10.RouteConfig(
          AssetCriticalityRoute.name,
          path: '/asset/criticality',
        ),
        _i10.RouteConfig(
          SystemCriticalityRoute.name,
          path: '/asset/system-criticality',
        ),
        _i10.RouteConfig(
          ContractorRoute.name,
          path: '/contractor',
        ),
        _i10.RouteConfig(
          PmCheckRoute.name,
          path: '/pm/check',
        ),
        _i10.RouteConfig(
          PmMeterUpdateRoute.name,
          path: '/pm/update-meter',
        ),
        _i10.RouteConfig(
          TimesheetView.name,
          path: '/timesheet',
        ),
      ];
}

/// generated route for
/// [_i1.HomePage]
class HomeRoute extends _i10.PageRouteInfo<void> {
  const HomeRoute()
      : super(
          HomeRoute.name,
          path: '/',
        );

  static const String name = 'HomeRoute';
}

/// generated route for
/// [_i2.MyTestPage]
class MyTestRoute extends _i10.PageRouteInfo<void> {
  const MyTestRoute()
      : super(
          MyTestRoute.name,
          path: '/test',
        );

  static const String name = 'MyTestRoute';
}

/// generated route for
/// [_i3.AssetPage]
class AssetRoute extends _i10.PageRouteInfo<void> {
  const AssetRoute()
      : super(
          AssetRoute.name,
          path: '/asset',
        );

  static const String name = 'AssetRoute';
}

/// generated route for
/// [_i4.AssetCriticalityPage]
class AssetCriticalityRoute extends _i10.PageRouteInfo<void> {
  const AssetCriticalityRoute()
      : super(
          AssetCriticalityRoute.name,
          path: '/asset/criticality',
        );

  static const String name = 'AssetCriticalityRoute';
}

/// generated route for
/// [_i5.SystemCriticalityPage]
class SystemCriticalityRoute extends _i10.PageRouteInfo<void> {
  const SystemCriticalityRoute()
      : super(
          SystemCriticalityRoute.name,
          path: '/asset/system-criticality',
        );

  static const String name = 'SystemCriticalityRoute';
}

/// generated route for
/// [_i6.ContractorPage]
class ContractorRoute extends _i10.PageRouteInfo<void> {
  const ContractorRoute()
      : super(
          ContractorRoute.name,
          path: '/contractor',
        );

  static const String name = 'ContractorRoute';
}

/// generated route for
/// [_i7.PmCheckPage]
class PmCheckRoute extends _i10.PageRouteInfo<void> {
  const PmCheckRoute()
      : super(
          PmCheckRoute.name,
          path: '/pm/check',
        );

  static const String name = 'PmCheckRoute';
}

/// generated route for
/// [_i8.PmMeterUpdatePage]
class PmMeterUpdateRoute extends _i10.PageRouteInfo<void> {
  const PmMeterUpdateRoute()
      : super(
          PmMeterUpdateRoute.name,
          path: '/pm/update-meter',
        );

  static const String name = 'PmMeterUpdateRoute';
}

/// generated route for
/// [_i9.TimesheetView]
class TimesheetView extends _i10.PageRouteInfo<void> {
  const TimesheetView()
      : super(
          TimesheetView.name,
          path: '/timesheet',
        );

  static const String name = 'TimesheetView';
}
