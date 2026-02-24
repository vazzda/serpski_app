import 'concept.dart';
import '../group/vocab_group_model.dart';

/// The universal dictionary loaded from dictionary.json.
///
/// Contains all concepts and their group assignments.
/// Language-agnostic — translations are in separate LanguagePack files.
class Dictionary {
  const Dictionary({
    required this.concepts,
    required this.groups,
  });

  /// All concepts keyed by ID.
  final Map<String, Concept> concepts;

  /// All vocabulary groups.
  final List<VocabGroupModel> groups;

  /// Set of all concept IDs in the dictionary.
  Set<String> get conceptIds => concepts.keys.toSet();

  factory Dictionary.fromJson(Map<String, dynamic> json) {
    final conceptsJson = json['concepts'] as Map<String, dynamic>;
    final concepts = conceptsJson.map(
      (id, data) => MapEntry(id, Concept.fromJson(id, data as Map<String, dynamic>)),
    );

    final groupsJson = json['groups'] as List<dynamic>;
    final groups = groupsJson
        .map((g) => VocabGroupModel.fromJson(g as Map<String, dynamic>))
        .toList();

    return Dictionary(concepts: concepts, groups: groups);
  }
}
