import 'package:flutter/material.dart';

import '../../data/content_repository/content_repository.dart';
import '../../data/local_storage/progress_store.dart';
import '../../data/local_storage/settings_store.dart';
import '../../domain/keyboard/keyboard_layout.dart';
import '../../domain/typing_engine/activity_definition.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class DactyKidsApp extends StatefulWidget {
  const DactyKidsApp({super.key});

  @override
  State<DactyKidsApp> createState() => _DactyKidsAppState();
}

class _DactyKidsAppState extends State<DactyKidsApp> {
  final _settingsStore = SettingsStore();
  final _contentRepository = ContentRepository();
  final _progressStore = ProgressStore();

  AppSettings _settings = AppSettings.defaults;
  List<ProfileSettings> _profiles = const [];
  List<KeyboardLayout> _layouts = const [];
  List<ActivityDefinition> _lessons = const [];
  ProgressOverview _progressOverview = const ProgressOverview(
    completedLessons: {},
    bestAccuracyByLesson: {},
    bestStarValueByLesson: {},
    lastResultByLesson: {},
    keyStats: {},
    starWallet: 0,
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profilesSnapshot = await _settingsStore.loadProfiles();
    final layouts = await _contentRepository.loadKeyboardLayouts();
    final lessons = await _contentRepository.loadLessons();
    final progressOverview = await _progressStore.loadOverview(
      profilesSnapshot.activeProfileId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _settings = profilesSnapshot.activeProfile.settings;
      _profiles = profilesSnapshot.profiles;
      _layouts = layouts;
      _lessons = lessons;
      _progressOverview = progressOverview;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings(AppSettings settings) async {
    await _settingsStore.save(settings);
    final profilesSnapshot = await _settingsStore.loadProfiles();
    if (!mounted) {
      return;
    }
    setState(() {
      _settings = profilesSnapshot.activeProfile.settings;
      _profiles = profilesSnapshot.profiles;
    });
  }

  Future<void> _switchProfile(String profileId) async {
    await _settingsStore.setActiveProfile(profileId);
    final profilesSnapshot = await _settingsStore.loadProfiles();
    final progressOverview = await _progressStore.loadOverview(
      profilesSnapshot.activeProfileId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _settings = profilesSnapshot.activeProfile.settings;
      _profiles = profilesSnapshot.profiles;
      _progressOverview = progressOverview;
    });
  }

  Future<void> _createProfile() async {
    final settings = await _settingsStore.createProfile();
    final profilesSnapshot = await _settingsStore.loadProfiles();
    final progressOverview =
        await _progressStore.loadOverview(settings.profileId);
    if (!mounted) {
      return;
    }
    setState(() {
      _settings = settings;
      _profiles = profilesSnapshot.profiles;
      _progressOverview = progressOverview;
    });
  }

  Future<void> _deleteProfile(String profileId) async {
    final nextActiveId = await _settingsStore.deleteProfile(profileId);
    if (nextActiveId == null) {
      return;
    }
    await _progressStore.clearProfile(profileId);
    final profilesSnapshot = await _settingsStore.loadProfiles();
    final progressOverview = await _progressStore.loadOverview(
      profilesSnapshot.activeProfileId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _settings = profilesSnapshot.activeProfile.settings;
      _profiles = profilesSnapshot.profiles;
      _progressOverview = progressOverview;
    });
  }

  Future<void> _refreshProgress() async {
    final progressOverview = await _progressStore.loadOverview(
      _settings.profileId,
    );
    if (mounted) {
      setState(() => _progressOverview = progressOverview);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DactyKids',
      theme: DactyTheme.fromPreset(_settings.visualPreset),
      home: _isLoading
          ? const _LoadingScreen()
          : HomeScreen(
              settings: _settings,
              profiles: _profiles,
              layouts: _layouts,
              lessons: _lessons,
              progressOverview: _progressOverview,
              progressStore: _progressStore,
              onSettingsChanged: _saveSettings,
              onProfileSelected: _switchProfile,
              onProfileCreated: _createProfile,
              onProfileDeleted: _deleteProfile,
              onProgressChanged: _refreshProgress,
              onBackupRestored: _load,
            ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
