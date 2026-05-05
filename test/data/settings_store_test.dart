import 'package:dactykids/data/local_storage/settings_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('creates and switches local profiles with separate settings', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SettingsStore();

    final initial = await store.loadProfiles();
    expect(initial.profiles, hasLength(1));

    final created = await store.createProfile();
    await store.save(
      created.copyWith(
        childName: 'Mila',
        avatarId: AvatarId.flower,
        keyboardLayoutId: 'qwerty_us',
        soundEnabled: false,
        showTimer: true,
        weeklyGoalMinutes: 35,
      ),
    );

    final withCreated = await store.loadProfiles();
    expect(withCreated.profiles, hasLength(2));
    expect(withCreated.activeProfile.settings.childName, 'Mila');
    expect(withCreated.activeProfile.settings.avatarId, AvatarId.flower);
    expect(withCreated.activeProfile.settings.keyboardLayoutId, 'qwerty_us');
    expect(withCreated.activeProfile.settings.soundEnabled, isFalse);
    expect(withCreated.activeProfile.settings.showTimer, isTrue);
    expect(withCreated.activeProfile.settings.weeklyGoalMinutes, 35);

    await store.setActiveProfile(AppSettings.defaults.profileId);
    final switched = await store.loadProfiles();
    expect(switched.activeProfile.settings.childName, 'DactyKid');
    expect(switched.activeProfile.settings.avatarId, AvatarId.comet);
  });

  test('deletes a profile while keeping one active profile', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SettingsStore();

    await store.loadProfiles();
    final created = await store.createProfile();
    await store.save(created.copyWith(childName: 'Noa'));

    final nextActiveId = await store.deleteProfile(created.profileId);
    final snapshot = await store.loadProfiles();

    expect(nextActiveId, AppSettings.defaults.profileId);
    expect(snapshot.profiles, hasLength(1));
    expect(snapshot.activeProfileId, AppSettings.defaults.profileId);
    expect(snapshot.profiles.map((profile) => profile.id),
        isNot(contains(created.profileId)));

    final refused = await store.deleteProfile(AppSettings.defaults.profileId);
    expect(refused, isNull);
    expect((await store.loadProfiles()).profiles, hasLength(1));
  });
}
