/// A universal vocabulary deck from dictionary.json.
///
/// Decks are language-agnostic — they reference term IDs, not cards.
/// Cards are generated at runtime by joining with translation files.
class VocabDeckModel {
  const VocabDeckModel({
    required this.id,
    required this.termIds,
    this.icon,
  });

  /// Unique deck identifier (e.g., "basic_verbs_01").
  final String id;

  /// Ordered list of term IDs in this deck.
  final List<String> termIds;

  /// Icon name (kebab-case), resolved at runtime via DeckIcons.fromString().
  final String? icon;

  factory VocabDeckModel.fromJson(Map<String, dynamic> json) {
    return VocabDeckModel(
      id: json['id'] as String,
      termIds: (json['terms'] as List<dynamic>).cast<String>(),
      icon: json['icon'] as String?,
    );
  }
}
