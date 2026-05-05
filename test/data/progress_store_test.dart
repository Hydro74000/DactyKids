import 'package:dactykids/data/local_storage/progress_store.dart';
import 'package:dactykids/domain/typing_engine/scoring_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stores best accuracy, last result and rewards locally', () async {
    SharedPreferences.setMockInitialValues({});
    final store = ProgressStore();

    await store.markLessonComplete(
      'profile_a',
      const SessionResult(
        activityId: 'home_row_01',
        totalKeystrokes: 10,
        correctKeystrokes: 10,
        errors: 0,
        accuracy: 1,
        keyStats: {
          'F': KeyStats(keyId: 'F', attempts: 5, correct: 5, errors: 0),
          'J': KeyStats(keyId: 'J', attempts: 5, correct: 5, errors: 0),
        },
        duration: Duration(minutes: 1),
        wpm: 2,
        difficultKeys: [],
        masteredKeys: ['F', 'J'],
      ),
    );

    final overview = await store.loadOverview('profile_a');
    final otherOverview = await store.loadOverview('profile_b');

    expect(overview.completedLessons, contains('home_row_01'));
    expect(overview.bestAccuracyByLesson['home_row_01'], 100);
    expect(
        overview.lastResultByLesson['home_row_01']?.masteredKeys, ['F', 'J']);
    expect(overview.keyStats['F']?.attempts, 5);
    expect(overview.recordedPracticeSeconds, 60);
    expect(overview.rewardIds, containsAll(['sticker_fj', 'etoile_precision']));
    expect(otherOverview.completedLessons, isEmpty);
    expect(otherOverview.bestAccuracyByLesson, isEmpty);
    expect(otherOverview.keyStats, isEmpty);
  });

  test('clears all progress for one profile only', () async {
    SharedPreferences.setMockInitialValues({});
    final store = ProgressStore();

    await store.markLessonComplete('profile_a', _perfectResult('home_row_01'));
    await store.markLessonComplete('profile_b', _perfectResult('home_row_02'));

    await store.clearProfile('profile_a');

    expect((await store.loadOverview('profile_a')).completedLessons, isEmpty);
    expect((await store.loadOverview('profile_a')).keyStats, isEmpty);
    expect((await store.loadOverview('profile_b')).completedLessons,
        contains('home_row_02'));
  });
}

SessionResult _perfectResult(String activityId) {
  return SessionResult(
    activityId: activityId,
    totalKeystrokes: 4,
    correctKeystrokes: 4,
    errors: 0,
    accuracy: 1,
    keyStats: const {
      'F': KeyStats(keyId: 'F', attempts: 2, correct: 2, errors: 0),
    },
    duration: const Duration(seconds: 30),
    wpm: 1.6,
    difficultKeys: const [],
    masteredKeys: const ['F'],
  );
}
