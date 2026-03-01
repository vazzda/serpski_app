/// Localized display metadata for a [Level], sourced from the native language pack.
class LevelMeta {
  const LevelMeta({required this.name, this.description});

  final String name;
  final String? description;

  factory LevelMeta.fromJson(Map<String, dynamic> json) {
    return LevelMeta(
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}

/// Localized display metadata for a vocabulary deck, sourced from the native language pack.
class DeckMeta {
  const DeckMeta({required this.name, this.description});

  final String name;
  final String? description;

  factory DeckMeta.fromJson(Map<String, dynamic> json) {
    return DeckMeta(
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}
