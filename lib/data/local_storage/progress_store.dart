import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/typing_engine/scoring_engine.dart';

class ProgressOverview {
  const ProgressOverview({
    required this.completedLessons,
    required this.bestAccuracyByLesson,
    required this.bestStarValueByLesson,
    required this.lastResultByLesson,
    required this.keyStats,
    required this.starWallet,
  });

  final Set<String> completedLessons;
  final Map<String, int> bestAccuracyByLesson;
  final Map<String, int> bestStarValueByLesson;
  final Map<String, LessonResultSnapshot> lastResultByLesson;
  final Map<String, KeyStats> keyStats;
  final int starWallet;

  int get completedCount => completedLessons.length;

  int get recordedPracticeSeconds {
    return lastResultByLesson.values.fold<int>(
      0,
      (sum, result) => sum + result.durationSeconds,
    );
  }

  Set<String> get rewardIds {
    return {
      if (completedLessons.contains('home_row_01')) 'sticker_fj',
      if (completedCount >= 3) 'badge_calme',
      if (completedCount >= 6) 'couronne_home_row',
      if (completedLessons.contains('top_row_05')) 'badge_foret',
      if (completedLessons.contains('bottom_row_04')) 'badge_grotte',
      if (completedLessons.contains('practice_syllables_01'))
        'sticker_syllabes',
      if (completedLessons.contains('practice_words_01')) 'sticker_mots',
      if (completedLessons.contains('soft_test_01')) 'ruban_test_doux',
      if (completedLessons.contains('castle_shift_01')) 'badge_majuscules',
      if (completedLessons.contains('castle_numbers_01')) 'badge_chiffres',
      if (completedLessons.contains('castle_symbols_01')) 'badge_symboles',
      if (completedLessons.contains('castle_accents_01')) 'badge_accents',
      if (completedLessons.contains('castle_paragraph_01')) 'badge_paragraphe',
      if (bestAccuracyByLesson.values.any((accuracy) => accuracy >= 95))
        'etoile_precision',
    };
  }

  List<KeyStats> get mostDifficultKeys {
    final stats = keyStats.values
        .where((stats) => stats.attempts >= 2 && stats.errors > 0)
        .toList()
      ..sort((left, right) {
        final accuracyCompare = left.accuracy.compareTo(right.accuracy);
        if (accuracyCompare != 0) {
          return accuracyCompare;
        }
        return right.attempts.compareTo(left.attempts);
      });
    return stats.take(5).toList();
  }
}

class StarAward {
  const StarAward({
    required this.baseStars,
    required this.isPerfectBonus,
    required this.previousBestValue,
    required this.newBestValue,
    required this.walletGain,
    required this.walletTotal,
  });

  final int baseStars;
  final bool isPerfectBonus;
  final int previousBestValue;
  final int newBestValue;
  final int walletGain;
  final int walletTotal;

  int get displayedStars => isPerfectBonus ? 4 : baseStars;
  int get paidValue => isPerfectBonus ? baseStars * 2 : baseStars;
}

class LessonResultSnapshot {
  const LessonResultSnapshot({
    required this.activityId,
    required this.accuracyPercent,
    required this.correctKeystrokes,
    required this.errors,
    required this.durationSeconds,
    required this.wpm,
    required this.difficultKeys,
    required this.masteredKeys,
  });

  final String activityId;
  final int accuracyPercent;
  final int correctKeystrokes;
  final int errors;
  final int durationSeconds;
  final double? wpm;
  final List<String> difficultKeys;
  final List<String> masteredKeys;

  factory LessonResultSnapshot.fromSessionResult(SessionResult result) {
    return LessonResultSnapshot(
      activityId: result.activityId,
      accuracyPercent: (result.accuracy * 100).round(),
      correctKeystrokes: result.correctKeystrokes,
      errors: result.errors,
      durationSeconds: result.duration.inSeconds,
      wpm: result.wpm,
      difficultKeys: result.difficultKeys,
      masteredKeys: result.masteredKeys,
    );
  }

  String encode() {
    return [
      activityId,
      accuracyPercent,
      correctKeystrokes,
      errors,
      durationSeconds,
      wpm?.toStringAsFixed(1) ?? '',
      difficultKeys.join('|'),
      masteredKeys.join('|'),
    ].join(';');
  }

  static LessonResultSnapshot? decode(String raw) {
    final parts = raw.split(';');
    if (parts.length == 6) {
      return LessonResultSnapshot(
        activityId: parts[0],
        accuracyPercent: int.tryParse(parts[1]) ?? 0,
        correctKeystrokes: int.tryParse(parts[2]) ?? 0,
        errors: int.tryParse(parts[3]) ?? 0,
        durationSeconds: 0,
        wpm: null,
        difficultKeys: parts[4].isEmpty ? const [] : parts[4].split('|'),
        masteredKeys: parts[5].isEmpty ? const [] : parts[5].split('|'),
      );
    }
    if (parts.length != 8) {
      return null;
    }
    return LessonResultSnapshot(
      activityId: parts[0],
      accuracyPercent: int.tryParse(parts[1]) ?? 0,
      correctKeystrokes: int.tryParse(parts[2]) ?? 0,
      errors: int.tryParse(parts[3]) ?? 0,
      durationSeconds: int.tryParse(parts[4]) ?? 0,
      wpm: double.tryParse(parts[5]),
      difficultKeys: parts[6].isEmpty ? const [] : parts[6].split('|'),
      masteredKeys: parts[7].isEmpty ? const [] : parts[7].split('|'),
    );
  }
}

class ProgressStore {
  static const _completedLessonsSuffix = 'progress.completedLessons';
  static const _bestAccuracySuffix = 'progress.bestAccuracy.';
  static const _bestStarValueSuffix = 'progress.bestStarValue.';
  static const _lastResultSuffix = 'progress.lastResult.';
  static const _keyStatsSuffix = 'progress.keyStats.';
  static const _starWalletSuffix = 'progress.starWallet';

  Future<Set<String>> loadCompletedLessons(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_completedLessonsKey(profileId)) ?? const [])
        .toSet();
  }

  Future<ProgressOverview> loadOverview(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed =
        (prefs.getStringList(_completedLessonsKey(profileId)) ?? const [])
            .toSet();
    final bestAccuracyByLesson = <String, int>{};
    final bestStarValueByLesson = <String, int>{};
    final lastResultByLesson = <String, LessonResultSnapshot>{};
    final keyStats = <String, KeyStats>{};
    final bestAccuracyPrefix = _bestAccuracyPrefix(profileId);
    final bestStarValuePrefix = _bestStarValuePrefix(profileId);
    final lastResultPrefix = _lastResultPrefix(profileId);
    final keyStatsPrefix = _keyStatsPrefix(profileId);

    for (final key in prefs.getKeys()) {
      if (key.startsWith(bestAccuracyPrefix)) {
        final lessonId = key.substring(bestAccuracyPrefix.length);
        bestAccuracyByLesson[lessonId] = prefs.getInt(key) ?? 0;
      }
      if (key.startsWith(bestStarValuePrefix)) {
        final lessonId = key.substring(bestStarValuePrefix.length);
        bestStarValueByLesson[lessonId] = prefs.getInt(key) ?? 0;
      }
      if (key.startsWith(lastResultPrefix)) {
        final lessonId = key.substring(lastResultPrefix.length);
        final raw = prefs.getString(key);
        final snapshot = raw == null ? null : LessonResultSnapshot.decode(raw);
        if (snapshot != null) {
          lastResultByLesson[lessonId] = snapshot;
        }
      }
      if (key.startsWith(keyStatsPrefix)) {
        final keyId = key.substring(keyStatsPrefix.length);
        final raw = prefs.getString(key);
        final stats = raw == null ? null : KeyStats.decode(raw);
        if (stats != null) {
          keyStats[keyId] = stats;
        }
      }
    }

    return ProgressOverview(
      completedLessons: completed,
      bestAccuracyByLesson: bestAccuracyByLesson,
      bestStarValueByLesson: bestStarValueByLesson,
      lastResultByLesson: lastResultByLesson,
      keyStats: keyStats,
      starWallet: prefs.getInt(_starWalletKey(profileId)) ?? 0,
    );
  }

  Future<StarAward> markLessonComplete(
      String profileId, SessionResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final accuracyPercent = (result.accuracy * 100).round();
    final starAward = await _updateStars(
      prefs: prefs,
      profileId: profileId,
      activityId: result.activityId,
      accuracyPercent: accuracyPercent,
      errors: result.errors,
    );
    final bestKey = '${_bestAccuracyPrefix(profileId)}${result.activityId}';
    final previousBest = prefs.getInt(bestKey) ?? 0;
    if (accuracyPercent > previousBest) {
      await prefs.setInt(bestKey, accuracyPercent);
    }
    await prefs.setString(
      '${_lastResultPrefix(profileId)}${result.activityId}',
      LessonResultSnapshot.fromSessionResult(result).encode(),
    );
    for (final entry in result.keyStats.entries) {
      final statsKey = '${_keyStatsPrefix(profileId)}${entry.key}';
      final previousRaw = prefs.getString(statsKey);
      final previous =
          previousRaw == null ? null : KeyStats.decode(previousRaw);
      final merged = (previous ??
              KeyStats(
                keyId: entry.key,
                attempts: 0,
                correct: 0,
                errors: 0,
              ))
          .merge(entry.value);
      await prefs.setString(statsKey, merged.encode());
    }
    if (result.accuracy < 0.9) {
      return starAward;
    }
    final completed =
        (prefs.getStringList(_completedLessonsKey(profileId)) ?? const [])
            .toSet();
    completed.add(result.activityId);
    await prefs.setStringList(
      _completedLessonsKey(profileId),
      completed.toList()..sort(),
    );
    return starAward;
  }

  Future<StarAward> _updateStars({
    required SharedPreferences prefs,
    required String profileId,
    required String activityId,
    required int accuracyPercent,
    required int errors,
  }) async {
    final baseStars = _baseStarsForAccuracy(accuracyPercent);
    final isPerfectBonus = accuracyPercent == 100 && errors == 0;
    final newValue = isPerfectBonus ? baseStars * 2 : baseStars;
    final bestKey = '${_bestStarValuePrefix(profileId)}$activityId';
    final previousBestValue = prefs.getInt(bestKey) ?? 0;
    final walletKey = _starWalletKey(profileId);
    final previousWallet = prefs.getInt(walletKey) ?? 0;
    final gain = (newValue - previousBestValue).clamp(0, 999);
    final nextWallet = previousWallet + gain;

    if (newValue > previousBestValue) {
      await prefs.setInt(bestKey, newValue);
    }
    if (gain > 0) {
      await prefs.setInt(walletKey, nextWallet);
    }

    return StarAward(
      baseStars: baseStars,
      isPerfectBonus: isPerfectBonus,
      previousBestValue: previousBestValue,
      newBestValue: newValue > previousBestValue ? newValue : previousBestValue,
      walletGain: gain,
      walletTotal: nextWallet,
    );
  }

  int _baseStarsForAccuracy(int accuracyPercent) {
    if (accuracyPercent <= 33) {
      return 1;
    }
    if (accuracyPercent <= 66) {
      return 2;
    }
    return 3;
  }

  Future<void> clearProfile(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _profilePrefix(profileId);
    for (final key in prefs.getKeys().where((key) => key.startsWith(prefix))) {
      await prefs.remove(key);
    }
  }

  String _profilePrefix(String profileId) => 'profile.$profileId.';

  String _completedLessonsKey(String profileId) =>
      '${_profilePrefix(profileId)}$_completedLessonsSuffix';

  String _bestAccuracyPrefix(String profileId) =>
      '${_profilePrefix(profileId)}$_bestAccuracySuffix';

  String _bestStarValuePrefix(String profileId) =>
      '${_profilePrefix(profileId)}$_bestStarValueSuffix';

  String _lastResultPrefix(String profileId) =>
      '${_profilePrefix(profileId)}$_lastResultSuffix';

  String _keyStatsPrefix(String profileId) =>
      '${_profilePrefix(profileId)}$_keyStatsSuffix';

  String _starWalletKey(String profileId) =>
      '${_profilePrefix(profileId)}$_starWalletSuffix';
}
