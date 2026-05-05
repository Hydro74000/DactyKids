import 'package:dactykids/domain/keyboard/input_normalizer.dart';
import 'package:dactykids/domain/typing_engine/prompt_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('matches exact keys including space', () {
    const matcher = PromptMatcher();

    final letter = matcher.match(
      'F',
      const NormalizedInput(keyId: 'F', character: 'f', isShiftPressed: false),
    );
    final space = matcher.match(
      'SPACE',
      const NormalizedInput(
          keyId: 'SPACE', character: ' ', isShiftPressed: false),
    );

    expect(letter.quality, MatchQuality.exact);
    expect(space.quality, MatchQuality.exact);
  });

  test('identifies nearby pedagogical errors', () {
    const matcher = PromptMatcher();

    final match = matcher.match(
      'F',
      const NormalizedInput(keyId: 'D', character: 'd', isShiftPressed: false),
    );

    expect(match.quality, MatchQuality.nearMiss);
    expect(match.isCorrect, isFalse);
  });

  test('requires shift for uppercase prompts', () {
    const matcher = PromptMatcher();

    final withoutShift = matcher.match(
      'SHIFT+A',
      const NormalizedInput(keyId: 'A', character: 'a', isShiftPressed: false),
    );
    final withShift = matcher.match(
      'SHIFT+A',
      const NormalizedInput(keyId: 'A', character: 'A', isShiftPressed: true),
    );

    expect(withoutShift.quality, MatchQuality.wrong);
    expect(withShift.quality, MatchQuality.exact);
    expect(withShift.expectedKey, 'Maj + A');
  });
}
