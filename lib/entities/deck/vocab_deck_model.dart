/// A universal vocabulary deck from dictionary.json.
///
/// Decks are language-agnostic — they reference concept IDs, not cards.
/// Cards are generated at runtime by joining with translation files.
class VocabDeckModel {
  const VocabDeckModel({
    required this.id,
    required this.conceptIds,
    this.icon,
  });

  /// Unique deck identifier (e.g., "basic_verbs_01").
  final String id;

  /// Ordered list of concept IDs in this deck.
  final List<String> conceptIds;

  /// MDI icon name (kebab-case), resolved at runtime via MdiIcons.fromString().
  final String? icon;

  factory VocabDeckModel.fromJson(Map<String, dynamic> json) {
    return VocabDeckModel(
      id: json['id'] as String,
      conceptIds: (json['concepts'] as List<dynamic>).cast<String>(),
      icon: json['icon'] as String?,
    );
  }
}
