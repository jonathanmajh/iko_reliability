import 'package:auto_route/auto_route.dart';

import '../main.dart';
import '../test/test.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(path: "/", page: GHFlutter, initial: true),
    AutoRoute(path: "/test", page: MyTestPage),
  ],
)
class $AppRouter {}
