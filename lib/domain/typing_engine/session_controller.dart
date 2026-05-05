import '../keyboard/input_normalizer.dart';
import 'activity_definition.dart';
import 'prompt_matcher.dart';
import 'scoring_engine.dart';

class SessionFeedback {
  const SessionFeedback({
    required this.message,
    required this.isPositive,
  });

  final String message;
  final bool isPositive;
}

class TypingSessionState {
  const TypingSessionState({
    required this.activity,
    required this.promptIndex,
    required this.keyStats,
    required this.feedback,
    required this.consecutiveErrors,
    required this.assistLevel,
  });

  final ActivityDefinition activity;
  final int promptIndex;
  final Map<String, KeyStats> keyStats;
  final SessionFeedback feedback;
  final int consecutiveErrors;
  final int assistLevel;

  String get currentPrompt => _flattenedPrompts[promptIndex];
  String get currentPromptLabel => PromptKey.display(currentPrompt);
  String get currentDisplayPrompt => activity.promptMode != PromptMode.keys
      ? _wordDisplayPrompt
      : currentPrompt;
  bool get isComplete => promptIndex >= _flattenedPrompts.length - 1;
  double get progress => (promptIndex + 1) / _flattenedPrompts.length;

  List<String> get _flattenedPrompts {
    if (activity.promptMode == PromptMode.keys) {
      return activity.prompts;
    }
    return [
      for (final prompt in activity.prompts) ..._charactersFor(prompt),
    ];
  }

  String get _wordDisplayPrompt {
    var remaining = promptIndex;
    for (final prompt in activity.prompts) {
      final length = _charactersFor(prompt).length;
      if (remaining < length) {
        return prompt;
      }
      remaining -= length;
    }
    return activity.prompts.last;
  }

  TypingSessionState copyWith({
    int? promptIndex,
    Map<String, KeyStats>? keyStats,
    SessionFeedback? feedback,
    int? consecutiveErrors,
    int? assistLevel,
  }) {
    return TypingSessionState(
      activity: activity,
      promptIndex: promptIndex ?? this.promptIndex,
      keyStats: keyStats ?? this.keyStats,
      feedback: feedback ?? this.feedback,
      consecutiveErrors: consecutiveErrors ?? this.consecutiveErrors,
      assistLevel: assistLevel ?? this.assistLevel,
    );
  }
}

List<String> _charactersFor(String prompt) {
  return prompt.split('').map((character) {
    if (character == ' ') {
      return 'SPACE';
    }
    final upper = character.toUpperCase();
    final lower = character.toLowerCase();
    if (upper != lower && character == upper) {
      return 'SHIFT+$upper';
    }
    return upper;
  }).toList();
}

class TypingSessionController {
  TypingSessionController({
    required ActivityDefinition activity,
    PromptMatcher matcher = const PromptMatcher(),
    ScoringEngine scoring = const ScoringEngine(),
    DateTime? startedAt,
  })  : _matcher = matcher,
        _scoring = scoring,
        _startedAt = startedAt ?? DateTime.now(),
        state = TypingSessionState(
          activity: activity,
          promptIndex: 0,
          keyStats: const {},
          consecutiveErrors: 0,
          assistLevel: 0,
          feedback: const SessionFeedback(
            message: 'Trouve la premiere touche.',
            isPositive: true,
          ),
        );

  final PromptMatcher _matcher;
  final ScoringEngine _scoring;
  final DateTime _startedAt;
  TypingSessionState state;

  PromptMatch handleInput(NormalizedInput input) {
    final match = _matcher.match(state.currentPrompt, input);
    final updatedStats = _scoring.record(state.keyStats, match);
    final nextIndex = match.isCorrect && !state.isComplete
        ? state.promptIndex + 1
        : state.promptIndex;
    final consecutiveErrors = match.isCorrect ? 0 : state.consecutiveErrors + 1;
    final assistLevel = match.isCorrect
        ? (state.assistLevel > 0 ? state.assistLevel - 1 : 0)
        : (consecutiveErrors >= 2 ? 1 : state.assistLevel);

    state = state.copyWith(
      promptIndex: nextIndex,
      keyStats: updatedStats,
      feedback: _feedbackFor(match),
      consecutiveErrors: consecutiveErrors,
      assistLevel: assistLevel,
    );
    return match;
  }

  SessionResult result() {
    return _scoring.result(
      activityId: state.activity.id,
      keyStats: state.keyStats,
      duration: DateTime.now().difference(_startedAt),
    );
  }

  SessionFeedback _feedbackFor(PromptMatch match) {
    if (match.quality == MatchQuality.exact) {
      return const SessionFeedback(
          message: 'Belle precision.', isPositive: true);
    }
    if (match.quality == MatchQuality.nearMiss) {
      return SessionFeedback(
        message: 'Presque. La bonne touche est ${match.expectedKey}.',
        isPositive: false,
      );
    }
    return SessionFeedback(
      message: 'Essaie doucement la touche ${match.expectedKey}.',
      isPositive: false,
    );
  }
}
