/// A universal vocabulary group from dictionary.json.
///
/// Groups are language-agnostic — they reference concept IDs, not cards.
/// Cards are generated at runtime by joining with translation files.
class VocabGroupModel {
  const VocabGroupModel({
    required this.id,
    required this.labelKey,
    required this.conceptIds,
  });

  /// Unique group identifier (e.g., "basic_verbs_01").
  final String id;

  /// ARB localization key for the group name (e.g., "groupBasicVerbs01").
  final String labelKey;

  /// Ordered list of concept IDs in this group.
  final List<String> conceptIds;

  factory VocabGroupModel.fromJson(Map<String, dynamic> json) {
    return VocabGroupModel(
      id: json['id'] as String,
      labelKey: json['labelKey'] as String,
      conceptIds: (json['concepts'] as List<dynamic>).cast<String>(),
    );
  }
}
