import 'package:flutter/material.dart';

import '../../domain/keyboard/keyboard_layout.dart';
import '../../domain/typing_engine/prompt_matcher.dart';

class VisualKeyboard extends StatelessWidget {
  const VisualKeyboard({
    super.key,
    required this.layout,
    required this.targetKey,
    required this.useLargeTarget,
  });

  final KeyboardLayout layout;
  final String targetKey;
  final bool useLargeTarget;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Clavier visuel. Touche cible $targetKey.',
      child: Column(
        children: [
          for (final row in layout.rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final key in row)
                    Flexible(
                      child: _KeyTile(
                        keyId: key,
                        isTarget: _sameKey(key, targetKey),
                        isSpace: key == 'SPACE',
                        useLargeTarget: useLargeTarget,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _sameKey(String left, String right) {
    final canonicalRight = PromptKey.canonical(right);
    if (left == 'SPACE' && (canonicalRight == 'SPACE' || right == ' ')) {
      return true;
    }
    return left.toUpperCase() == canonicalRight;
  }
}

class _KeyTile extends StatelessWidget {
  const _KeyTile({
    required this.keyId,
    required this.isTarget,
    required this.isSpace,
    required this.useLargeTarget,
  });

  final String keyId;
  final bool isTarget;
  final bool isSpace;
  final bool useLargeTarget;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = isSpace ? 220.0 : 58.0;
    final height = isTarget && useLargeTarget ? 72.0 : 56.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      constraints: BoxConstraints(
        minWidth: width,
        minHeight: height,
        maxWidth: isSpace ? 360 : 72,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isTarget ? scheme.primary : scheme.surface,
        border: Border.all(
          color: isTarget ? scheme.secondary : scheme.outline,
          width: isTarget ? 4 : 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          isSpace ? 'espace' : keyId,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isTarget ? scheme.onPrimary : scheme.onSurface,
            fontSize: isSpace ? 18 : 24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
