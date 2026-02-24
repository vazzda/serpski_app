/// A universal concept from dictionary.json.
///
/// Concepts are abstract meaning units — language-agnostic.
/// They have a human-readable ID and a part of speech.
class Concept {
  const Concept({
    required this.id,
    required this.pos,
  });

  /// Human-readable slug (e.g., "buy", "city", "good").
  final String id;

  /// Part of speech: "verb", "noun", "adjective", "other".
  final String pos;

  factory Concept.fromJson(String id, Map<String, dynamic> json) {
    return Concept(
      id: id,
      pos: json['pos'] as String,
    );
  }
}
