import 'package:flutter/material.dart';

import '../../data/local_storage/settings_store.dart';

class DactyTheme {
  const DactyTheme._();

  static ThemeData fromPreset(VisualPreset preset) {
    final scheme = switch (preset) {
      VisualPreset.highContrast => const ColorScheme.light(
          primary: Color(0xFF003A7D),
          onPrimary: Colors.white,
          secondary: Color(0xFF9A3412),
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          error: Color(0xFF8B0000),
          onError: Colors.white,
        ),
      VisualPreset.lowVision => const ColorScheme.light(
          primary: Color(0xFF004B5C),
          onPrimary: Colors.white,
          secondary: Color(0xFF6B4E00),
          onSecondary: Colors.white,
          surface: Color(0xFFFFFCF2),
          onSurface: Color(0xFF111111),
          error: Color(0xFF7F1D1D),
          onError: Colors.white,
        ),
      VisualPreset.grayscale => const ColorScheme.light(
          primary: Color(0xFF2F2F2F),
          onPrimary: Colors.white,
          secondary: Color(0xFF5C5C5C),
          onSecondary: Colors.white,
          surface: Color(0xFFF7F7F7),
          onSurface: Color(0xFF111111),
          error: Color(0xFF3B3B3B),
          onError: Colors.white,
        ),
      VisualPreset.standard => const ColorScheme.light(
          primary: Color(0xFF146C94),
          onPrimary: Colors.white,
          secondary: Color(0xFFB45309),
          onSecondary: Colors.white,
          surface: Color(0xFFFFFBF5),
          onSurface: Color(0xFF172026),
          error: Color(0xFFB42318),
          onError: Colors.white,
        ),
    };

    final textScale = preset == VisualPreset.lowVision ? 1.18 : 1.0;
    final baseTextTheme = Typography.blackMountainView.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      textTheme: _scaledTextTheme(baseTextTheme, textScale),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(56, 56),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(56, 56),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(56, 56),
          tapTargetSize: MaterialTapTargetSize.padded,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(56, 56),
          tapTargetSize: MaterialTapTargetSize.padded,
          side: BorderSide(color: scheme.primary, width: 2),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(56, 56)),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        minTileHeight: 56,
      ),
      focusColor: scheme.secondary.withValues(alpha: 0.28),
    );
  }

  static TextTheme _scaledTextTheme(TextTheme textTheme, double factor) {
    TextStyle? scale(TextStyle? style) {
      if (style == null || style.fontSize == null) {
        return style;
      }
      return style.copyWith(fontSize: style.fontSize! * factor);
    }

    return textTheme.copyWith(
      displayLarge: scale(textTheme.displayLarge),
      displayMedium: scale(textTheme.displayMedium),
      displaySmall: scale(textTheme.displaySmall),
      headlineLarge: scale(textTheme.headlineLarge),
      headlineMedium: scale(textTheme.headlineMedium),
      headlineSmall: scale(textTheme.headlineSmall),
      titleLarge: scale(textTheme.titleLarge),
      titleMedium: scale(textTheme.titleMedium),
      titleSmall: scale(textTheme.titleSmall),
      bodyLarge: scale(textTheme.bodyLarge),
      bodyMedium: scale(textTheme.bodyMedium),
      bodySmall: scale(textTheme.bodySmall),
      labelLarge: scale(textTheme.labelLarge),
      labelMedium: scale(textTheme.labelMedium),
      labelSmall: scale(textTheme.labelSmall),
    );
  }
}
