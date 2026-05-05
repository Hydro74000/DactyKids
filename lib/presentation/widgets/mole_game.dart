import 'package:flutter/material.dart';

const _moleBackgroundAsset = 'assets/images/game/mole_background.png';
const _moleSpriteAsset = 'assets/images/game/mole_sprite.png';

class MoleGame extends StatelessWidget {
  const MoleGame({
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
    final visibleMoles = (1 + progress.clamp(0, 1) * 4).ceil();
    final activeSlot = (visibleMoles - 1).clamp(0, _moleSlots.length - 1);
    return Semantics(
      label: 'Mini-jeu taupes. Prompt actuel $promptLabel.',
      child: SizedBox(
        width: 340,
        height: 260,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                _moleBackgroundAsset,
                fit: BoxFit.cover,
                semanticLabel: 'Decor de prairie avec trous de taupe.',
              ),
              for (var index = 0; index < _moleSlots.length; index++)
                _MoleInHole(
                  key: ValueKey('mole-$index-$visibleMoles-$feedbackPulse'),
                  alignment: _moleSlots[index],
                  isVisible: index < visibleMoles,
                  isActive: index == activeSlot,
                  isPositive: isPositive,
                  reduceMotion: reduceMotion,
                ),
              if (!reduceMotion && isPositive && feedbackPulse > 0)
                _SoilPuffs(
                  key: ValueKey(feedbackPulse),
                  alignment: _moleSlots[activeSlot],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

const _moleSlots = [
  Alignment(-0.58, 0.28),
  Alignment(0.0, 0.2),
  Alignment(0.56, 0.24),
  Alignment(-0.08, 0.56),
  Alignment(0.42, 0.56),
];

class _MoleInHole extends StatelessWidget {
  const _MoleInHole({
    super.key,
    required this.alignment,
    required this.isVisible,
    required this.isActive,
    required this.isPositive,
    required this.reduceMotion,
  });

  final Alignment alignment;
  final bool isVisible;
  final bool isActive;
  final bool isPositive;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final rise = isVisible ? 0.0 : 74.0;
    final width = isActive ? 158.0 : 124.0;
    return Align(
      alignment: alignment,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration:
            reduceMotion ? Duration.zero : const Duration(milliseconds: 240),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: reduceMotion
                ? rise
                : isVisible
                    ? 58
                    : rise,
            end: rise,
          ),
          duration:
              reduceMotion ? Duration.zero : const Duration(milliseconds: 420),
          curve: Curves.easeOutBack,
          builder: (context, dy, child) {
            final shake = reduceMotion || isPositive || !isActive
                ? 0.0
                : (1 - (dy / 58).clamp(0, 1)) * 8;
            return Transform.translate(
              offset: Offset(shake.toDouble(), dy),
              child: child,
            );
          },
          child: SizedBox(
            width: width,
            height: 148,
            child: Image.asset(
              _moleSpriteAsset,
              fit: BoxFit.contain,
              semanticLabel: '',
            ),
          ),
        ),
      ),
    );
  }
}

class _SoilPuffs extends StatelessWidget {
  const _SoilPuffs({
    super.key,
    required this.alignment,
  });

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 380),
        builder: (context, value, child) {
          return Transform.translate(
            offset: const Offset(0, 60),
            child: Opacity(
              opacity: 1 - value,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16 + value * 18,
                children: const [
                  _DirtDot(size: 12),
                  _DirtDot(size: 16),
                  _DirtDot(size: 10),
                  _DirtDot(size: 14),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DirtDot extends StatelessWidget {
  const _DirtDot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xff8f5d30),
        shape: BoxShape.circle,
      ),
      child: SizedBox(width: size, height: size),
    );
  }
}
