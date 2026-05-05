import 'package:flutter/services.dart';

class NormalizedInput {
  const NormalizedInput({
    required this.keyId,
    required this.character,
    required this.isShiftPressed,
  });

  final String keyId;
  final String character;
  final bool isShiftPressed;
}

class InputNormalizer {
  const InputNormalizer();

  NormalizedInput? normalize(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return null;
    }

    final logicalKey = event.logicalKey;
    final character = event.character;
    final isShiftPressed = HardwareKeyboard.instance.logicalKeysPressed.any(
      (key) =>
          key == LogicalKeyboardKey.shiftLeft ||
          key == LogicalKeyboardKey.shiftRight,
    );

    if (logicalKey == LogicalKeyboardKey.space) {
      return NormalizedInput(
        keyId: 'SPACE',
        character: ' ',
        isShiftPressed: isShiftPressed,
      );
    }

    final label = logicalKey.keyLabel;
    if (label.isEmpty && character == null) {
      return null;
    }

    final raw = (character?.isNotEmpty == true ? character! : label).trim();
    if (raw.isEmpty) {
      return null;
    }

    return NormalizedInput(
      keyId: raw.toUpperCase(),
      character: raw,
      isShiftPressed: isShiftPressed,
    );
  }
}
