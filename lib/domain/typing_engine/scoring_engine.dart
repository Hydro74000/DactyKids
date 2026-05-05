import 'prompt_matcher.dart';

class KeyStats {
  const KeyStats({
    required this.keyId,
    required this.attempts,
    required this.correct,
    required this.errors,
  });

  final String keyId;
  final int attempts;
  final int correct;
  final int errors;

  double get accuracy => attempts == 0 ? 1 : correct / attempts;

  KeyStats record(bool isCorrect) {
    return KeyStats(
      keyId: keyId,
      attempts: attempts + 1,
      correct: correct + (isCorrect ? 1 : 0),
      errors: errors + (isCorrect ? 0 : 1),
    );
  }

  KeyStats merge(KeyStats other) {
    return KeyStats(
      keyId: keyId,
      attempts: attempts + other.attempts,
      correct: correct + other.correct,
      errors: errors + other.errors,
    );
  }

  String encode() => '$keyId,$attempts,$correct,$errors';

  static KeyStats? decode(String raw) {
    final parts = raw.split(',');
    if (parts.length != 4) {
      return null;
    }
    return KeyStats(
      keyId: parts[0],
      attempts: int.tryParse(parts[1]) ?? 0,
      correct: int.tryParse(parts[2]) ?? 0,
      errors: int.tryParse(parts[3]) ?? 0,
    );
  }
}

class SessionResult {
  const SessionResult({
    required this.activityId,
    required this.totalKeystrokes,
    required this.correctKeystrokes,
    required this.errors,
    required this.accuracy,
    required this.keyStats,
    required this.duration,
    required this.wpm,
    required this.difficultKeys,
    required this.masteredKeys,
  });

  final String activityId;
  final int totalKeystrokes;
  final int correctKeystrokes;
  final int errors;
  final double accuracy;
  final Map<String, KeyStats> keyStats;
  final Duration duration;
  final double? wpm;
  final List<String> difficultKeys;
  final List<String> masteredKeys;
}

class ScoringEngine {
  const ScoringEngine();

  Map<String, KeyStats> record(
    Map<String, KeyStats> current,
    PromptMatch match,
  ) {
    final stats = current[match.expectedKey] ??
        KeyStats(
          keyId: match.expectedKey,
          attempts: 0,
          correct: 0,
          errors: 0,
        );
    return {
      ...current,
      match.expectedKey: stats.record(match.isCorrect),
    };
  }

  SessionResult result({
    required String activityId,
    required Map<String, KeyStats> keyStats,
    required Duration duration,
  }) {
    final total =
        keyStats.values.fold<int>(0, (sum, item) => sum + item.attempts);
    final correct =
        keyStats.values.fold<int>(0, (sum, item) => sum + item.correct);
    final errors =
        keyStats.values.fold<int>(0, (sum, item) => sum + item.errors);
    final accuracy = total == 0 ? 1.0 : correct / total;
    final minutes = duration.inMilliseconds / 60000;
    final wpm = minutes <= 0 ? null : correct / 5 / minutes;

    return SessionResult(
      activityId: activityId,
      totalKeystrokes: total,
      correctKeystrokes: correct,
      errors: errors,
      accuracy: accuracy,
      keyStats: keyStats,
      duration: duration,
      wpm: wpm,
      difficultKeys: keyStats.values
          .where((stats) => stats.attempts >= 2 && stats.accuracy < 0.8)
          .map((stats) => stats.keyId)
          .toList(),
      masteredKeys: keyStats.values
          .where((stats) => stats.attempts >= 2 && stats.accuracy >= 0.9)
          .map((stats) => stats.keyId)
          .toList(),
    );
  }
}
