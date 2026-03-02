import 'term.dart';
import '../deck/vocab_deck_model.dart';
import '../level/level.dart';

/// The universal dictionary loaded from dictionary.json + levels.json.
///
/// Contains all terms, vocabulary decks, and level definitions.
/// Language-agnostic — translations are in separate LanguagePack files.
class Dictionary {
  const Dictionary({
    required this.terms,
    required this.decks,
    required this.levels,
  });

  /// All terms keyed by ID.
  final Map<String, Term> terms;

  /// All vocabulary decks keyed by insertion order.
  final List<VocabDeckModel> decks;

  /// Ordered levels, each containing a subset of deck IDs.
  final List<Level> levels;

  /// Set of all term IDs in the dictionary.
  Set<String> get termIds => terms.keys.toSet();

  /// All decks keyed by ID for fast lookup.
  Map<String, VocabDeckModel> get decksById =>
      {for (final g in decks) g.id: g};

  factory Dictionary.fromJson(Map<String, dynamic> json) {
    final termsJson = json['terms'] as Map<String, dynamic>;
    final terms = termsJson.map(
      (id, data) =>
          MapEntry(id, Term.fromJson(id, data as Map<String, dynamic>)),
    );

    final decksJson = json['decks'] as List<dynamic>;
    final decks = decksJson
        .map((g) => VocabDeckModel.fromJson(g as Map<String, dynamic>))
        .toList();

    final levelsJson = json['levels'] as List<dynamic>;
    final levels = levelsJson
        .map((l) => Level.fromJson(l as Map<String, dynamic>))
        .toList();

    return Dictionary(terms: terms, decks: decks, levels: levels);
  }
}
