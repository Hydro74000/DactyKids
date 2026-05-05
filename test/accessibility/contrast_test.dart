import 'package:dactykids/data/local_storage/settings_store.dart';
import 'package:dactykids/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('main theme color pairs meet WCAG AA contrast targets', () {
    for (final preset in VisualPreset.values) {
      final scheme = DactyTheme.fromPreset(preset).colorScheme;

      expect(_contrast(scheme.surface, scheme.onSurface),
          greaterThanOrEqualTo(4.5));
      expect(_contrast(scheme.primary, scheme.onPrimary),
          greaterThanOrEqualTo(4.5));
      expect(_contrast(scheme.secondary, scheme.onSecondary),
          greaterThanOrEqualTo(4.5));
      expect(
          _contrast(scheme.error, scheme.onError), greaterThanOrEqualTo(4.5));
    }
  });

  test('interactive theme defaults keep comfortable target sizes', () {
    for (final preset in VisualPreset.values) {
      final theme = DactyTheme.fromPreset(preset);
      final states = <WidgetState>{};

      expect(theme.materialTapTargetSize, MaterialTapTargetSize.padded);
      expect(theme.visualDensity, VisualDensity.standard);
      expect(
        theme.iconButtonTheme.style?.minimumSize?.resolve(states),
        const Size(56, 56),
      );
      expect(
        theme.textButtonTheme.style?.minimumSize?.resolve(states),
        const Size(56, 56),
      );
      expect(
        theme.filledButtonTheme.style?.minimumSize?.resolve(states),
        const Size(56, 56),
      );
      expect(
        theme.outlinedButtonTheme.style?.minimumSize?.resolve(states),
        const Size(56, 56),
      );
      expect(theme.listTileTheme.minTileHeight, greaterThanOrEqualTo(56));
    }
  });

  test('grayscale preset avoids hue-dependent colors', () {
    final scheme = DactyTheme.fromPreset(VisualPreset.grayscale).colorScheme;

    expect(_isNeutral(scheme.primary), isTrue);
    expect(_isNeutral(scheme.secondary), isTrue);
    expect(_isNeutral(scheme.surface), isTrue);
    expect(_isNeutral(scheme.error), isTrue);
  });
}

double _contrast(Color left, Color right) {
  final leftLuminance = left.computeLuminance();
  final rightLuminance = right.computeLuminance();
  final lighter =
      leftLuminance > rightLuminance ? leftLuminance : rightLuminance;
  final darker =
      leftLuminance > rightLuminance ? rightLuminance : leftLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

bool _isNeutral(Color color) {
  return color.r == color.g && color.g == color.b;
}
