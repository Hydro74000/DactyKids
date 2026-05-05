import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/local_storage/local_backup_store.dart';
import '../../data/local_storage/progress_store.dart';
import '../../data/local_storage/settings_store.dart';
import '../../domain/keyboard/keyboard_layout.dart';
import '../../domain/typing_engine/activity_definition.dart';
import '../../domain/typing_engine/scoring_engine.dart';
import 'lesson_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.settings,
    required this.profiles,
    required this.layouts,
    required this.lessons,
    required this.progressOverview,
    required this.progressStore,
    required this.onSettingsChanged,
    required this.onProfileSelected,
    required this.onProfileCreated,
    required this.onProfileDeleted,
    required this.onProgressChanged,
    required this.onBackupRestored,
  });

  final AppSettings settings;
  final List<ProfileSettings> profiles;
  final List<KeyboardLayout> layouts;
  final List<ActivityDefinition> lessons;
  final ProgressOverview progressOverview;
  final ProgressStore progressStore;
  final ValueChanged<AppSettings> onSettingsChanged;
  final ValueChanged<String> onProfileSelected;
  final Future<void> Function() onProfileCreated;
  final Future<void> Function(String profileId) onProfileDeleted;
  final VoidCallback onProgressChanged;
  final Future<void> Function() onBackupRestored;

  @override
  Widget build(BuildContext context) {
    final selectedLayout = layouts.firstWhere(
      (layout) => layout.id == settings.keyboardLayoutId,
      orElse: () => layouts.first,
    );
    final selectedLessons =
        lessons.map((lesson) => lesson.forLayout(selectedLayout.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DactyKids'),
        actions: [
          IconButton(
            tooltip: 'Profil',
            onPressed: () => _showProfilePanel(context),
            icon: const Icon(Icons.person_rounded),
          ),
          IconButton(
            tooltip: 'Mini-jeux',
            onPressed: () => _showMiniGamesPanel(
              context,
              selectedLayout,
            ),
            icon: const Icon(Icons.sports_esports_rounded),
          ),
          IconButton(
            tooltip: 'Reglages',
            onPressed: () => _showSettings(context),
            icon: const Icon(Icons.settings_rounded),
          ),
          IconButton(
            tooltip: 'Parent',
            onPressed: () => _showParentPanel(context, selectedLessons),
            icon: const Icon(Icons.supervisor_account_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 840;
            final content = [
              _WelcomePanel(
                childName: settings.childName,
                avatarId: settings.avatarId,
                layoutLabel: selectedLayout.label,
                visualPreset: settings.visualPreset,
                progressOverview: progressOverview,
                onChooseAvatar: () => _showAvatarPanel(context),
                onShowRewards: () => _showRewardsPanel(context),
                onShowMiniGames: () => _showMiniGamesPanel(
                  context,
                  selectedLayout,
                ),
              ),
              _LessonList(
                lessons: selectedLessons,
                progressOverview: progressOverview,
                onStartLesson: (lesson) => _startLesson(
                  context,
                  lesson,
                  selectedLayout,
                ),
              ),
            ];

            return Padding(
              padding: const EdgeInsets.all(20),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(child: content.first),
                        ),
                        const SizedBox(width: 24),
                        Expanded(flex: 2, child: content.last),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight * 0.48,
                          ),
                          child: SingleChildScrollView(child: content.first),
                        ),
                        const SizedBox(height: 20),
                        Expanded(child: content.last),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _startLesson(
    BuildContext context,
    ActivityDefinition lesson,
    KeyboardLayout layout, {
    LessonGameType? forcedGameType,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonScreen(
          lesson: lesson,
          layout: layout,
          settings: settings,
          profileId: settings.profileId,
          progressStore: progressStore,
          forcedGameType: forcedGameType,
        ),
      ),
    );
    onProgressChanged();
  }

  Future<void> _showSettings(BuildContext context) async {
    var draft = settings;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void save(AppSettings next) {
              setSheetState(() => draft = next);
              onSettingsChanged(next);
            }

            return FractionallySizedBox(
              heightFactor: 0.92,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: ListView(
                  children: [
                    Text('Clavier',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: [
                        for (final layout in layouts)
                          ButtonSegment(
                            value: layout.id,
                            label: Text(layout.label),
                          ),
                      ],
                      selected: {draft.keyboardLayoutId},
                      onSelectionChanged: (value) => save(
                        draft.copyWith(keyboardLayoutId: value.first),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Mode visuel',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<VisualPreset>(
                        segments: const [
                          ButtonSegment(
                              value: VisualPreset.standard,
                              label: Text('Standard')),
                          ButtonSegment(
                            value: VisualPreset.highContrast,
                            label: Text('Contraste'),
                          ),
                          ButtonSegment(
                              value: VisualPreset.lowVision,
                              label: Text('Tres lisible')),
                          ButtonSegment(
                              value: VisualPreset.grayscale,
                              label: Text('Gris')),
                        ],
                        selected: {draft.visualPreset},
                        onSelectionChanged: (value) => save(
                          draft.copyWith(visualPreset: value.first),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Animations reduites'),
                      value: draft.reduceMotion,
                      onChanged: (value) => save(
                        draft.copyWith(reduceMotion: value),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Son doux'),
                      value: draft.soundEnabled,
                      onChanged: (value) => save(
                        draft.copyWith(soundEnabled: value),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Timer visible'),
                      value: draft.showTimer,
                      onChanged: (value) => save(
                        draft.copyWith(showTimer: value),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Aide mains et doigts'),
                      value: draft.showHandGuide,
                      onChanged: (value) => save(
                        draft.copyWith(showHandGuide: value),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Objectif hebdomadaire',
                        style: Theme.of(context).textTheme.titleLarge),
                    Slider(
                      value: draft.weeklyGoalMinutes.toDouble(),
                      min: 5,
                      max: 60,
                      divisions: 11,
                      label: '${draft.weeklyGoalMinutes} min',
                      onChanged: (value) => save(
                        draft.copyWith(weeklyGoalMinutes: value.round()),
                      ),
                    ),
                    Text('${draft.weeklyGoalMinutes} minutes par semaine'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showProfilePanel(BuildContext context) async {
    var draft = settings;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void save(AppSettings next) {
              setSheetState(() => draft = next);
              onSettingsChanged(next);
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text('Profil enfant',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text('Profil actif',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final profile in profiles)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(_avatarIcon(profile.settings.avatarId)),
                      title: Text(profile.settings.childName),
                      subtitle: Text(_avatarLabel(profile.settings.avatarId)),
                      trailing: profile.id == settings.profileId
                          ? const Icon(Icons.check_circle_rounded)
                          : const Icon(Icons.circle_outlined),
                      onTap: () {
                        Navigator.of(context).pop();
                        onProfileSelected(profile.id);
                      },
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await onProfileCreated();
                    },
                    icon: const Icon(Icons.person_add_rounded),
                    label: const Text('Ajouter un profil'),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: draft.childName,
                    decoration: const InputDecoration(
                      labelText: 'Renommer le profil actif',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => save(
                      draft.copyWith(childName: value),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(_avatarIcon(draft.avatarId)),
                    title: Text(_avatarLabel(draft.avatarId)),
                    trailing: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showAvatarPanel(context);
                      },
                      icon: const Icon(Icons.palette_rounded),
                      label: const Text('Avatar'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: profiles.length <= 1
                        ? null
                        : () => _confirmDeleteProfile(context),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Supprimer ce profil'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteProfile(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le profil'),
          content: Text(
            'Supprimer ${settings.childName} et sa progression locale ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true) {
      return;
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    await onProfileDeleted(settings.profileId);
  }

  Future<void> _showAvatarPanel(BuildContext context) async {
    var draft = settings;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void save(AvatarId avatarId) {
              final next = draft.copyWith(avatarId: avatarId);
              setSheetState(() => draft = next);
              onSettingsChanged(next);
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text('Choisir un avatar',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  for (final avatarId in AvatarId.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: OutlinedButton.icon(
                        onPressed: () => save(avatarId),
                        icon: Icon(_avatarIcon(avatarId)),
                        label: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_avatarLabel(avatarId)),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: avatarId == draft.avatarId
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showRewardsPanel(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text('Recompenses',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              for (final reward in _allRewards)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    reward.icon,
                    color: progressOverview.rewardIds.contains(reward.id)
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).disabledColor,
                  ),
                  title: Text(reward.label),
                  subtitle: Text(reward.description),
                  trailing: progressOverview.rewardIds.contains(reward.id)
                      ? const Icon(Icons.check_circle_rounded)
                      : const Icon(Icons.lock_outline_rounded),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showMiniGamesPanel(
    BuildContext context,
    KeyboardLayout selectedLayout,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text('Mini-jeux', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _MiniGameTile(
                icon: Icons.air_rounded,
                title: 'Ballons',
                subtitle: 'Lettres qui montent, rythme tranquille.',
                isUnlocked: _isMiniGameUnlocked(LessonGameType.balloons),
                onTap: () => _startMiniGame(
                  context,
                  selectedLayout,
                  LessonGameType.balloons,
                ),
              ),
              _MiniGameTile(
                icon: Icons.grass_rounded,
                title: 'Taupes',
                subtitle: _isMiniGameUnlocked(LessonGameType.moles)
                    ? 'Une touche apparait, tu la trouves.'
                    : 'Debloque apres F/J puis D/K.',
                isUnlocked: _isMiniGameUnlocked(LessonGameType.moles),
                onTap: () => _startMiniGame(
                  context,
                  selectedLayout,
                  LessonGameType.moles,
                ),
              ),
              _MiniGameTile(
                icon: Icons.local_florist_rounded,
                title: 'Jardin',
                subtitle: _isMiniGameUnlocked(LessonGameType.garden)
                    ? 'Mode calme pour faire pousser les mots.'
                    : 'Debloque apres le village de repos.',
                isUnlocked: _isMiniGameUnlocked(LessonGameType.garden),
                onTap: () => _startMiniGame(
                  context,
                  selectedLayout,
                  LessonGameType.garden,
                ),
              ),
              _MiniGameTile(
                icon: Icons.rocket_launch_rounded,
                title: 'Vaisseau',
                subtitle: _isMiniGameUnlocked(LessonGameType.spaceship)
                    ? 'Un rayon aide les majuscules et symboles.'
                    : 'Debloque apres les premieres phrases.',
                isUnlocked: _isMiniGameUnlocked(LessonGameType.spaceship),
                onTap: () => _startMiniGame(
                  context,
                  selectedLayout,
                  LessonGameType.spaceship,
                ),
              ),
              _MiniGameTile(
                icon: Icons.directions_run_rounded,
                title: 'Course',
                subtitle: _isMiniGameUnlocked(LessonGameType.race)
                    ? 'Chaque mot fait avancer le parcours.'
                    : 'Debloque apres la premiere pratique de mots.',
                isUnlocked: _isMiniGameUnlocked(LessonGameType.race),
                onTap: () => _startMiniGame(
                  context,
                  selectedLayout,
                  LessonGameType.race,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isMiniGameUnlocked(LessonGameType gameType) {
    return switch (gameType) {
      LessonGameType.balloons => true,
      LessonGameType.moles =>
        progressOverview.completedLessons.contains('home_row_02'),
      LessonGameType.garden =>
        progressOverview.completedLessons.contains('home_row_06'),
      LessonGameType.spaceship =>
        progressOverview.completedLessons.contains('practice_sentences_01'),
      LessonGameType.race =>
        progressOverview.completedLessons.contains('practice_words_01'),
    };
  }

  void _startMiniGame(
    BuildContext context,
    KeyboardLayout selectedLayout,
    LessonGameType gameType,
  ) {
    final lesson = _randomMiniGameActivity(
      selectedLayout: selectedLayout,
      gameType: gameType,
    );
    Navigator.of(context).pop();
    _startLesson(
      context,
      lesson,
      selectedLayout,
      forcedGameType: gameType,
    );
  }

  ActivityDefinition _randomMiniGameActivity({
    required KeyboardLayout selectedLayout,
    required LessonGameType gameType,
  }) {
    final random = math.Random(DateTime.now().microsecondsSinceEpoch);
    final letterKeys = _letterKeysFor(selectedLayout);
    final digitKeys = _availableFrom(selectedLayout, _digitPool);
    final symbolKeys = _availableFrom(selectedLayout, _symbolPool);
    final wordPool = _wordPoolFor(selectedLayout);

    final prompts = switch (gameType) {
      LessonGameType.balloons => _pickMany(random, letterKeys, 12),
      LessonGameType.moles => _pickMany(random, letterKeys, 14),
      LessonGameType.garden => _pickMany(random, wordPool, 8),
      LessonGameType.spaceship => _pickMany(
          random,
          [
            ...letterKeys.take(12),
            ...digitKeys,
            ...symbolKeys,
          ],
          14,
        ),
      LessonGameType.race => _pickMany(random, wordPool, 10),
    };

    final promptMode = switch (gameType) {
      LessonGameType.garden || LessonGameType.race => PromptMode.words,
      _ => PromptMode.keys,
    };

    return ActivityDefinition(
      id: 'mini_game_${gameType.name}_arcade',
      title: _miniGameArcadeTitle(gameType),
      world: 'mini_games_arcade',
      newKeys: prompts
          .where((prompt) => promptMode == PromptMode.keys)
          .toSet()
          .toList(),
      reviewKeys: letterKeys.take(8).toList(),
      requiredAccuracy: 0.9,
      prompts: prompts,
      promptMode: promptMode,
    );
  }

  List<String> _letterKeysFor(KeyboardLayout layout) {
    final keys = layout.rows.expand((row) => row).where((key) {
      return key.length == 1 && RegExp(r'^[A-ZÀÂÄÇÉÈÊËÎÏÔÖÙÛÜ]$').hasMatch(key);
    }).toList();
    keys.shuffle(math.Random(DateTime.now().millisecondsSinceEpoch));
    return keys.isEmpty ? const ['F', 'J', 'D', 'K'] : keys;
  }

  List<String> _availableFrom(KeyboardLayout layout, List<String> pool) {
    return pool.where(layout.contains).toList();
  }

  List<String> _wordPoolFor(KeyboardLayout layout) {
    return _wordPool.where((word) {
      return word
          .toUpperCase()
          .split('')
          .every((character) => layout.contains(character));
    }).toList();
  }

  List<String> _pickMany(math.Random random, List<String> pool, int count) {
    final choices = pool.isEmpty ? const ['F', 'J', 'D', 'K'] : pool;
    return [
      for (var index = 0; index < count; index++)
        choices[random.nextInt(choices.length)],
    ];
  }

  String _miniGameArcadeTitle(LessonGameType gameType) {
    return switch (gameType) {
      LessonGameType.balloons => 'Mini-jeu ballons',
      LessonGameType.moles => 'Mini-jeu taupes',
      LessonGameType.garden => 'Mini-jeu jardin',
      LessonGameType.spaceship => 'Mini-jeu vaisseau',
      LessonGameType.race => 'Mini-jeu course',
    };
  }

  Future<void> _showParentPanel(
    BuildContext context,
    List<ActivityDefinition> selectedLessons,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final latestResults = progressOverview.lastResultByLesson.values
            .toList()
          ..sort((left, right) => left.activityId.compareTo(right.activityId));
        final worldSummaries = _worldSummaries(selectedLessons);
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: ListView(
              children: [
                Text('Parent / enseignant',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text('${progressOverview.completedCount} lecon(s) terminee(s)'),
                const SizedBox(height: 8),
                Text(
                  'Objectif: ${_minutes(progressOverview.recordedPracticeSeconds)} / '
                  '${settings.weeklyGoalMinutes} min enregistrees',
                ),
                const SizedBox(height: 12),
                Text('Progression',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final summary in worldSummaries)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(summary.icon),
                    title: Text(summary.label),
                    subtitle: Text(
                      '${summary.completed} / ${summary.total} activite(s)',
                    ),
                  ),
                const SizedBox(height: 12),
                if (latestResults.isEmpty)
                  const Text('Aucun resultat enregistre.')
                else
                  for (final result in latestResults)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.insights_rounded),
                      title: Text(result.activityId),
                      subtitle: Text(
                        'Precision ${result.accuracyPercent} %, erreurs ${result.errors}',
                      ),
                    ),
                const SizedBox(height: 12),
                Text('Touches a retravailler',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (progressOverview.mostDifficultKeys.isEmpty)
                  const Text('Rien a signaler pour le moment.')
                else
                  for (final stats in progressOverview.mostDifficultKeys)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.keyboard_alt_rounded),
                      title: Text(stats.keyId),
                      subtitle: Text(
                        '${(stats.accuracy * 100).round()} % de precision, '
                        '${stats.errors} erreur(s) sur ${stats.attempts} essai(s)',
                      ),
                    ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: latestResults.isEmpty
                      ? null
                      : () async {
                          await Clipboard.setData(
                            ClipboardData(
                              text: _csvFor(
                                latestResults,
                                progressOverview.keyStats.values,
                              ),
                            ),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('CSV copie.')),
                            );
                          }
                        },
                  icon: const Icon(Icons.content_copy_rounded),
                  label: const Text('Copier CSV'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _copyBackup(context),
                  icon: const Icon(Icons.backup_rounded),
                  label: const Text('Copier sauvegarde'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _showRestoreDialog(context),
                  icon: const Icon(Icons.restore_rounded),
                  label: const Text('Restaurer sauvegarde'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _copyBackup(BuildContext context) async {
    final backup = await LocalBackupStore().exportJson();
    await Clipboard.setData(ClipboardData(text: backup));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sauvegarde copiee.')),
      );
    }
  }

  Future<void> _showRestoreDialog(BuildContext context) async {
    final controller = TextEditingController();
    final rawBackup = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restaurer'),
          content: TextField(
            controller: controller,
            minLines: 5,
            maxLines: 8,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Sauvegarde JSON',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(controller.text),
              icon: const Icon(Icons.restore_rounded),
              label: const Text('Restaurer'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (rawBackup == null || rawBackup.trim().isEmpty) {
      return;
    }

    try {
      await LocalBackupStore().importJson(rawBackup);
      await onBackupRestored();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sauvegarde restauree.')),
        );
      }
    } on FormatException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sauvegarde invalide.')),
        );
      }
    }
  }

  String _csvFor(
    List<LessonResultSnapshot> results,
    Iterable<KeyStats> keyStats,
  ) {
    final sortedKeyStats = keyStats.toList()
      ..sort((left, right) => left.keyId.compareTo(right.keyId));
    final lines = [
      'type,lesson,key,accuracy_percent,correct,errors,attempts,duration_seconds,wpm,difficult_keys,mastered_keys',
      for (final result in results)
        _csvRow([
          'lesson',
          result.activityId,
          '',
          '${result.accuracyPercent}',
          '${result.correctKeystrokes}',
          '${result.errors}',
          '${result.correctKeystrokes + result.errors}',
          '${result.durationSeconds}',
          result.wpm?.toStringAsFixed(1) ?? '',
          result.difficultKeys.join('|'),
          result.masteredKeys.join('|'),
        ]),
      'key_stats',
      for (final stats in sortedKeyStats)
        _csvRow([
          'key',
          '',
          stats.keyId,
          '${(stats.accuracy * 100).round()}',
          '${stats.correct}',
          '${stats.errors}',
          '${stats.attempts}',
          '',
          '',
          '',
          '',
        ]),
    ];
    return lines.join('\n');
  }

  List<_WorldSummary> _worldSummaries(List<ActivityDefinition> lessons) {
    final totals = <String, int>{};
    final completed = <String, int>{};
    for (final lesson in lessons) {
      totals[lesson.world] = (totals[lesson.world] ?? 0) + 1;
      if (progressOverview.completedLessons.contains(lesson.id)) {
        completed[lesson.world] = (completed[lesson.world] ?? 0) + 1;
      }
    }
    return [
      for (final entry in totals.entries)
        _WorldSummary(
          label: _worldLabel(entry.key),
          icon: _worldIcon(entry.key),
          completed: completed[entry.key] ?? 0,
          total: entry.value,
        ),
    ];
  }

  String _worldLabel(String world) {
    return switch (world) {
      'village_home_row' => 'Village des touches de repos',
      'forest_top_row' => 'Foret de la rangee superieure',
      'cave_bottom_row' => 'Grotte de la rangee inferieure',
      'word_garden' => 'Jardin des mots',
      'soft_test' => 'Tests doux',
      'castle_phrases' => 'Chateau des phrases',
      _ => world,
    };
  }

  IconData _worldIcon(String world) {
    return switch (world) {
      'village_home_row' => Icons.home_work_rounded,
      'forest_top_row' => Icons.park_rounded,
      'cave_bottom_row' => Icons.terrain_rounded,
      'word_garden' => Icons.local_florist_rounded,
      'soft_test' => Icons.flag_rounded,
      'castle_phrases' => Icons.castle_rounded,
      _ => Icons.map_rounded,
    };
  }

  String _csvRow(List<String> cells) => cells.map(_csvCell).join(',');

  String _csvCell(String value) {
    if (!value.contains(',') && !value.contains('"') && !value.contains('\n')) {
      return value;
    }
    return '"${value.replaceAll('"', '""')}"';
  }

  int _minutes(int seconds) => (seconds / 60).ceil();

  IconData _avatarIcon(AvatarId avatarId) {
    return switch (avatarId) {
      AvatarId.comet => Icons.rocket_launch_rounded,
      AvatarId.flower => Icons.local_florist_rounded,
      AvatarId.star => Icons.star_rounded,
    };
  }

  String _avatarLabel(AvatarId avatarId) {
    return switch (avatarId) {
      AvatarId.comet => 'Fusee',
      AvatarId.flower => 'Jardin',
      AvatarId.star => 'Etoile',
    };
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({
    required this.layoutLabel,
    required this.childName,
    required this.avatarId,
    required this.visualPreset,
    required this.progressOverview,
    required this.onChooseAvatar,
    required this.onShowRewards,
    required this.onShowMiniGames,
  });

  final String childName;
  final AvatarId avatarId;
  final String layoutLabel;
  final VisualPreset visualPreset;
  final ProgressOverview progressOverview;
  final VoidCallback onChooseAvatar;
  final VoidCallback onShowRewards;
  final VoidCallback onShowMiniGames;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_avatarIcon(avatarId), size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Parcours des touches',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Bonjour $childName. Choisis une lecon et avance doucement.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Chip(
                avatar: const Icon(
                  Icons.star_rounded,
                  color: Color(0xffffc107),
                ),
                label: Text('${progressOverview.starWallet} etoile(s)'),
              ),
              OutlinedButton.icon(
                onPressed: onChooseAvatar,
                icon: const Icon(Icons.palette_rounded),
                label: const Text('Avatar'),
              ),
              OutlinedButton.icon(
                onPressed: onShowRewards,
                icon: const Icon(Icons.workspace_premium_rounded),
                label: const Text('Recompenses'),
              ),
              OutlinedButton.icon(
                onPressed: onShowMiniGames,
                icon: const Icon(Icons.sports_esports_rounded),
                label: const Text('Mini-jeux'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Chip(label: Text('Clavier $layoutLabel')),
              Chip(
                  label: Text(
                      '${progressOverview.completedCount} lecon(s) terminee(s)')),
              Chip(label: Text(_presetLabel(visualPreset))),
            ],
          ),
          const SizedBox(height: 18),
          _RewardShelf(rewardIds: progressOverview.rewardIds),
        ],
      ),
    );
  }

  String _presetLabel(VisualPreset preset) {
    return switch (preset) {
      VisualPreset.standard => 'Standard',
      VisualPreset.highContrast => 'Contraste eleve',
      VisualPreset.lowVision => 'Tres lisible',
      VisualPreset.grayscale => 'Niveaux de gris',
    };
  }

  IconData _avatarIcon(AvatarId avatarId) {
    return switch (avatarId) {
      AvatarId.comet => Icons.rocket_launch_rounded,
      AvatarId.flower => Icons.local_florist_rounded,
      AvatarId.star => Icons.star_rounded,
    };
  }
}

class _RewardShelf extends StatelessWidget {
  const _RewardShelf({required this.rewardIds});

  final Set<String> rewardIds;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final reward
            in _allRewards.where((reward) => rewardIds.contains(reward.id)))
          Chip(
            avatar: Icon(
              reward.icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: Text(reward.label),
          ),
      ],
    );
  }
}

class _Reward {
  const _Reward(this.id, this.icon, this.label, this.description);

  final String id;
  final IconData icon;
  final String label;
  final String description;
}

const _allRewards = [
  _Reward('sticker_fj', Icons.touch_app_rounded, 'F/J',
      'Terminer la premiere lecon F, J et espace.'),
  _Reward('badge_calme', Icons.self_improvement_rounded, 'Calme',
      'Terminer trois lecons avec patience.'),
  _Reward('etoile_precision', Icons.star_rounded, 'Precision',
      'Atteindre au moins 95 % de precision.'),
  _Reward('couronne_home_row', Icons.workspace_premium_rounded, 'Village',
      'Terminer tout le village des touches.'),
  _Reward('badge_foret', Icons.park_rounded, 'Foret',
      'Terminer la rangee superieure.'),
  _Reward('badge_grotte', Icons.terrain_rounded, 'Grotte',
      'Terminer la rangee inferieure.'),
  _Reward('sticker_syllabes', Icons.short_text_rounded, 'Syllabes',
      'Terminer la premiere pratique de syllabes.'),
  _Reward('sticker_mots', Icons.abc_rounded, 'Mots',
      'Terminer la premiere pratique de mots.'),
  _Reward('ruban_test_doux', Icons.flag_rounded, 'Test doux',
      'Terminer un test doux sans classement.'),
  _Reward('badge_majuscules', Icons.text_fields_rounded, 'Majuscules',
      'Terminer la premiere lecon de majuscules.'),
  _Reward('badge_chiffres', Icons.pin_rounded, 'Chiffres',
      'Terminer la premiere lecon de chiffres.'),
  _Reward('badge_symboles', Icons.alternate_email_rounded, 'Symboles',
      'Terminer la premiere lecon de ponctuation.'),
  _Reward('badge_accents', Icons.spellcheck_rounded, 'Accents',
      'Terminer la premiere lecon avec accents francais.'),
  _Reward('badge_paragraphe', Icons.notes_rounded, 'Paragraphe',
      'Terminer le premier paragraphe court.'),
];

const _digitPool = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];

const _symbolPool = [',', ';', ':', '!', '.', '/'];

const _wordPool = [
  'ami',
  'lit',
  'moto',
  'robot',
  'soleil',
  'lune',
  'jardin',
  'ballon',
  'fusée',
  'voiture',
  'route',
  'fleur',
  'taupe',
  'maison',
  'chat',
  'koala',
  'piano',
  'banane',
  'tomate',
  'nuage',
  'pirate',
  'cadeau',
  'orange',
  'village',
  'magie',
  'navire',
  'radis',
  'comete',
  'ruban',
  'cactus',
];

class _WorldSummary {
  const _WorldSummary({
    required this.label,
    required this.icon,
    required this.completed,
    required this.total,
  });

  final String label;
  final IconData icon;
  final int completed;
  final int total;
}

class _MiniGameTile extends StatelessWidget {
  const _MiniGameTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isUnlocked,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isUnlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        leading: Icon(
          isUnlocked ? icon : Icons.lock_outline_rounded,
          color: isUnlocked
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).disabledColor,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: Icon(
          isUnlocked ? Icons.play_arrow_rounded : Icons.lock_outline_rounded,
        ),
        enabled: isUnlocked,
        onTap: isUnlocked ? onTap : null,
      ),
    );
  }
}

class _LessonList extends StatefulWidget {
  const _LessonList({
    required this.lessons,
    required this.progressOverview,
    required this.onStartLesson,
  });

  final List<ActivityDefinition> lessons;
  final ProgressOverview progressOverview;
  final ValueChanged<ActivityDefinition> onStartLesson;

  @override
  State<_LessonList> createState() => _LessonListState();
}

class _LessonListState extends State<_LessonList> {
  late List<GlobalKey> _itemKeys;

  @override
  void initState() {
    super.initState();
    _itemKeys = List.generate(widget.lessons.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
  }

  @override
  void didUpdateWidget(covariant _LessonList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessons.length != widget.lessons.length) {
      _itemKeys = List.generate(widget.lessons.length, (_) => GlobalKey());
    }
    if (oldWidget.lessons != widget.lessons ||
        oldWidget.progressOverview.completedLessons !=
            widget.progressOverview.completedLessons) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.lessons.length,
      itemBuilder: (context, index) {
        final lesson = widget.lessons[index];
        return Padding(
          key: _itemKeys[index],
          padding: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            leading: Icon(
              widget.progressOverview.completedLessons.contains(lesson.id)
                  ? Icons.check_circle_rounded
                  : Icons.keyboard_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              lesson.title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(_subtitleFor(lesson)),
            trailing: const Icon(Icons.play_arrow_rounded),
            onTap: () => widget.onStartLesson(lesson),
          ),
        );
      },
    );
  }

  String _subtitleFor(ActivityDefinition lesson) {
    final best = widget.progressOverview.bestAccuracyByLesson[lesson.id];
    final suffix = best == null ? '' : ' - meilleur $best %';
    return 'Touches: ${lesson.allowedKeys.join(', ')}$suffix';
  }

  void _scrollToCurrent() {
    if (!mounted || widget.lessons.isEmpty) {
      return;
    }
    final currentIndex = widget.lessons.indexWhere(
      (lesson) => !widget.progressOverview.completedLessons.contains(lesson.id),
    );
    final index = currentIndex == -1 ? widget.lessons.length - 1 : currentIndex;
    final context = _itemKeys[index].currentContext;
    if (context == null) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      alignment: 0.45,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }
}
