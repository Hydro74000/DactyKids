import 'dart:math' as math;

import 'package:flutter/material.dart';

const _balloonBackgroundAsset = 'assets/images/game/balloon_background.png';
const _balloonAsset = 'assets/images/game/balloon_red.png';

class BalloonGame extends StatefulWidget {
  const BalloonGame({
    super.key,
    required this.prompt,
    required this.isPositive,
    required this.feedbackPulse,
    required this.reduceMotion,
  });

  final String prompt;
  final bool isPositive;
  final int feedbackPulse;
  final bool reduceMotion;

  @override
  State<BalloonGame> createState() => _BalloonGameState();
}

class _BalloonGameState extends State<BalloonGame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (!widget.reduceMotion) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant BalloonGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reduceMotion != oldWidget.reduceMotion) {
      widget.reduceMotion
          ? _controller.stop()
          : _controller.repeat(reverse: true);
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
    return Semantics(
      label: 'Mini-jeu ballons. Prompt actuel $promptLabel.',
      child: SizedBox(
        width: 340,
        height: 260,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                _balloonBackgroundAsset,
                fit: BoxFit.cover,
                semanticLabel: 'Decor de ciel de fete.',
              ),
              _FloatingBalloon(
                animation: _controller,
                reduceMotion: widget.reduceMotion,
                alignment: const Alignment(-0.82, -0.08),
                width: 82,
                phase: 0.1,
                tint: const Color(0xffffd166),
              ),
              _FloatingBalloon(
                animation: _controller,
                reduceMotion: widget.reduceMotion,
                alignment: const Alignment(0.78, -0.18),
                width: 72,
                phase: 0.63,
                tint: const Color(0xff7bdff2),
              ),
              Center(
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(widget.feedbackPulse),
                  tween: Tween<double>(
                    begin: widget.reduceMotion
                        ? 1
                        : widget.isPositive
                            ? 0.72
                            : 1.08,
                    end: 1,
                  ),
                  curve: widget.isPositive
                      ? Curves.elasticOut
                      : Curves.easeOutBack,
                  duration: widget.reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 520),
                  builder: (context, scale, child) {
                    final wobble = widget.reduceMotion || widget.isPositive
                        ? 0.0
                        : math.sin((1 - scale) * math.pi * 6) * 0.08;
                    return Transform.rotate(
                      angle: wobble,
                      child: Transform.scale(scale: scale, child: child),
                    );
                  },
                  child: SizedBox(
                    width: 190,
                    height: 230,
                    child: Image.asset(
                      _balloonAsset,
                      fit: BoxFit.contain,
                      semanticLabel: '',
                    ),
                  ),
                ),
              ),
              if (!widget.reduceMotion &&
                  widget.isPositive &&
                  widget.feedbackPulse > 0)
                _PopSparkles(key: ValueKey(widget.feedbackPulse)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingBalloon extends StatelessWidget {
  const _FloatingBalloon({
    required this.animation,
    required this.reduceMotion,
    required this.alignment,
    required this.width,
    required this.phase,
    required this.tint,
  });

  final Animation<double> animation;
  final bool reduceMotion;
  final Alignment alignment;
  final double width;
  final double phase;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final wave = reduceMotion
            ? 0.0
            : math.sin((animation.value + phase) * math.pi * 2);
        return Align(
          alignment: alignment,
          child: Transform.translate(
            offset: Offset(wave * 12, wave * -16),
            child: Transform.rotate(
              angle: wave * 0.04,
              child: child,
            ),
          ),
        );
      },
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(tint, BlendMode.modulate),
        child: Image.asset(
          _balloonAsset,
          width: width,
          fit: BoxFit.contain,
          semanticLabel: '',
        ),
      ),
    );
  }
}

class _PopSparkles extends StatelessWidget {
  const _PopSparkles({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xffffd166),
      const Color(0xffef476f),
      const Color(0xff06d6a0),
      const Color(0xff118ab2),
      const Color(0xffffffff),
    ];
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      builder: (context, value, child) {
        return Opacity(
          opacity: 1 - value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (var index = 0; index < colors.length; index++)
                Transform.translate(
                  offset: Offset(
                    math.cos(index * 1.26) * value * 86,
                    math.sin(index * 1.26) * value * 60,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors[index],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black54, width: 1),
                    ),
                    child: const SizedBox(width: 14, height: 14),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
