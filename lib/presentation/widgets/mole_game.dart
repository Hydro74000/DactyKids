import 'package:flutter/material.dart';

class MoleGame extends StatelessWidget {
  const MoleGame({
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
    return Semantics(
      label: 'Mini-jeu taupes. Prompt actuel $prompt.',
      child: SizedBox(
        width: 240,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 18,
              child: Container(
                width: 220,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  border: Border.all(color: scheme.onSurface, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            AnimatedPositioned(
              key: ValueKey(feedbackPulse),
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              bottom: 48,
              child: Container(
                width: 150,
                height: 128,
                decoration: BoxDecoration(
                  color: scheme.secondary,
                  border: Border.all(color: scheme.onSurface, width: 4),
                  borderRadius: BorderRadius.circular(72),
                ),
                child: Center(
                  child: Text(
                    prompt == 'SPACE' ? 'espace' : prompt,
                    style: TextStyle(
                      color: scheme.onSecondary,
                      fontSize: prompt == 'SPACE' ? 28 : 64,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
