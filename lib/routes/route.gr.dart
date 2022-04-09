// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

import 'package:auto_route/auto_route.dart' as _i3;
import 'package:flutter/material.dart' as _i4;

import '../main.dart' as _i1;
import '../test/test.dart' as _i2;

class AppRouter extends _i3.RootStackRouter {
  AppRouter([_i4.GlobalKey<_i4.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i3.PageFactory> pagesMap = {
    GHFlutter.name: (routeData) {
      return _i3.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i1.GHFlutter());
    },
    MyTestRoute.name: (routeData) {
      return _i3.MaterialPageX<dynamic>(
          routeData: routeData, child: const _i2.MyTestPage());
    }
  };

  @override
  List<_i3.RouteConfig> get routes => [
        _i3.RouteConfig(GHFlutter.name, path: '/'),
        _i3.RouteConfig(MyTestRoute.name, path: '/test')
      ];
}

/// generated route for
/// [_i1.GHFlutter]
class GHFlutter extends _i3.PageRouteInfo<void> {
  const GHFlutter() : super(GHFlutter.name, path: '/');

  static const String name = 'GHFlutter';
}

/// generated route for
/// [_i2.MyTestPage]
class MyTestRoute extends _i3.PageRouteInfo<void> {
  const MyTestRoute() : super(MyTestRoute.name, path: '/test');

  static const String name = 'MyTestRoute';
}
