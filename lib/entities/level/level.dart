/// A named grouping of vocabulary decks shown as a section in the vocab screen.
///
/// Levels are the primary content-access unit — free/paid tiers are assigned
/// per level per course. Progress is tracked at the level level by aggregating
/// the progress of all decks it contains.
class Level {
  const Level({required this.id, required this.deckIds});

  /// Unique level identifier (e.g., "intro", "basic").
  final String id;

  /// Ordered list of deck IDs belonging to this level.
  final List<String> deckIds;

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as String,
      deckIds: (json['decks'] as List<dynamic>).cast<String>(),
    );
  }
}
