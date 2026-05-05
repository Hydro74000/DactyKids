import 'dart:math' as math;

import 'package:flutter/material.dart';

const _spaceBackgroundAsset = 'assets/images/game/space_background.png';
const _rocketSpriteAsset = 'assets/images/game/rocket_sprite.png';

class SpaceshipGame extends StatefulWidget {
  const SpaceshipGame({
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
  State<SpaceshipGame> createState() => _SpaceshipGameState();
}

class _SpaceshipGameState extends State<SpaceshipGame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    if (!widget.reduceMotion) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SpaceshipGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reduceMotion != oldWidget.reduceMotion) {
      widget.reduceMotion ? _controller.stop() : _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promptLabel = widget.prompt == 'SPACE' ? 'espace' : widget.prompt;
    final routeProgress = widget.progress.clamp(0.0, 1.0);
    final routeIndex = (routeProgress * (_planetRoute.length - 1)).round();
    final rocketAlignment = Alignment.lerp(
      _planetRoute[routeIndex],
      const Alignment(0, -0.06),
      0.28,
    )!;
    return Semantics(
      label: 'Mini-jeu vaisseau. Prompt actuel $promptLabel.',
      child: SizedBox(
        width: 340,
        height: 260,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                _spaceBackgroundAsset,
                fit: BoxFit.cover,
                semanticLabel: 'Decor spatial avec planetes.',
              ),
              for (var index = 0; index < _planetRoute.length; index++)
                _PlanetStop(
                  alignment: _planetRoute[index],
                  isReached: index <= routeIndex,
                  index: index,
                ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final wave = widget.reduceMotion
                      ? 0.0
                      : math.sin(_controller.value * math.pi * 2);
                  return AnimatedAlign(
                    duration: widget.reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 460),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment(
                      rocketAlignment.x,
                      rocketAlignment.y + wave * 0.06,
                    ),
                    child: child,
                  );
                },
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(widget.feedbackPulse),
                  tween: Tween<double>(
                    begin: widget.reduceMotion
                        ? 1
                        : widget.isPositive
                            ? 0.82
                            : 1.06,
                    end: 1,
                  ),
                  duration: widget.reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 520),
                  curve: widget.isPositive
                      ? Curves.easeOutBack
                      : Curves.elasticOut,
                  builder: (context, scale, child) {
                    final tilt = widget.reduceMotion || widget.isPositive
                        ? 0.0
                        : math.sin((1 - scale) * math.pi * 8) * 0.08;
                    return Transform.rotate(
                      angle: tilt,
                      child: Transform.scale(scale: scale, child: child),
                    );
                  },
                  child: SizedBox(
                    width: 170,
                    height: 210,
                    child: Image.asset(
                      _rocketSpriteAsset,
                      fit: BoxFit.contain,
                      semanticLabel: '',
                    ),
                  ),
                ),
              ),
              if (!widget.reduceMotion)
                _RocketFlame(key: ValueKey(widget.feedbackPulse)),
            ],
          ),
        ),
      ),
    );
  }
}

const _planetRoute = [
  Alignment(-0.72, 0.5),
  Alignment(-0.52, -0.24),
  Alignment(0.0, 0.28),
  Alignment(0.48, -0.28),
  Alignment(0.74, 0.42),
];

class _PlanetStop extends StatelessWidget {
  const _PlanetStop({
    required this.alignment,
    required this.isReached,
    required this.index,
  });

  final Alignment alignment;
  final bool isReached;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xffffd166),
      const Color(0xff7bdff2),
      const Color(0xff06d6a0),
      const Color(0xffef476f),
      const Color(0xffbdb2ff),
    ];
    return Align(
      alignment: alignment,
      child: AnimatedScale(
        scale: isReached ? 1.08 : 0.82,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors[index % colors.length].withValues(alpha: 0.82),
            shape: BoxShape.circle,
            border: Border.all(
              color: isReached ? Colors.white : Colors.white54,
              width: isReached ? 3 : 2,
            ),
            boxShadow: isReached
                ? const [
                    BoxShadow(
                      color: Colors.white38,
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: SizedBox(
            width: 34 + index * 4,
            height: 34 + index * 4,
          ),
        ),
      ),
    );
  }
}

class _RocketFlame extends StatelessWidget {
  const _RocketFlame({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 142,
      right: 142,
      bottom: 18,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.75, end: 1),
        duration: const Duration(milliseconds: 180),
        builder: (context, value, child) {
          return Transform.scale(
            scaleY: value,
            alignment: Alignment.topCenter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xfffff3b0),
                    Color(0xffff9f1c),
                    Color(0xffef476f),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const SizedBox(height: 58),
            ),
          );
        },
      ),
    );
  }
}
