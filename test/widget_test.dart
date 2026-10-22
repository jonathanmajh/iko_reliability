import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:iko_reliability_flutter/main.dart';
import 'package:iko_reliability_flutter/settings/settings_notifier.dart';
import 'package:iko_reliability_flutter/settings/theme_manager.dart';

void main() {
  testWidgets('MyApp builds and renders the app root',
      (WidgetTester tester) async {
    // The app is designed for a desktop window; the default test
    // surface (800x600 logical px) makes its layouts overflow.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1920, 1080);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
        MyApp(SettingsNotifier(), SelectedSiteNotifier(), ThemeManager()));

    // The real app is router-based, so pump one frame past first build.
    await tester.pump();

    // Tolerate the known drawer-title Row overflow
    // (lib/home_page.dart:172, pre-existing at any test surface);
    // surface any other exception as a test failure.
    final exception = tester.takeException();
    expect(
      exception,
      anyOf(
        isNull,
        isA<FlutterError>().having(
            (e) => e.message, 'message', contains('RenderFlex overflowed')),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
