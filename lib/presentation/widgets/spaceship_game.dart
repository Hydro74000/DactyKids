import 'package:flutter/material.dart';

class SpaceshipGame extends StatelessWidget {
  const SpaceshipGame({
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
    final beamHeight = reduceMotion ? 80.0 : 54.0 + (feedbackPulse % 3) * 18;
    return Semantics(
      label: 'Mini-jeu vaisseau. Prompt actuel $prompt.',
      child: SizedBox(
        width: 260,
        height: 230,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 18,
              child: Container(
                width: 136,
                height: 82,
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
                      fontSize: prompt == 'SPACE' ? 24 : 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              bottom: 44,
              child: Container(
                width: 58,
                height: beamHeight,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  border: Border.all(color: scheme.primary, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Positioned(
              bottom: 22,
              child: Icon(
                Icons.rocket_launch_rounded,
                size: 72,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
