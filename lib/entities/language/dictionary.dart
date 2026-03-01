import 'concept.dart';
import '../deck/vocab_deck_model.dart';
import '../level/level.dart';

/// The universal dictionary loaded from dictionary.json + levels.json.
///
/// Contains all concepts, vocabulary decks, and level definitions.
/// Language-agnostic — translations are in separate LanguagePack files.
class Dictionary {
  const Dictionary({
    required this.concepts,
    required this.decks,
    required this.levels,
  });

  /// All concepts keyed by ID.
  final Map<String, Concept> concepts;

  /// All vocabulary decks keyed by insertion order.
  final List<VocabDeckModel> decks;

  /// Ordered levels, each containing a subset of deck IDs.
  final List<Level> levels;

  /// Set of all concept IDs in the dictionary.
  Set<String> get conceptIds => concepts.keys.toSet();

  /// All decks keyed by ID for fast lookup.
  Map<String, VocabDeckModel> get decksById =>
      {for (final g in decks) g.id: g};

  factory Dictionary.fromJson(Map<String, dynamic> json) {
    final conceptsJson = json['concepts'] as Map<String, dynamic>;
    final concepts = conceptsJson.map(
      (id, data) =>
          MapEntry(id, Concept.fromJson(id, data as Map<String, dynamic>)),
    );

    final decksJson = json['decks'] as List<dynamic>;
    final decks = decksJson
        .map((g) => VocabDeckModel.fromJson(g as Map<String, dynamic>))
        .toList();

    final levelsJson = json['levels'] as List<dynamic>;
    final levels = levelsJson
        .map((l) => Level.fromJson(l as Map<String, dynamic>))
        .toList();

    return Dictionary(concepts: concepts, decks: decks, levels: levels);
  }
}
