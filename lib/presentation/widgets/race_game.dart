import 'package:flutter/material.dart';

class RaceGame extends StatelessWidget {
  const RaceGame({
    super.key,
    required this.prompt,
    required this.feedbackPulse,
    required this.reduceMotion,
  });

  final String prompt;
  final int feedbackPulse;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = 0.12 + (feedbackPulse % 8) * 0.1;
    return Semantics(
      label: 'Mini-jeu course. Prompt actuel $prompt.',
      child: SizedBox(
        width: 280,
        height: 220,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 230,
              constraints: const BoxConstraints(minHeight: 74),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.secondary,
                border: Border.all(color: scheme.onSurface, width: 4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  prompt == 'SPACE' ? 'espace' : prompt,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: scheme.onSecondary,
                    fontSize: prompt.length > 8 ? 30 : 46,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final trackWidth = constraints.maxWidth;
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 18,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        border: Border.all(color: scheme.onSurface, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 220),
                      left: (trackWidth - 54) * progress.clamp(0.0, 1.0),
                      child: Icon(
                        Icons.directions_run_rounded,
                        size: 54,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
