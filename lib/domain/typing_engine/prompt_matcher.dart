import '../keyboard/input_normalizer.dart';

enum MatchQuality { exact, nearMiss, wrong }

class PromptMatch {
  const PromptMatch({
    required this.quality,
    required this.expectedKey,
    required this.actualKey,
  });

  final MatchQuality quality;
  final String expectedKey;
  final String actualKey;

  bool get isCorrect => quality == MatchQuality.exact;
}

class PromptMatcher {
  const PromptMatcher();

  PromptMatch match(String expectedKey, NormalizedInput input) {
    final expected = PromptKey.canonical(expectedKey);
    final requiresShift = PromptKey.requiresShift(expectedKey);
    final actual = _canonical(input.keyId);
    if (expected == actual && (!requiresShift || input.isShiftPressed)) {
      return PromptMatch(
        quality: MatchQuality.exact,
        expectedKey: PromptKey.display(expectedKey),
        actualKey: actual,
      );
    }

    if (_neighborKeys[expected]?.contains(actual) ?? false) {
      return PromptMatch(
        quality: MatchQuality.nearMiss,
        expectedKey: PromptKey.display(expectedKey),
        actualKey: actual,
      );
    }

    return PromptMatch(
      quality: MatchQuality.wrong,
      expectedKey: PromptKey.display(expectedKey),
      actualKey: actual,
    );
  }

  String _canonical(String value) {
    if (value == ' ' || value.toUpperCase() == 'SPACE') {
      return 'SPACE';
    }
    return value.toUpperCase();
  }
}

class PromptKey {
  const PromptKey._();

  static bool requiresShift(String value) {
    return value.toUpperCase().startsWith('SHIFT+');
  }

  static String canonical(String value) {
    final trimmed = value.trim();
    final withoutModifier = requiresShift(trimmed)
        ? trimmed.substring(trimmed.indexOf('+') + 1)
        : trimmed;
    if (withoutModifier == ' ' || withoutModifier.toUpperCase() == 'SPACE') {
      return 'SPACE';
    }
    return withoutModifier.toUpperCase();
  }

  static String display(String value) {
    final canonicalKey = canonical(value);
    if (requiresShift(value)) {
      return 'Maj + $canonicalKey';
    }
    return canonicalKey;
  }
}

const Map<String, Set<String>> _neighborKeys = {
  'F': {'D', 'G', 'R', 'V'},
  'J': {'H', 'K', 'U', 'N'},
  'D': {'S', 'F', 'E', 'C'},
  'K': {'J', 'L', 'I', ','},
  'S': {'A', 'D', 'Z', 'X'},
  'L': {'K', ';', 'O', '.'},
  'A': {'S', 'Q', 'Z'},
  ';': {'L', 'P', '/'},
  'G': {'F', 'H', 'T', 'B'},
  'H': {'G', 'J', 'Y', 'N'},
};
