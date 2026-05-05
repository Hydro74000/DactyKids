import 'package:dactykids/domain/keyboard/input_normalizer.dart';
import 'package:dactykids/domain/typing_engine/activity_definition.dart';
import 'package:dactykids/domain/typing_engine/session_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('advances only on correct input and records scoring', () {
    final controller = TypingSessionController(
      activity: const ActivityDefinition(
        id: 'lesson_test',
        title: 'Test',
        world: 'home',
        newKeys: ['F', 'J'],
        reviewKeys: [],
        requiredAccuracy: 0.9,
        prompts: ['F', 'J'],
      ),
    );

    controller.handleInput(
      const NormalizedInput(keyId: 'D', character: 'd', isShiftPressed: false),
    );
    expect(controller.state.currentPrompt, 'F');

    controller.handleInput(
      const NormalizedInput(keyId: 'F', character: 'f', isShiftPressed: false),
    );
    expect(controller.state.currentPrompt, 'J');

    controller.handleInput(
      const NormalizedInput(keyId: 'J', character: 'j', isShiftPressed: false),
    );

    final result = controller.result();
    expect(result.totalKeystrokes, 3);
    expect(result.correctKeystrokes, 2);
    expect(result.accuracy, closeTo(2 / 3, 0.001));
    expect(result.duration.inMilliseconds, greaterThanOrEqualTo(0));
    expect(result.keyStats['F']?.attempts, 2);
    expect(result.keyStats['F']?.errors, 1);
  });

  test('raises assist level after repeated errors', () {
    final controller = TypingSessionController(
      activity: const ActivityDefinition(
        id: 'lesson_assist',
        title: 'Assist',
        world: 'home',
        newKeys: ['F'],
        reviewKeys: [],
        requiredAccuracy: 0.9,
        prompts: ['F'],
      ),
    );

    controller.handleInput(
      const NormalizedInput(keyId: 'D', character: 'd', isShiftPressed: false),
    );
    controller.handleInput(
      const NormalizedInput(keyId: 'D', character: 'd', isShiftPressed: false),
    );

    expect(controller.state.assistLevel, 1);
  });

  test('flattens word prompts into key sequence', () {
    final controller = TypingSessionController(
      activity: const ActivityDefinition(
        id: 'words',
        title: 'Words',
        world: 'word_garden',
        newKeys: [],
        reviewKeys: ['A', 'M', 'I'],
        requiredAccuracy: 0.85,
        prompts: ['ami'],
        promptMode: PromptMode.words,
      ),
    );

    expect(controller.state.currentPrompt, 'A');
    expect(controller.state.currentDisplayPrompt, 'ami');
  });

  test('flattens sentence prompts and keeps sentence display', () {
    final controller = TypingSessionController(
      activity: const ActivityDefinition(
        id: 'sentence',
        title: 'Sentence',
        world: 'word_garden',
        newKeys: [],
        reviewKeys: ['A', 'M', 'I', 'SPACE'],
        requiredAccuracy: 0.85,
        prompts: ['ami ami'],
        promptMode: PromptMode.sentences,
      ),
    );

    expect(controller.state.currentPrompt, 'A');
    expect(controller.state.currentDisplayPrompt, 'ami ami');
  });

  test('flattens uppercase letters into shift prompts', () {
    final controller = TypingSessionController(
      activity: const ActivityDefinition(
        id: 'uppercase_sentence',
        title: 'Uppercase',
        world: 'castle_phrases',
        newKeys: ['SHIFT+A'],
        reviewKeys: ['A', 'SPACE'],
        requiredAccuracy: 0.8,
        prompts: ['Ami'],
        promptMode: PromptMode.sentences,
      ),
    );

    expect(controller.state.currentPrompt, 'SHIFT+A');
    expect(controller.state.currentPromptLabel, 'Maj + A');
    expect(controller.state.currentDisplayPrompt, 'Ami');
  });

  test('flattens paragraph prompts and keeps paragraph display', () {
    final controller = TypingSessionController(
      activity: const ActivityDefinition(
        id: 'paragraph',
        title: 'Paragraph',
        world: 'castle_phrases',
        newKeys: [],
        reviewKeys: ['SHIFT+A', 'A', 'M', 'I', 'SPACE', '.'],
        requiredAccuracy: 0.78,
        prompts: ['Ami.'],
        promptMode: PromptMode.paragraphs,
      ),
    );

    expect(controller.state.currentPrompt, 'SHIFT+A');
    expect(controller.state.currentDisplayPrompt, 'Ami.');
  });

  test('flattens lowercase accented words into exact accent keys', () {
    final controller = TypingSessionController(
      activity: const ActivityDefinition(
        id: 'accented_words',
        title: 'Accented words',
        world: 'castle_phrases',
        newKeys: ['É'],
        reviewKeys: ['T'],
        requiredAccuracy: 0.78,
        prompts: ['été'],
        promptMode: PromptMode.words,
      ),
    );

    expect(controller.state.currentPrompt, 'É');
    expect(controller.state.currentDisplayPrompt, 'été');
  });
}
