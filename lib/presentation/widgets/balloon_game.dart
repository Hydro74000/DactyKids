import 'dart:math' as math;

import 'package:flutter/material.dart';

class BalloonGame extends StatefulWidget {
  const BalloonGame({
    super.key,
    required this.prompt,
    required this.feedbackPulse,
    required this.reduceMotion,
  });

  final String prompt;
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
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Mini-jeu ballons. Prompt actuel ${widget.prompt}.',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final offset = widget.reduceMotion
              ? 0.0
              : math.sin(_controller.value * math.pi * 2) * 10;
          return Transform.translate(
            offset: Offset(0, offset),
            child: AnimatedScale(
              key: ValueKey(widget.feedbackPulse),
              scale: 1,
              duration: const Duration(milliseconds: 180),
              child: CustomPaint(
                painter: _BalloonPainter(
                  color: scheme.secondary,
                  outline: scheme.onSurface,
                ),
                child: SizedBox(
                  width: 220,
                  height: 240,
                  child: Center(
                    child: Text(
                      widget.prompt == 'SPACE' ? 'espace' : widget.prompt,
                      style: TextStyle(
                        color: scheme.onSecondary,
                        fontSize: widget.prompt == 'SPACE' ? 38 : 72,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BalloonPainter extends CustomPainter {
  const _BalloonPainter({
    required this.color,
    required this.outline,
  });

  final Color color;
  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final border = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final oval = Rect.fromLTWH(22, 10, size.width - 44, size.height - 70);
    canvas.drawOval(oval, paint);
    canvas.drawOval(oval, border);

    final knot = Path()
      ..moveTo(size.width / 2 - 12, size.height - 62)
      ..lineTo(size.width / 2 + 12, size.height - 62)
      ..lineTo(size.width / 2, size.height - 42)
      ..close();
    canvas.drawPath(knot, paint);
    canvas.drawPath(knot, border);

    final stringPaint = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final path = Path()
      ..moveTo(size.width / 2, size.height - 42)
      ..quadraticBezierTo(
          size.width / 2 - 14, size.height - 20, size.width / 2, size.height);
    canvas.drawPath(path, stringPaint);
  }

  @override
  bool shouldRepaint(covariant _BalloonPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.outline != outline;
  }
}
