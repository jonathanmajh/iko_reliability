// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

import 'package:auto_route/auto_route.dart' as _i5;
import 'package:flutter/material.dart' as _i6;

import '../admin/asset.dart' as _i3;
import '../admin/contractor.dart' as _i4;
import '../main.dart' as _i1;
import '../test/test.dart' as _i2;

class AppRouter extends _i5.RootStackRouter {
  AppRouter([_i6.GlobalKey<_i6.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i5.PageFactory> pagesMap = {
    GHFlutter.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i1.GHFlutter());
    },
    MyTestRoute.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i2.MyTestPage());
    },
    AssetRoute.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i3.AssetPage());
    },
    ContractorRoute.name: (routeData) {
      return _i5.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i4.ContractorPage());
    }
  };

  @override
  List<_i5.RouteConfig> get routes => [
        _i5.RouteConfig(GHFlutter.name, path: '/'),
        _i5.RouteConfig(MyTestRoute.name, path: '/test'),
        _i5.RouteConfig(AssetRoute.name, path: '/asset'),
        _i5.RouteConfig(ContractorRoute.name, path: '/contractor')
      ];
}

/// generated route for
/// [_i1.GHFlutter]
class GHFlutter extends _i5.PageRouteInfo<void> {
  const GHFlutter() : super(GHFlutter.name, path: '/');

  static const String name = 'GHFlutter';
}

/// generated route for
/// [_i2.MyTestPage]
class MyTestRoute extends _i5.PageRouteInfo<void> {
  const MyTestRoute() : super(MyTestRoute.name, path: '/test');

  static const String name = 'MyTestRoute';
}

/// generated route for
/// [_i3.AssetPage]
class AssetRoute extends _i5.PageRouteInfo<void> {
  const AssetRoute() : super(AssetRoute.name, path: '/asset');

  static const String name = 'AssetRoute';
}

/// generated route for
/// [_i4.ContractorPage]
class ContractorRoute extends _i5.PageRouteInfo<void> {
  const ContractorRoute() : super(ContractorRoute.name, path: '/contractor');

  static const String name = 'ContractorRoute';
}
