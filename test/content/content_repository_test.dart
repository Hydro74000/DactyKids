import 'package:dactykids/data/content_repository/content_repository.dart';
import 'package:dactykids/domain/keyboard/keyboard_layout.dart';
import 'package:dactykids/domain/typing_engine/activity_definition.dart';
import 'package:dactykids/domain/typing_engine/prompt_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads MVP layouts and home row lessons from assets', () async {
    final repository = ContentRepository();

    final layouts = await repository.loadKeyboardLayouts();
    final lessons = await repository.loadLessons();

    expect(layouts.map((layout) => layout.id),
        containsAll(['azerty_fr', 'qwerty_us']));
    expect(lessons, hasLength(24));
    expect(lessons.first.prompts, containsAll(['F', 'J', 'SPACE']));
    expect(lessons[3].forLayout('azerty_fr').newKeys, ['Q', 'M']);
    expect(lessons[3].forLayout('qwerty_us').newKeys, ['A', ';']);
    expect(lessons[9].forLayout('azerty_fr').newKeys, ['Z', 'O']);
    expect(lessons[10].forLayout('qwerty_us').newKeys, ['Q', 'P']);
    expect(lessons[11].title, 'V et N');
    expect(lessons[15].promptMode.name, 'syllables');
    expect(lessons[16].promptMode.name, 'words');
    expect(lessons[17].promptMode.name, 'sentences');
    expect(lessons[19].id, 'castle_shift_01');
    expect(lessons[19].forLayout('azerty_fr').newKeys, ['SHIFT+Q', 'SHIFT+M']);
    expect(lessons[20].promptMode.name, 'numbers');
    expect(lessons[21].id, 'castle_symbols_01');
    expect(lessons[22].id, 'castle_accents_01');
    expect(
        lessons[22].forLayout('azerty_fr').newKeys, ['É', 'È', 'À', 'Ç', 'Ù']);
    expect(lessons[22].forLayout('qwerty_us').prompts, ['ete', 'ca', 'ou']);
    expect(lessons.last.id, 'castle_paragraph_01');
    expect(lessons.last.promptMode.name, 'paragraphs');
  });

  test('lesson content stays compatible with declared keyboard layouts',
      () async {
    final repository = ContentRepository();

    final layouts = await repository.loadKeyboardLayouts();
    final lessons = await repository.loadLessons();

    for (final layout in layouts) {
      for (final rawLesson in lessons) {
        final lesson = rawLesson.forLayout(layout.id);
        final availableKeys = _layoutKeys(layout);
        final declaredKeys = [...lesson.newKeys, ...lesson.reviewKeys];
        final promptKeys = _promptKeys(lesson);

        for (final key in [...declaredKeys, ...promptKeys]) {
          expect(
            availableKeys,
            contains(PromptKey.canonical(key)),
            reason: '${lesson.id} references $key on ${layout.id}',
          );
        }
      }
    }
  });
}

Set<String> _layoutKeys(KeyboardLayout layout) {
  return {
    for (final row in layout.rows)
      for (final key in row) PromptKey.canonical(key),
  };
}

List<String> _promptKeys(ActivityDefinition lesson) {
  if (lesson.promptMode == PromptMode.keys) {
    return lesson.prompts;
  }
  return [
    for (final prompt in lesson.prompts)
      for (final character in prompt.split('')) _keyForCharacter(character),
  ];
}

String _keyForCharacter(String character) {
  if (character == ' ') {
    return 'SPACE';
  }
  final upper = character.toUpperCase();
  final lower = character.toLowerCase();
  if (upper != lower && character == upper) {
    return 'SHIFT+$upper';
  }
  return upper;
}
