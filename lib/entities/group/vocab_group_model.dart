/// A universal vocabulary group from dictionary.json.
///
/// Groups are language-agnostic — they reference concept IDs, not cards.
/// Cards are generated at runtime by joining with translation files.
class VocabGroupModel {
  const VocabGroupModel({
    required this.id,
    required this.conceptIds,
    this.icon,
  });

  /// Unique group identifier (e.g., "basic_verbs_01").
  final String id;

  /// Ordered list of concept IDs in this group.
  final List<String> conceptIds;

  /// MDI icon name (kebab-case), resolved at runtime via MdiIcons.fromString().
  final String? icon;

  factory VocabGroupModel.fromJson(Map<String, dynamic> json) {
    return VocabGroupModel(
      id: json['id'] as String,
      conceptIds: (json['concepts'] as List<dynamic>).cast<String>(),
      icon: json['icon'] as String?,
    );
  }
}
