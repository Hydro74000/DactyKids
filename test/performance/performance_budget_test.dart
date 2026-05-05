import 'package:dactykids/data/content_repository/content_repository.dart';
import 'package:dactykids/domain/keyboard/input_normalizer.dart';
import 'package:dactykids/domain/typing_engine/activity_definition.dart';
import 'package:dactykids/domain/typing_engine/session_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('content assets load within release smoke budget', () async {
    final stopwatch = Stopwatch()..start();

    final repository = ContentRepository();
    final layouts = await repository.loadKeyboardLayouts();
    final lessons = await repository.loadLessons();

    stopwatch.stop();
    expect(layouts, hasLength(2));
    expect(lessons, hasLength(greaterThanOrEqualTo(24)));
    expect(stopwatch.elapsedMilliseconds, lessThan(500));
  });

  test('typing engine handles repeated key input within smoke budget', () {
    final controller = TypingSessionController(
      activity: const ActivityDefinition(
        id: 'perf_keys',
        title: 'Perf',
        world: 'test',
        newKeys: ['F'],
        reviewKeys: [],
        requiredAccuracy: 0.9,
        prompts: [
          'F',
          'F',
          'F',
          'F',
          'F',
          'F',
          'F',
          'F',
          'F',
          'F',
        ],
      ),
    );
    const input = NormalizedInput(
      keyId: 'F',
      character: 'f',
      isShiftPressed: false,
    );

    final stopwatch = Stopwatch()..start();
    for (var index = 0; index < 1000; index++) {
      controller.handleInput(input);
    }
    stopwatch.stop();

    expect(stopwatch.elapsedMilliseconds, lessThan(100));
  });
}
