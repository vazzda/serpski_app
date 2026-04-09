/// A single translation entry from a language file (e.g., sr.json).
///
/// Each concept has a list of these. Most concepts have one entry;
/// Slavic verb aspect pairs have two (perfective + imperfective).
class TranslationEntry {
  const TranslationEntry({
    required this.text,
    this.note,
    this.gender,
    this.aspect,
    this.forms,
  });

  /// Primary form (what the user must produce/recognize).
  final String text;

  /// Short explanation or usage example.
  final String? note;

  /// Noun gender or adjective primary gender: "m", "f", "n".
  final String? gender;

  /// Verb aspect: "perfective" or "imperfective".
  final String? aspect;

  /// Additional inflected forms (e.g., adjective gender variants).
  final Map<String, String>? forms;

  factory TranslationEntry.fromJson(Map<String, dynamic> json) {
    return TranslationEntry(
      text: json['text'] as String,
      note: json['note'] as String?,
      gender: json['gender'] as String?,
      aspect: json['aspect'] as String?,
      forms: json['forms'] != null
          ? Map<String, String>.from(json['forms'] as Map)
          : null,
    );
  }
}
