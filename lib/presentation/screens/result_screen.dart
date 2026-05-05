import 'package:flutter/material.dart';

import '../../data/local_storage/progress_store.dart';
import '../../domain/typing_engine/scoring_engine.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.result,
    required this.starAward,
    this.rewardIds = const {},
  });

  final SessionResult result;
  final StarAward starAward;
  final Set<String> rewardIds;

  @override
  Widget build(BuildContext context) {
    final percent = (result.accuracy * 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text('Resultat')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    size: 96,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    percent >= 90
                        ? 'Bravo pour ta precision.'
                        : 'Tu progresses.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _StarScore(award: starAward),
                  const SizedBox(height: 20),
                  _Metric(label: 'Precision', value: '$percent %'),
                  _Metric(
                      label: 'Touches correctes',
                      value: '${result.correctKeystrokes}'),
                  if (result.wpm != null)
                    _Metric(
                        label: 'Rythme indicatif',
                        value: '${result.wpm!.round()} mots/min'),
                  _Metric(
                      label: 'A retravailler doucement',
                      value: _keys(result.difficultKeys)),
                  _Metric(
                      label: 'Bien trouvees',
                      value: _keys(result.masteredKeys)),
                  _Metric(
                    label: 'Portefeuille etoiles',
                    value: starAward.walletGain > 0
                        ? '+${starAward.walletGain} / ${starAward.walletTotal}'
                        : '${starAward.walletTotal}',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (rewardIds.contains('sticker_fj'))
                        const Chip(
                          avatar: Icon(Icons.touch_app_rounded),
                          label: Text('Sticker F/J'),
                        ),
                      if (rewardIds.contains('badge_calme'))
                        const Chip(
                          avatar: Icon(Icons.self_improvement_rounded),
                          label: Text('Badge calme'),
                        ),
                      if (rewardIds.contains('etoile_precision'))
                        const Chip(
                          avatar: Icon(Icons.star_rounded),
                          label: Text('Etoile precision'),
                        ),
                      if (rewardIds.contains('couronne_home_row'))
                        const Chip(
                          avatar: Icon(Icons.workspace_premium_rounded),
                          label: Text('Village complet'),
                        ),
                      if (rewardIds.contains('badge_foret'))
                        const Chip(
                          avatar: Icon(Icons.park_rounded),
                          label: Text('Foret'),
                        ),
                      if (rewardIds.contains('badge_grotte'))
                        const Chip(
                          avatar: Icon(Icons.terrain_rounded),
                          label: Text('Grotte'),
                        ),
                      if (rewardIds.contains('sticker_mots'))
                        const Chip(
                          avatar: Icon(Icons.abc_rounded),
                          label: Text('Mots'),
                        ),
                      if (rewardIds.contains('ruban_test_doux'))
                        const Chip(
                          avatar: Icon(Icons.flag_rounded),
                          label: Text('Test doux'),
                        ),
                      if (rewardIds.contains('badge_accents'))
                        const Chip(
                          avatar: Icon(Icons.spellcheck_rounded),
                          label: Text('Accents'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Retour aux lecons'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _keys(List<String> keys) =>
      keys.isEmpty ? 'Encore en decouverte' : keys.join(', ');
}

class _StarScore extends StatelessWidget {
  const _StarScore({required this.award});

  final StarAward award;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          height: 86,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var index = 0; index < 3; index++)
                    Icon(
                      Icons.star_rounded,
                      size: 58,
                      color: index < award.baseStars
                          ? const Color(0xffffc107)
                          : scheme.surfaceContainerHighest,
                      shadows: index < award.baseStars
                          ? const [
                              Shadow(
                                color: Color(0xfffff3b0),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                ],
              ),
              if (award.isPerfectBonus)
                const Positioned(
                  top: 0,
                  child: Icon(
                    Icons.stars_rounded,
                    size: 70,
                    color: Color(0xffd7e6ff),
                    shadows: [
                      Shadow(color: Colors.white, blurRadius: 16),
                      Shadow(color: Color(0xff9bbcff), blurRadius: 10),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (award.isPerfectBonus)
          Text(
            'Exceptionnel ! Gains Doubles !',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w900,
                ),
          ),
        Text(
          award.walletGain > 0
              ? '${award.walletGain} etoile(s) ajoutee(s)'
              : 'Meilleur score deja recompense',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child:
                  Text(label, style: Theme.of(context).textTheme.titleMedium)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
