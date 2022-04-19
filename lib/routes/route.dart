import 'package:auto_route/auto_route.dart';
import 'package:flutter_application_1/grid/grid.dart';

import '../main.dart';
import '../test/test.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(path: "/", page: GHFlutter, initial: true),
    AutoRoute(path: "/test", page: MyTestPage),
    AutoRoute(path: "/grid", page: GridPage)
  ],
)
class $AppRouter {}
