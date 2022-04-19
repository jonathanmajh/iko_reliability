// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

import 'package:auto_route/auto_route.dart' as _i4;
import 'package:flutter/material.dart' as _i5;

import '../grid/grid.dart' as _i3;
import '../main.dart' as _i1;
import '../test/test.dart' as _i2;

class AppRouter extends _i4.RootStackRouter {
  AppRouter([_i5.GlobalKey<_i5.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i4.PageFactory> pagesMap = {
    GHFlutter.name: (routeData) {
      return _i4.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i1.GHFlutter());
    },
    MyTestRoute.name: (routeData) {
      return _i4.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i2.MyTestPage());
    },
    GridRoute.name: (routeData) {
      return _i4.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i3.GridPage());
    }
  };

  @override
  List<_i4.RouteConfig> get routes => [
        _i4.RouteConfig(GHFlutter.name, path: '/'),
        _i4.RouteConfig(MyTestRoute.name, path: '/test'),
        _i4.RouteConfig(GridRoute.name, path: '/grid')
      ];
}

/// generated route for
/// [_i1.GHFlutter]
class GHFlutter extends _i4.PageRouteInfo<void> {
  const GHFlutter() : super(GHFlutter.name, path: '/');

  static const String name = 'GHFlutter';
}

/// generated route for
/// [_i2.MyTestPage]
class MyTestRoute extends _i4.PageRouteInfo<void> {
  const MyTestRoute() : super(MyTestRoute.name, path: '/test');

  static const String name = 'MyTestRoute';
}

/// generated route for
/// [_i3.GridPage]
class GridRoute extends _i4.PageRouteInfo<void> {
  const GridRoute() : super(GridRoute.name, path: '/grid');

  static const String name = 'GridRoute';
}
