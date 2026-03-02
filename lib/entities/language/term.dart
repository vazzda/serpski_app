/// A universal term from dictionary.json.
///
/// Terms are abstract meaning units — language-agnostic.
/// They have a human-readable ID and a part of speech.
class Term {
  const Term({
    required this.id,
    required this.pos,
  });

  /// Human-readable slug (e.g., "buy", "city", "good").
  final String id;

  /// Part of speech: "verb", "noun", "adjective", "other".
  final String pos;

  factory Term.fromJson(String id, Map<String, dynamic> json) {
    return Term(
      id: id,
      pos: json['pos'] as String,
    );
  }
}
