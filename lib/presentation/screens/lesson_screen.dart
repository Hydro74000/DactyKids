import 'package:flutter/material.dart';

import '../../data/local_storage/progress_store.dart';
import '../../data/local_storage/settings_store.dart';
import '../../domain/keyboard/input_normalizer.dart';
import '../../domain/keyboard/keyboard_layout.dart';
import '../../domain/typing_engine/activity_definition.dart';
import '../../domain/typing_engine/session_controller.dart';
import '../audio/audio_feedback.dart';
import '../widgets/balloon_game.dart';
import '../widgets/garden_game.dart';
import '../widgets/hand_guide.dart';
import '../widgets/mole_game.dart';
import '../widgets/race_game.dart';
import '../widgets/spaceship_game.dart';
import '../widgets/visual_keyboard.dart';
import 'result_screen.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.lesson,
    required this.layout,
    required this.settings,
    required this.profileId,
    required this.progressStore,
    this.forcedGameType,
  });

  final ActivityDefinition lesson;
  final KeyboardLayout layout;
  final AppSettings settings;
  final String profileId;
  final ProgressStore progressStore;
  final LessonGameType? forcedGameType;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _focusNode = FocusNode(debugLabel: 'lesson-input');
  final _normalizer = const InputNormalizer();
  final _audioFeedback = AudioFeedback();
  late TypingSessionController _controller;
  late final DateTime _startedAt;
  int _feedbackPulse = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _controller = TypingSessionController(activity: widget.lesson);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _audioFeedback.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleKey(KeyEvent event) async {
    if (_finished) {
      return;
    }
    final input = _normalizer.normalize(event);
    if (input == null) {
      return;
    }
    final wasComplete = _controller.state.isComplete;
    final match = _controller.handleInput(input);
    if (widget.settings.soundEnabled) {
      match.isCorrect
          ? await _audioFeedback.playCorrect()
          : await _audioFeedback.playError();
    }
    setState(() => _feedbackPulse++);

    if (match.isCorrect && wasComplete) {
      _finished = true;
      if (widget.settings.soundEnabled) {
        await _audioFeedback.playSuccess();
      }
      final result = _controller.result();
      final starAward = await widget.progressStore
          .markLessonComplete(widget.profileId, result);
      final progressOverview =
          await widget.progressStore.loadOverview(widget.profileId);
      if (!mounted) {
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(
            result: result,
            starAward: starAward,
            rewardIds: progressOverview.rewardIds,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final isLowVision = widget.settings.visualPreset == VisualPreset.lowVision;
    final finger = widget.layout.fingerFor(state.currentPrompt);
    final scheme = Theme.of(context).colorScheme;
    final displayPrompt = state.currentDisplayPrompt == state.currentPrompt
        ? state.currentPromptLabel
        : state.currentDisplayPrompt;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        appBar: AppBar(
          title: _LessonHeaderTitle(
            lessonTitle: widget.lesson.title,
            feedbackMessage: state.feedback.message,
            isPositive: state.feedback.isPositive,
          ),
          actions: [
            if (widget.settings.showTimer)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(child: _ElapsedTimer(startedAt: _startedAt)),
              ),
            IconButton(
              tooltip: 'Pause',
              onPressed: _showPause,
              icon: const Icon(Icons.pause_circle_rounded),
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final game = _LessonStage(
                gameType: widget.forcedGameType ?? _gameTypeFor(widget.lesson),
                prompt: state.currentPromptLabel,
                displayPrompt: displayPrompt,
                isPositive: state.feedback.isPositive,
                progress: state.progress,
                errorCount: state.keyStats.values
                    .fold<int>(0, (sum, stats) => sum + stats.errors),
                feedbackPulse: _feedbackPulse,
                reduceMotion: widget.settings.reduceMotion,
              );
              final keyboard = VisualKeyboard(
                layout: widget.layout,
                targetKey: state.currentPrompt,
                useLargeTarget: isLowVision ||
                    !state.feedback.isPositive ||
                    state.assistLevel > 0,
              );
              final lessonAid = _LessonAidPanel(
                finger: finger,
                assistLevel: state.assistLevel,
                showHandGuide: widget.settings.showHandGuide,
                highContrast:
                    widget.settings.visualPreset == VisualPreset.highContrast,
              );

              return Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: state.progress,
                      minHeight: 14,
                      borderRadius: BorderRadius.circular(8),
                      color: scheme.primary,
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: isWide
                          ? Row(
                              children: [
                                Expanded(flex: 3, child: game),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 2,
                                  child: ListView(
                                    children: [
                                      keyboard,
                                      const SizedBox(height: 12),
                                      lessonAid,
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView(
                              children: [
                                game,
                                const SizedBox(height: 20),
                                keyboard,
                                const SizedBox(height: 12),
                                lessonAid,
                              ],
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showPause() async {
    final state = _controller.state;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pause'),
          content: Text(
            'Respire un coup. Prochaine touche: ${state.currentPromptLabel}. '
            'Doigt: ${widget.layout.fingerFor(state.currentPrompt)}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Reprendre'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _finished = false;
                  _feedbackPulse = 0;
                  _controller =
                      TypingSessionController(activity: widget.lesson);
                });
              },
              child: const Text('Recommencer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Quitter'),
            ),
          ],
        );
      },
    );
    _focusNode.requestFocus();
  }
}

class _LessonHeaderTitle extends StatelessWidget {
  const _LessonHeaderTitle({
    required this.lessonTitle,
    required this.feedbackMessage,
    required this.isPositive,
  });

  final String lessonTitle;
  final String feedbackMessage;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Flexible(
          flex: 2,
          child: Text(
            lessonTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isPositive ? scheme.primaryContainer : scheme.errorContainer,
              border: Border.all(
                color: isPositive ? scheme.primary : scheme.error,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              feedbackMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isPositive
                        ? scheme.onPrimaryContainer
                        : scheme.onErrorContainer,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ElapsedTimer extends StatelessWidget {
  const _ElapsedTimer({required this.startedAt});

  final DateTime startedAt;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(seconds: 1), (tick) => tick),
      builder: (context, snapshot) {
        final elapsed = DateTime.now().difference(startedAt);
        final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
        final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
        return Text(
          '$minutes:$seconds',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        );
      },
    );
  }
}

class _LessonStage extends StatelessWidget {
  const _LessonStage({
    required this.gameType,
    required this.prompt,
    required this.displayPrompt,
    required this.isPositive,
    required this.progress,
    required this.errorCount,
    required this.feedbackPulse,
    required this.reduceMotion,
  });

  final LessonGameType gameType;
  final String prompt;
  final String displayPrompt;
  final bool isPositive;
  final double progress;
  final int errorCount;
  final int feedbackPulse;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final promptLabel = displayPrompt == 'SPACE' ? 'espace' : displayPrompt;
    return Semantics(
      liveRegion: true,
      label: 'Touche a taper $promptLabel.',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _GameView(
            gameType: gameType,
            prompt: prompt,
            isPositive: isPositive,
            progress: progress,
            errorCount: errorCount,
            feedbackPulse: feedbackPulse,
            reduceMotion: reduceMotion,
          ),
          const SizedBox(height: 12),
          _PromptDisplay(
            label: promptLabel,
            isSpace: prompt == 'SPACE',
          ),
        ],
      ),
    );
  }
}

class _PromptDisplay extends StatelessWidget {
  const _PromptDisplay({
    required this.label,
    required this.isSpace,
  });

  final String label;
  final bool isSpace;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.displayLarge?.copyWith(
          fontSize: isSpace ? 50 : 76,
          height: 1.04,
          fontWeight: FontWeight.w900,
        );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 660),
          child: Text(
            label,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ),
      ),
    );
  }
}

class _LessonAidPanel extends StatelessWidget {
  const _LessonAidPanel({
    required this.finger,
    required this.assistLevel,
    required this.showHandGuide,
    required this.highContrast,
  });

  final String finger;
  final int assistLevel;
  final bool showHandGuide;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Aide doigt. Utilise $finger.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandGuide) ...[
            HandGuide(
              finger: finger,
              highContrast: highContrast,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            finger,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          if (assistLevel > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Mode aide: prends ton temps, la touche est agrandie.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

enum LessonGameType { balloons, moles, garden, spaceship, race }

LessonGameType _gameTypeFor(ActivityDefinition lesson) {
  if (lesson.world == 'castle_phrases') {
    return LessonGameType.spaceship;
  }
  if (lesson.promptMode == PromptMode.words ||
      lesson.promptMode == PromptMode.sentences ||
      lesson.promptMode == PromptMode.paragraphs) {
    return LessonGameType.race;
  }
  if (lesson.id.endsWith('01') || lesson.id.endsWith('02')) {
    return LessonGameType.balloons;
  }
  if (lesson.world == 'forest_top_row') {
    return LessonGameType.garden;
  }
  return LessonGameType.moles;
}

class _GameView extends StatelessWidget {
  const _GameView({
    required this.gameType,
    required this.prompt,
    required this.isPositive,
    required this.progress,
    required this.errorCount,
    required this.feedbackPulse,
    required this.reduceMotion,
  });

  final LessonGameType gameType;
  final String prompt;
  final bool isPositive;
  final double progress;
  final int errorCount;
  final int feedbackPulse;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return switch (gameType) {
      LessonGameType.balloons => BalloonGame(
          prompt: prompt,
          isPositive: isPositive,
          feedbackPulse: feedbackPulse,
          reduceMotion: reduceMotion,
        ),
      LessonGameType.moles => MoleGame(
          prompt: prompt,
          isPositive: isPositive,
          progress: progress,
          feedbackPulse: feedbackPulse,
          reduceMotion: reduceMotion,
        ),
      LessonGameType.garden => GardenGame(
          prompt: prompt,
          isPositive: isPositive,
          progress: progress,
          feedbackPulse: feedbackPulse,
          reduceMotion: reduceMotion,
        ),
      LessonGameType.spaceship => SpaceshipGame(
          prompt: prompt,
          isPositive: isPositive,
          progress: progress,
          feedbackPulse: feedbackPulse,
          reduceMotion: reduceMotion,
        ),
      LessonGameType.race => RaceGame(
          prompt: prompt,
          isPositive: isPositive,
          progress: progress,
          errorCount: errorCount,
          feedbackPulse: feedbackPulse,
          reduceMotion: reduceMotion,
        ),
    };
  }
}
