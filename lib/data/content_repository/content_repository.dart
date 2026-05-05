import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/keyboard/keyboard_layout.dart';
import '../../domain/typing_engine/activity_definition.dart';

class ContentRepository {
  ContentRepository({AssetBundle? assetBundle})
      : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;

  Future<List<KeyboardLayout>> loadKeyboardLayouts() async {
    final paths = [
      'assets/content/layouts/azerty_fr.json',
      'assets/content/layouts/qwerty_us.json',
    ];
    final layouts = <KeyboardLayout>[];
    for (final path in paths) {
      final raw = await _assetBundle.loadString(path);
      layouts.add(
          KeyboardLayout.fromJson(jsonDecode(raw) as Map<String, dynamic>));
    }
    return layouts;
  }

  Future<List<ActivityDefinition>> loadLessons() async {
    final paths = [
      ...List.generate(
        6,
        (index) => 'assets/content/lessons/home_row_0${index + 1}.json',
      ),
      ...List.generate(
        5,
        (index) => 'assets/content/lessons/top_row_0${index + 1}.json',
      ),
      ...List.generate(
        4,
        (index) => 'assets/content/lessons/bottom_row_0${index + 1}.json',
      ),
      'assets/content/lessons/practice_syllables_01.json',
      'assets/content/lessons/practice_words_01.json',
      'assets/content/lessons/practice_sentences_01.json',
      'assets/content/lessons/soft_test_01.json',
      'assets/content/lessons/castle_shift_01.json',
      'assets/content/lessons/castle_numbers_01.json',
      'assets/content/lessons/castle_symbols_01.json',
      'assets/content/lessons/castle_accents_01.json',
      'assets/content/lessons/castle_paragraph_01.json',
    ];
    final lessons = <ActivityDefinition>[];
    for (final path in paths) {
      final raw = await _assetBundle.loadString(path);
      lessons.add(
          ActivityDefinition.fromJson(jsonDecode(raw) as Map<String, dynamic>));
    }
    return lessons;
  }

  Future<List<ActivityDefinition>> loadHomeRowLessons() => loadLessons();
}
