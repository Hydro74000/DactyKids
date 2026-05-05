import 'package:dactykids/presentation/screens/dactykids_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home and panels remain usable at 200 percent text scale',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(const DactyKidsApp());
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('Parcours des touches'), findsOneWidget);
    expect(find.byTooltip('Reglages'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Reglages'));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Mode visuel'), findsOneWidget);
    await tester.dragFrom(const Offset(600, 820), const Offset(0, -320));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Timer visible'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tapAt(const Offset(20, 20));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byTooltip('Parent'));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Parent / enseignant'), findsOneWidget);
    expect(find.text('Progression'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
