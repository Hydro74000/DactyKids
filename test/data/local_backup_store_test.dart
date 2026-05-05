import 'package:dactykids/data/local_storage/local_backup_store.dart';
import 'package:dactykids/data/local_storage/progress_store.dart';
import 'package:dactykids/data/local_storage/settings_store.dart';
import 'package:dactykids/domain/typing_engine/scoring_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('exports and restores local profiles and progress', () async {
    SharedPreferences.setMockInitialValues({});
    final settingsStore = SettingsStore();
    final progressStore = ProgressStore();
    final backupStore = LocalBackupStore();

    final created = await settingsStore.createProfile();
    await settingsStore.save(created.copyWith(childName: 'Nina'));
    await progressStore.markLessonComplete(
      created.profileId,
      const SessionResult(
        activityId: 'home_row_01',
        totalKeystrokes: 4,
        correctKeystrokes: 4,
        errors: 0,
        accuracy: 1,
        keyStats: {
          'F': KeyStats(keyId: 'F', attempts: 2, correct: 2, errors: 0),
        },
        duration: Duration(seconds: 30),
        wpm: 1.6,
        difficultKeys: [],
        masteredKeys: ['F'],
      ),
    );

    final backup = await backupStore.exportJson();

    SharedPreferences.setMockInitialValues({});
    await backupStore.importJson(backup);

    final restoredProfiles = await settingsStore.loadProfiles();
    final restoredOverview =
        await progressStore.loadOverview(created.profileId);

    expect(restoredProfiles.activeProfile.settings.childName, 'Nina');
    expect(restoredOverview.completedLessons, contains('home_row_01'));
    expect(restoredOverview.keyStats['F']?.attempts, 2);
  });

  test('rejects invalid backup format', () async {
    SharedPreferences.setMockInitialValues({});

    expect(
      () => LocalBackupStore().importJson('{"format":"other"}'),
      throwsFormatException,
    );
  });
}
