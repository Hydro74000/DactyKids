import 'package:flutter/material.dart';

class GardenGame extends StatelessWidget {
  const GardenGame({
    super.key,
    required this.prompt,
    required this.isPositive,
    required this.progress,
    required this.feedbackPulse,
    required this.reduceMotion,
  });

  final String prompt;
  final bool isPositive;
  final double progress;
  final int feedbackPulse;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final promptLabel = prompt == 'SPACE' ? 'espace' : prompt;
    final growth = progress.clamp(0.08, 1.0);
    final flowerCount = (1 + growth * (_flowerBeds.length - 1)).ceil();
    return Semantics(
      label: 'Mini-jeu jardin. Prompt actuel $promptLabel.',
      child: SizedBox(
        width: 340,
        height: 260,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/game/garden_background.png',
                fit: BoxFit.cover,
                semanticLabel: 'Decor de jardin ensoleille.',
              ),
              for (var index = 0; index < _flowerBeds.length; index++)
                _GrowingFlower(
                  key: ValueKey('flower-$index-$feedbackPulse'),
                  bed: _flowerBeds[index],
                  isVisible: index < flowerCount,
                  growth: (growth + index * 0.1).clamp(0.2, 1.15),
                  reduceMotion: reduceMotion,
                ),
              if (!reduceMotion && isPositive && feedbackPulse > 0)
                _GardenGlow(key: ValueKey(feedbackPulse)),
            ],
          ),
        ),
      ),
    );
  }
}

const _flowerBeds = [
  _FlowerBed(alignment: Alignment(0, 0.52), height: 190),
  _FlowerBed(alignment: Alignment(-0.42, 0.62), height: 132),
  _FlowerBed(alignment: Alignment(0.42, 0.62), height: 132),
  _FlowerBed(alignment: Alignment(-0.68, 0.2), height: 94),
  _FlowerBed(alignment: Alignment(0.66, 0.18), height: 96),
  _FlowerBed(alignment: Alignment(-0.18, 0.06), height: 112),
];

class _FlowerBed {
  const _FlowerBed({
    required this.alignment,
    required this.height,
  });

  final Alignment alignment;
  final double height;
}

class _GrowingFlower extends StatelessWidget {
  const _GrowingFlower({
    super.key,
    required this.bed,
    required this.isVisible,
    required this.growth,
    required this.reduceMotion,
  });

  final _FlowerBed bed;
  final bool isVisible;
  final double growth;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: bed.alignment,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration:
            reduceMotion ? Duration.zero : const Duration(milliseconds: 260),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: reduceMotion ? growth : growth * 0.68,
            end: isVisible ? growth : 0.2,
          ),
          curve: Curves.easeOutBack,
          duration:
              reduceMotion ? Duration.zero : const Duration(milliseconds: 560),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              alignment: Alignment.bottomCenter,
              child: child,
            );
          },
          child: Image.asset(
            'assets/images/game/garden_flower.png',
            height: bed.height,
            fit: BoxFit.contain,
            semanticLabel: '',
          ),
        ),
      ),
    );
  }
}

class _GardenGlow extends StatelessWidget {
  const _GardenGlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 98,
      right: 98,
      bottom: 34,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        builder: (context, value, child) {
          return Opacity(
            opacity: 1 - value,
            child: Transform.scale(
              scale: 0.65 + value * 1.35,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.28),
                  border: Border.all(
                    color: const Color(0xffffd166).withValues(alpha: 0.75),
                    width: 3,
                  ),
                ),
                child: const SizedBox(height: 120),
              ),
            ),
          );
        },
      ),
    );
  }
}
