import 'package:shared_preferences/shared_preferences.dart';

enum VisualPreset { standard, highContrast, lowVision, grayscale }

enum AvatarId { comet, flower, star }

class ProfileSettings {
  const ProfileSettings({
    required this.id,
    required this.settings,
  });

  final String id;
  final AppSettings settings;
}

class ProfilesSnapshot {
  const ProfilesSnapshot({
    required this.activeProfileId,
    required this.profiles,
  });

  final String activeProfileId;
  final List<ProfileSettings> profiles;

  ProfileSettings get activeProfile {
    return profiles.firstWhere(
      (profile) => profile.id == activeProfileId,
      orElse: () => profiles.first,
    );
  }
}

class AppSettings {
  const AppSettings({
    required this.profileId,
    required this.childName,
    required this.avatarId,
    required this.keyboardLayoutId,
    required this.visualPreset,
    required this.reduceMotion,
    required this.soundEnabled,
    required this.showTimer,
    required this.showHandGuide,
    required this.weeklyGoalMinutes,
  });

  final String profileId;
  final String childName;
  final AvatarId avatarId;
  final String keyboardLayoutId;
  final VisualPreset visualPreset;
  final bool reduceMotion;
  final bool soundEnabled;
  final bool showTimer;
  final bool showHandGuide;
  final int weeklyGoalMinutes;

  AppSettings copyWith({
    String? profileId,
    String? childName,
    AvatarId? avatarId,
    String? keyboardLayoutId,
    VisualPreset? visualPreset,
    bool? reduceMotion,
    bool? soundEnabled,
    bool? showTimer,
    bool? showHandGuide,
    int? weeklyGoalMinutes,
  }) {
    return AppSettings(
      profileId: profileId ?? this.profileId,
      childName: childName ?? this.childName,
      avatarId: avatarId ?? this.avatarId,
      keyboardLayoutId: keyboardLayoutId ?? this.keyboardLayoutId,
      visualPreset: visualPreset ?? this.visualPreset,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      showTimer: showTimer ?? this.showTimer,
      showHandGuide: showHandGuide ?? this.showHandGuide,
      weeklyGoalMinutes: weeklyGoalMinutes ?? this.weeklyGoalMinutes,
    );
  }

  static const defaults = AppSettings(
    profileId: 'profile_default',
    childName: 'DactyKid',
    avatarId: AvatarId.comet,
    keyboardLayoutId: 'azerty_fr',
    visualPreset: VisualPreset.standard,
    reduceMotion: false,
    soundEnabled: true,
    showTimer: false,
    showHandGuide: true,
    weeklyGoalMinutes: 20,
  );
}

class SettingsStore {
  static const _profileIdsKey = 'profiles.ids';
  static const _activeProfileIdKey = 'profiles.activeId';
  static const _legacyChildNameKey = 'settings.childName';
  static const _legacyAvatarIdKey = 'settings.avatarId';
  static const _legacyLayoutKey = 'settings.keyboardLayoutId';
  static const _legacyPresetKey = 'settings.visualPreset';
  static const _legacyReduceMotionKey = 'settings.reduceMotion';
  static const _legacySoundEnabledKey = 'settings.soundEnabled';
  static const _legacyShowTimerKey = 'settings.showTimer';
  static const _legacyShowHandGuideKey = 'settings.showHandGuide';
  static const _legacyWeeklyGoalMinutesKey = 'settings.weeklyGoalMinutes';

  Future<AppSettings> load() async {
    final snapshot = await loadProfiles();
    return snapshot.activeProfile.settings;
  }

  Future<ProfilesSnapshot> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    var ids = prefs.getStringList(_profileIdsKey);
    if (ids == null || ids.isEmpty) {
      final migrated = _loadProfile(prefs, AppSettings.defaults.profileId);
      final defaultSettings = migrated.copyWith(
        childName: prefs.getString(_legacyChildNameKey) ?? migrated.childName,
        avatarId: _enumByName(
          AvatarId.values,
          prefs.getString(_legacyAvatarIdKey),
          migrated.avatarId,
        ),
        keyboardLayoutId:
            prefs.getString(_legacyLayoutKey) ?? migrated.keyboardLayoutId,
        visualPreset: _enumByName(
          VisualPreset.values,
          prefs.getString(_legacyPresetKey),
          migrated.visualPreset,
        ),
        reduceMotion:
            prefs.getBool(_legacyReduceMotionKey) ?? migrated.reduceMotion,
        soundEnabled:
            prefs.getBool(_legacySoundEnabledKey) ?? migrated.soundEnabled,
        showTimer: prefs.getBool(_legacyShowTimerKey) ?? migrated.showTimer,
        showHandGuide:
            prefs.getBool(_legacyShowHandGuideKey) ?? migrated.showHandGuide,
        weeklyGoalMinutes: prefs.getInt(_legacyWeeklyGoalMinutesKey) ??
            migrated.weeklyGoalMinutes,
      );
      await _saveProfile(prefs, defaultSettings);
      ids = [defaultSettings.profileId];
      await prefs.setStringList(_profileIdsKey, ids);
      await prefs.setString(_activeProfileIdKey, defaultSettings.profileId);
    }

    final profiles = [
      for (final id in ids)
        ProfileSettings(id: id, settings: _loadProfile(prefs, id)),
    ];
    final activeId = prefs.getString(_activeProfileIdKey);
    return ProfilesSnapshot(
      activeProfileId: profiles.any((profile) => profile.id == activeId)
          ? activeId!
          : profiles.first.id,
      profiles: profiles,
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await _saveProfile(prefs, settings);
  }

  Future<AppSettings> createProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_profileIdsKey) ?? const [];
    final nextId = 'profile_${DateTime.now().microsecondsSinceEpoch}';
    final nextIndex = ids.length + 1;
    final settings = AppSettings.defaults.copyWith(
      profileId: nextId,
      childName: 'Enfant $nextIndex',
    );
    await prefs.setStringList(_profileIdsKey, [...ids, nextId]);
    await prefs.setString(_activeProfileIdKey, nextId);
    await _saveProfile(prefs, settings);
    return settings;
  }

  Future<void> setActiveProfile(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_profileIdsKey) ?? const [];
    if (ids.contains(profileId)) {
      await prefs.setString(_activeProfileIdKey, profileId);
    }
  }

  Future<String?> deleteProfile(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_profileIdsKey) ?? const [];
    if (!ids.contains(profileId) || ids.length <= 1) {
      return null;
    }

    final remainingIds = ids.where((id) => id != profileId).toList();
    await prefs.setStringList(_profileIdsKey, remainingIds);
    for (final key in prefs.getKeys().where(_isProfileSettingsKey(profileId))) {
      await prefs.remove(key);
    }

    final activeId = prefs.getString(_activeProfileIdKey);
    final nextActiveId = activeId == profileId
        ? remainingIds.first
        : activeId ?? remainingIds.first;
    await prefs.setString(_activeProfileIdKey, nextActiveId);
    return nextActiveId;
  }

  AppSettings _loadProfile(SharedPreferences prefs, String profileId) {
    final prefix = _profilePrefix(profileId);
    return AppSettings(
      profileId: profileId,
      childName: prefs.getString('${prefix}childName') ??
          AppSettings.defaults.childName,
      avatarId: _enumByName(
        AvatarId.values,
        prefs.getString('${prefix}avatarId'),
        AppSettings.defaults.avatarId,
      ),
      keyboardLayoutId: prefs.getString('${prefix}keyboardLayoutId') ??
          AppSettings.defaults.keyboardLayoutId,
      visualPreset: _enumByName(
        VisualPreset.values,
        prefs.getString('${prefix}visualPreset'),
        AppSettings.defaults.visualPreset,
      ),
      reduceMotion: prefs.getBool('${prefix}reduceMotion') ??
          AppSettings.defaults.reduceMotion,
      soundEnabled: prefs.getBool('${prefix}soundEnabled') ??
          AppSettings.defaults.soundEnabled,
      showTimer:
          prefs.getBool('${prefix}showTimer') ?? AppSettings.defaults.showTimer,
      showHandGuide: prefs.getBool('${prefix}showHandGuide') ??
          AppSettings.defaults.showHandGuide,
      weeklyGoalMinutes: prefs.getInt('${prefix}weeklyGoalMinutes') ??
          AppSettings.defaults.weeklyGoalMinutes,
    );
  }

  Future<void> _saveProfile(
      SharedPreferences prefs, AppSettings settings) async {
    final prefix = _profilePrefix(settings.profileId);
    await prefs.setString(
      '${prefix}childName',
      settings.childName.trim().isEmpty
          ? AppSettings.defaults.childName
          : settings.childName.trim(),
    );
    await prefs.setString('${prefix}avatarId', settings.avatarId.name);
    await prefs.setString(
        '${prefix}keyboardLayoutId', settings.keyboardLayoutId);
    await prefs.setString('${prefix}visualPreset', settings.visualPreset.name);
    await prefs.setBool('${prefix}reduceMotion', settings.reduceMotion);
    await prefs.setBool('${prefix}soundEnabled', settings.soundEnabled);
    await prefs.setBool('${prefix}showTimer', settings.showTimer);
    await prefs.setBool('${prefix}showHandGuide', settings.showHandGuide);
    await prefs.setInt(
        '${prefix}weeklyGoalMinutes', settings.weeklyGoalMinutes);
  }

  String _profilePrefix(String profileId) => 'profile.$profileId.settings.';

  bool Function(String key) _isProfileSettingsKey(String profileId) {
    final prefix = _profilePrefix(profileId);
    return (key) => key.startsWith(prefix);
  }

  T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
    return values.firstWhere(
      (value) => value.name == name,
      orElse: () => fallback,
    );
  }
}
