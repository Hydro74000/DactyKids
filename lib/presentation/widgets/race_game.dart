import 'package:flutter/material.dart';

const _raceBackgroundAsset = 'assets/images/game/race_background.png';

class RaceGame extends StatelessWidget {
  const RaceGame({
    super.key,
    required this.prompt,
    required this.isPositive,
    required this.progress,
    required this.errorCount,
    required this.feedbackPulse,
    required this.reduceMotion,
  });

  final String prompt;
  final bool isPositive;
  final double progress;
  final int errorCount;
  final int feedbackPulse;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final promptLabel = prompt == 'SPACE' ? 'espace' : prompt;
    final raceProgress = progress.clamp(0.0, 1.0);
    final damage = errorCount.clamp(0, 10);

    return Semantics(
      label: 'Mini-jeu course. Prompt actuel $promptLabel.',
      child: SizedBox(
        width: 340,
        height: 260,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const carWidth = 158.0;
              final trackWidth = constraints.maxWidth - carWidth - 20;
              final carLeft = 10 + trackWidth * raceProgress;

              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _raceBackgroundAsset,
                    fit: BoxFit.cover,
                    semanticLabel: 'Decor de piste de course.',
                  ),
                  AnimatedPositioned(
                    left: carLeft,
                    bottom: isPositive ? 34 : 44,
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 380),
                    curve: isPositive ? Curves.easeOutCubic : Curves.elasticOut,
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey(feedbackPulse),
                      tween: Tween<double>(
                        begin: reduceMotion
                            ? 0
                            : isPositive
                                ? -10
                                : 12,
                        end: 0,
                      ),
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 420),
                      curve: Curves.elasticOut,
                      builder: (context, dy, child) {
                        return Transform.translate(
                          offset: Offset(0, dy),
                          child: child,
                        );
                      },
                      child: _RaceCar(
                        damage: damage,
                        isPositive: isPositive,
                      ),
                    ),
                  ),
                  if (!reduceMotion && isPositive && feedbackPulse > 0)
                    _SpeedLines(key: ValueKey(feedbackPulse)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RaceCar extends StatelessWidget {
  const _RaceCar({
    required this.damage,
    required this.isPositive,
  });

  final int damage;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final wobble = !isPositive && damage > 0 ? -0.07 : 0.0;
    final carAsset =
        'assets/images/game/cars/race_car_damage_${damage.toString().padLeft(2, '0')}.png';

    return Transform.rotate(
      angle: wobble,
      child: SizedBox(
        width: 158,
        height: 108,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Image.asset(
                carAsset,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                semanticLabel: '',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedLines extends StatelessWidget {
  const _SpeedLines({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 22,
      bottom: 82,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 360),
        builder: (context, value, child) {
          return Opacity(
            opacity: 1 - value,
            child: Transform.translate(
              offset: Offset(value * 34, 0),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SpeedLine(width: 82),
                  SizedBox(height: 8),
                  _SpeedLine(width: 54),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SpeedLine extends StatelessWidget {
  const _SpeedLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(width: width, height: 6),
    );
  }
}
