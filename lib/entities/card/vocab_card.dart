import 'card_model.dart';

/// A language-agnostic vocabulary training card.
///
/// Generated at runtime by joining a concept's target and native translations.
/// One target translation entry = one VocabCard.
class VocabCard implements CardModel {
  const VocabCard({
    required this.conceptId,
    required this.translationIndex,
    required this.nativeText,
    required this.targetText,
    this.note,
    this.gender,
    this.aspect,
    this.forms,
  });

  /// Concept slug from dictionary.json (e.g., "buy", "city").
  final String conceptId;

  /// Index within the target language's translations array for this concept.
  /// Used for word ID generation: "{conceptId}:{translationIndex}".
  final int translationIndex;

  /// Display text in the user's native language.
  /// Built from all native translations joined with " / ".
  /// If the target has an aspect, a localized aspect label is appended.
  @override
  final String nativeText;

  /// Display text in the target language (what the user must produce/recognize).
  @override
  final String targetText;

  /// Short explanation or usage example. Always visible on card.
  final String? note;

  /// Noun gender or adjective primary gender: "m", "f", "n".
  final String? gender;

  /// Verb aspect: "perfective" or "imperfective".
  final String? aspect;

  /// Additional inflected forms (e.g., adjective gender variants).
  /// Keys are gender codes: {"f": "dobra", "n": "dobro"}.
  final Map<String, String>? forms;

  /// Target-language answer for grading (same as targetText for vocab).
  @override
  String get targetAnswer => targetText;

  /// Unique word ID for progress tracking. Scoped by target_lang in DB.
  String get wordId => '$conceptId:$translationIndex';
}
