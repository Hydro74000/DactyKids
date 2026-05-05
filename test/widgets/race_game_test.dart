import 'package:dactykids/presentation/widgets/race_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('race game renders car without layout exceptions',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: RaceGame(
              prompt: 'M',
              isPositive: false,
              progress: 0.42,
              errorCount: 3,
              feedbackPulse: 4,
              reduceMotion: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(RaceGame), findsOneWidget);
    expect(find.text('M'), findsNothing);
  });
}
