import 'package:flutter/material.dart';

class GardenGame extends StatelessWidget {
  const GardenGame({
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
    final sproutHeight = 80.0 + (feedbackPulse % 4) * 18.0;
    return Semantics(
      label: 'Mini-jeu jardin. Prompt actuel $prompt.',
      child: SizedBox(
        width: 240,
        height: 230,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 230,
              height: 48,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                border: Border.all(color: scheme.onSurface, width: 3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            AnimatedContainer(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 260),
              width: 22,
              height: sproutHeight,
              margin: const EdgeInsets.only(bottom: 38),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Positioned(
              bottom: sproutHeight + 24,
              child: Container(
                width: 136,
                height: 104,
                decoration: BoxDecoration(
                  color: scheme.secondary,
                  border: Border.all(color: scheme.onSurface, width: 4),
                  borderRadius: BorderRadius.circular(56),
                ),
                child: Center(
                  child: Text(
                    prompt == 'SPACE' ? 'espace' : prompt,
                    style: TextStyle(
                      color: scheme.onSecondary,
                      fontSize: prompt == 'SPACE' ? 26 : 58,
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
