import '../typing_engine/prompt_matcher.dart';

class KeyboardLayout {
  const KeyboardLayout({
    required this.id,
    required this.label,
    required this.rows,
    required this.fingers,
  });

  final String id;
  final String label;
  final List<List<String>> rows;
  final Map<String, String> fingers;

  factory KeyboardLayout.fromJson(Map<String, dynamic> json) {
    return KeyboardLayout(
      id: json['id'] as String,
      label: json['label'] as String,
      rows: (json['rows'] as List<dynamic>)
          .map((row) => (row as List<dynamic>).cast<String>())
          .toList(),
      fingers: (json['fingers'] as Map<String, dynamic>).cast<String, String>(),
    );
  }

  String fingerFor(String keyId) =>
      fingers[PromptKey.canonical(keyId)] ?? 'doigt indique';

  bool contains(String keyId) => rows.any((row) => row.contains(keyId));
}
