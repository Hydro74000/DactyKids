import 'package:dactykids/presentation/screens/dactykids_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows mini games and parent progress panels', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1200, 900));

    await tester.pumpWidget(const DactyKidsApp());
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('Parcours des touches'), findsOneWidget);
    expect(find.text('F, J et espace'), findsOneWidget);
    expect(find.byTooltip('Profil'), findsOneWidget);
    expect(find.text('Avatar'), findsOneWidget);
    expect(find.text('Recompenses'), findsOneWidget);
    expect(find.byTooltip('Mini-jeux'), findsOneWidget);

    await tester.tap(find.byTooltip('Mini-jeux'));
    await tester.pumpAndSettle();

    expect(find.text('Ballons'), findsOneWidget);
    expect(find.text('Taupes'), findsOneWidget);
    expect(find.text('Jardin'), findsOneWidget);
    expect(find.text('Vaisseau', skipOffstage: false), findsOneWidget);
    expect(find.text('Course', skipOffstage: false), findsOneWidget);

    await tester.tapAt(const Offset(20, 20));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byTooltip('Parent'));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Parent / enseignant'), findsOneWidget);
    expect(find.text('Progression'), findsOneWidget);
    expect(find.text('Village des touches de repos'), findsOneWidget);
    expect(
        find.text('Chateau des phrases', skipOffstage: false), findsOneWidget);
  });

  testWidgets('visible primary controls keep 48px target minimum',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1200, 900));

    await tester.pumpWidget(const DactyKidsApp());
    await tester.pump(const Duration(seconds: 3));

    final controlFinders = [
      find.byType(IconButton),
      find.byType(FilledButton),
      find.byType(OutlinedButton),
    ];

    for (final finder in controlFinders) {
      for (final element in finder.evaluate()) {
        final box = element.renderObject as RenderBox;
        if (!box.attached || !box.hasSize) {
          continue;
        }
        expect(box.size.width, greaterThanOrEqualTo(48));
        expect(box.size.height, greaterThanOrEqualTo(48));
      }
    }
  });
}
