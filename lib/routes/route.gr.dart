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
import 'package:auto_route/auto_route.dart' as _i7;
import 'package:flutter/material.dart' as _i8;

import '../admin/asset.dart' as _i3;
import '../admin/contractor.dart' as _i4;
import '../admin/pm_check.dart' as _i5;
import '../admin/pm_meter_update.dart' as _i6;
import '../main.dart' as _i1;
import '../test/test.dart' as _i2;

class AppRouter extends _i7.RootStackRouter {
  AppRouter([_i8.GlobalKey<_i8.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i7.PageFactory> pagesMap = {
    HomeRoute.name: (routeData) {
      return _i7.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i1.HomePage(),
      );
    },
    MyTestRoute.name: (routeData) {
      return _i7.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i2.MyTestPage(),
      );
    },
    AssetRoute.name: (routeData) {
      return _i7.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i3.AssetPage(),
      );
    },
    ContractorRoute.name: (routeData) {
      return _i7.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i4.ContractorPage(),
      );
    },
    PmCheckRoute.name: (routeData) {
      return _i7.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i5.PmCheckPage(),
      );
    },
    PmMeterUpdateRoute.name: (routeData) {
      return _i7.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i6.PmMeterUpdatePage(),
      );
    },
  };

  @override
  List<_i7.RouteConfig> get routes => [
        _i7.RouteConfig(
          HomeRoute.name,
          path: '/',
        ),
        _i7.RouteConfig(
          MyTestRoute.name,
          path: '/test',
        ),
        _i7.RouteConfig(
          AssetRoute.name,
          path: '/asset',
        ),
        _i7.RouteConfig(
          ContractorRoute.name,
          path: '/contractor',
        ),
        _i7.RouteConfig(
          PmCheckRoute.name,
          path: '/pm/check',
        ),
        _i7.RouteConfig(
          PmMeterUpdateRoute.name,
          path: '/pm/update-meter',
        ),
      ];
}

/// generated route for
/// [_i1.HomePage]
class HomeRoute extends _i7.PageRouteInfo<void> {
  const HomeRoute()
      : super(
          HomeRoute.name,
          path: '/',
        );

  static const String name = 'HomeRoute';
}

/// generated route for
/// [_i2.MyTestPage]
class MyTestRoute extends _i7.PageRouteInfo<void> {
  const MyTestRoute()
      : super(
          MyTestRoute.name,
          path: '/test',
        );

  static const String name = 'MyTestRoute';
}

/// generated route for
/// [_i3.AssetPage]
class AssetRoute extends _i7.PageRouteInfo<void> {
  const AssetRoute()
      : super(
          AssetRoute.name,
          path: '/asset',
        );

  static const String name = 'AssetRoute';
}

/// generated route for
/// [_i4.ContractorPage]
class ContractorRoute extends _i7.PageRouteInfo<void> {
  const ContractorRoute()
      : super(
          ContractorRoute.name,
          path: '/contractor',
        );

  static const String name = 'ContractorRoute';
}

/// generated route for
/// [_i5.PmCheckPage]
class PmCheckRoute extends _i7.PageRouteInfo<void> {
  const PmCheckRoute()
      : super(
          PmCheckRoute.name,
          path: '/pm/check',
        );

  static const String name = 'PmCheckRoute';
}

/// generated route for
/// [_i6.PmMeterUpdatePage]
class PmMeterUpdateRoute extends _i7.PageRouteInfo<void> {
  const PmMeterUpdateRoute()
      : super(
          PmMeterUpdateRoute.name,
          path: '/pm/update-meter',
        );

  static const String name = 'PmMeterUpdateRoute';
}
