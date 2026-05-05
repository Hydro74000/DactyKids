class ActivityDefinition {
  const ActivityDefinition({
    required this.id,
    required this.title,
    required this.world,
    required this.newKeys,
    required this.reviewKeys,
    required this.requiredAccuracy,
    required this.prompts,
    this.promptMode = PromptMode.keys,
    this.layoutVariants = const {},
  });

  final String id;
  final String title;
  final String world;
  final List<String> newKeys;
  final List<String> reviewKeys;
  final double requiredAccuracy;
  final List<String> prompts;
  final PromptMode promptMode;
  final Map<String, ActivityVariant> layoutVariants;

  factory ActivityDefinition.fromJson(Map<String, dynamic> json) {
    return ActivityDefinition(
      id: json['id'] as String,
      title: json['title'] as String,
      world: json['world'] as String,
      newKeys: (json['newKeys'] as List<dynamic>).cast<String>(),
      reviewKeys: (json['reviewKeys'] as List<dynamic>).cast<String>(),
      requiredAccuracy: (json['requiredAccuracy'] as num).toDouble(),
      prompts: (json['prompts'] as List<dynamic>).cast<String>(),
      promptMode: PromptMode.values.firstWhere(
        (mode) => mode.name == json['promptMode'],
        orElse: () => PromptMode.keys,
      ),
      layoutVariants:
          ((json['layoutVariants'] as Map<String, dynamic>?) ?? {}).map(
        (layoutId, value) => MapEntry(
          layoutId,
          ActivityVariant.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }

  List<String> get allowedKeys => {...newKeys, ...reviewKeys}.toList();

  ActivityDefinition forLayout(String layoutId) {
    final variant = layoutVariants[layoutId];
    if (variant == null) {
      return this;
    }
    return ActivityDefinition(
      id: id,
      title: variant.title ?? title,
      world: world,
      newKeys: variant.newKeys ?? newKeys,
      reviewKeys: variant.reviewKeys ?? reviewKeys,
      requiredAccuracy: requiredAccuracy,
      prompts: variant.prompts ?? prompts,
      promptMode: variant.promptMode ?? promptMode,
      layoutVariants: layoutVariants,
    );
  }
}

enum PromptMode {
  keys,
  syllables,
  words,
  sentences,
  numbers,
  symbols,
  paragraphs
}

class ActivityVariant {
  const ActivityVariant({
    this.title,
    this.newKeys,
    this.reviewKeys,
    this.prompts,
    this.promptMode,
  });

  final String? title;
  final List<String>? newKeys;
  final List<String>? reviewKeys;
  final List<String>? prompts;
  final PromptMode? promptMode;

  factory ActivityVariant.fromJson(Map<String, dynamic> json) {
    return ActivityVariant(
      title: json['title'] as String?,
      newKeys: (json['newKeys'] as List<dynamic>?)?.cast<String>(),
      reviewKeys: (json['reviewKeys'] as List<dynamic>?)?.cast<String>(),
      prompts: (json['prompts'] as List<dynamic>?)?.cast<String>(),
      promptMode: json['promptMode'] == null
          ? null
          : PromptMode.values.firstWhere(
              (mode) => mode.name == json['promptMode'],
              orElse: () => PromptMode.keys,
            ),
    );
  }
}
