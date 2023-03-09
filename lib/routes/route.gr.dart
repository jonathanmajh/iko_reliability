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
import 'package:auto_route/auto_route.dart' as _i8;
import 'package:flutter/material.dart' as _i9;

import '../admin/asset.dart' as _i3;
import '../admin/contractor.dart' as _i5;
import '../admin/pm_check.dart' as _i6;
import '../admin/pm_meter_update.dart' as _i7;
import '../criticality/asset_criticality.dart' as _i4;
import '../main.dart' as _i1;
import '../test/test.dart' as _i2;

class AppRouter extends _i8.RootStackRouter {
  AppRouter([_i9.GlobalKey<_i9.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i8.PageFactory> pagesMap = {
    HomeRoute.name: (routeData) {
      return _i8.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i1.HomePage(),
      );
    },
    MyTestRoute.name: (routeData) {
      return _i8.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i2.MyTestPage(),
      );
    },
    AssetRoute.name: (routeData) {
      return _i8.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i3.AssetPage(),
      );
    },
    AssetCriticalityRoute.name: (routeData) {
      return _i8.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i4.AssetCriticalityPage(),
      );
    },
    ContractorRoute.name: (routeData) {
      return _i8.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i5.ContractorPage(),
      );
    },
    PmCheckRoute.name: (routeData) {
      return _i8.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i6.PmCheckPage(),
      );
    },
    PmMeterUpdateRoute.name: (routeData) {
      return _i8.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i7.PmMeterUpdatePage(),
      );
    },
  };

  @override
  List<_i8.RouteConfig> get routes => [
        _i8.RouteConfig(
          HomeRoute.name,
          path: '/',
        ),
        _i8.RouteConfig(
          MyTestRoute.name,
          path: '/test',
        ),
        _i8.RouteConfig(
          AssetRoute.name,
          path: '/asset',
        ),
        _i8.RouteConfig(
          AssetCriticalityRoute.name,
          path: '/asset/criticality',
        ),
        _i8.RouteConfig(
          ContractorRoute.name,
          path: '/contractor',
        ),
        _i8.RouteConfig(
          PmCheckRoute.name,
          path: '/pm/check',
        ),
        _i8.RouteConfig(
          PmMeterUpdateRoute.name,
          path: '/pm/update-meter',
        ),
      ];
}

/// generated route for
/// [_i1.HomePage]
class HomeRoute extends _i8.PageRouteInfo<void> {
  const HomeRoute()
      : super(
          HomeRoute.name,
          path: '/',
        );

  static const String name = 'HomeRoute';
}

/// generated route for
/// [_i2.MyTestPage]
class MyTestRoute extends _i8.PageRouteInfo<void> {
  const MyTestRoute()
      : super(
          MyTestRoute.name,
          path: '/test',
        );

  static const String name = 'MyTestRoute';
}

/// generated route for
/// [_i3.AssetPage]
class AssetRoute extends _i8.PageRouteInfo<void> {
  const AssetRoute()
      : super(
          AssetRoute.name,
          path: '/asset',
        );

  static const String name = 'AssetRoute';
}

/// generated route for
/// [_i4.AssetCriticalityPage]
class AssetCriticalityRoute extends _i8.PageRouteInfo<void> {
  const AssetCriticalityRoute()
      : super(
          AssetCriticalityRoute.name,
          path: '/asset/criticality',
        );

  static const String name = 'AssetCriticalityRoute';
}

/// generated route for
/// [_i5.ContractorPage]
class ContractorRoute extends _i8.PageRouteInfo<void> {
  const ContractorRoute()
      : super(
          ContractorRoute.name,
          path: '/contractor',
        );

  static const String name = 'ContractorRoute';
}

/// generated route for
/// [_i6.PmCheckPage]
class PmCheckRoute extends _i8.PageRouteInfo<void> {
  const PmCheckRoute()
      : super(
          PmCheckRoute.name,
          path: '/pm/check',
        );

  static const String name = 'PmCheckRoute';
}

/// generated route for
/// [_i7.PmMeterUpdatePage]
class PmMeterUpdateRoute extends _i8.PageRouteInfo<void> {
  const PmMeterUpdateRoute()
      : super(
          PmMeterUpdateRoute.name,
          path: '/pm/update-meter',
        );

  static const String name = 'PmMeterUpdateRoute';
}
