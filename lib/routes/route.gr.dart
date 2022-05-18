// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

import 'package:auto_route/auto_route.dart' as _i6;
import 'package:flutter/material.dart' as _i7;

import '../admin/asset.dart' as _i4;
import '../admin/contractor.dart' as _i5;
import '../main.dart' as _i1;
import '../reader/bookrenderer.dart' as _i3;
import '../test/test.dart' as _i2;

class AppRouter extends _i6.RootStackRouter {
  AppRouter([_i7.GlobalKey<_i7.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i6.PageFactory> pagesMap = {
    GHFlutter.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i1.GHFlutter());
    },
    MyTestRoute.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i2.MyTestPage());
    },
    EpubRoute.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i3.EpubPage());
    },
    AssetRoute.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i4.AssetPage());
    },
    ContractorRoute.name: (routeData) {
      return _i6.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i5.ContractorPage());
    }
  };

  @override
  List<_i6.RouteConfig> get routes => [
        _i6.RouteConfig(GHFlutter.name, path: '/'),
        _i6.RouteConfig(MyTestRoute.name, path: '/test'),
        _i6.RouteConfig(EpubRoute.name, path: '/readbook'),
        _i6.RouteConfig(AssetRoute.name, path: '/asset'),
        _i6.RouteConfig(ContractorRoute.name, path: '/contractor')
      ];
}

/// generated route for
/// [_i1.GHFlutter]
class GHFlutter extends _i6.PageRouteInfo<void> {
  const GHFlutter() : super(GHFlutter.name, path: '/');

  static const String name = 'GHFlutter';
}

/// generated route for
/// [_i2.MyTestPage]
class MyTestRoute extends _i6.PageRouteInfo<void> {
  const MyTestRoute() : super(MyTestRoute.name, path: '/test');

  static const String name = 'MyTestRoute';
}

/// generated route for
/// [_i3.EpubPage]
class EpubRoute extends _i6.PageRouteInfo<void> {
  const EpubRoute() : super(EpubRoute.name, path: '/readbook');

  static const String name = 'EpubRoute';
}

/// generated route for
/// [_i4.AssetPage]
class AssetRoute extends _i6.PageRouteInfo<void> {
  const AssetRoute() : super(AssetRoute.name, path: '/asset');

  static const String name = 'AssetRoute';
}

/// generated route for
/// [_i5.ContractorPage]
class ContractorRoute extends _i6.PageRouteInfo<void> {
  const ContractorRoute() : super(ContractorRoute.name, path: '/contractor');

  static const String name = 'ContractorRoute';
}
