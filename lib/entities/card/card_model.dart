/// A single flashcard. All card types (vocab, ending, phrase) implement this.
abstract interface class CardModel {
  String get targetText;
  String get nativeText;

  /// Target-language side used for display and grading.
  /// For endings: pronoun + form; for vocab/words: same as targetText.
  String get targetAnswer;
}

/// Word card: infinitive (neutral) form in target language.
class WordCard implements CardModel {
  const WordCard({required this.targetText, required this.nativeText});

  @override
  final String targetText;
  @override
  final String nativeText;

  @override
  String get targetAnswer => targetText;

  factory WordCard.fromJson(Map<String, dynamic> json) => WordCard(
        targetText: json['serbian'] as String,
        nativeText: json['english'] as String,
      );
}

/// Noun card with gender for agreement rounds.
class NounCard implements CardModel {
  const NounCard({
    required this.targetText,
    required this.nativeText,
    required this.gender,
  });

  @override
  final String targetText;
  @override
  final String nativeText;
  /// "m", "f", or "n"
  final String gender;

  @override
  String get targetAnswer => targetText;

  factory NounCard.fromJson(Map<String, dynamic> json) => NounCard(
        targetText: json['serbian'] as String,
        nativeText: json['english'] as String,
        gender: json['gender'] as String,
      );
}

/// Adjective card with all three gender forms.
class AdjectiveCard implements CardModel {
  const AdjectiveCard({
    required this.targetText,
    required this.nativeText,
    required this.feminine,
    required this.neuter,
  });

  /// Masculine form (used in vocabulary mode).
  @override
  final String targetText;
  @override
  final String nativeText;
  final String feminine;
  final String neuter;

  @override
  String get targetAnswer => targetText;

  String formForGender(String gender) => switch (gender) {
        'm' => targetText,
        'f' => feminine,
        'n' => neuter,
        _ => targetText,
      };

  factory AdjectiveCard.fromJson(Map<String, dynamic> json) => AdjectiveCard(
        targetText: json['serbian'] as String,
        nativeText: json['english'] as String,
        feminine: json['feminine'] as String,
        neuter: json['neuter'] as String,
      );
}

/// Runtime-generated phrase (adjective + noun in agreement).
class PhraseCard implements CardModel {
  const PhraseCard({required this.targetText, required this.nativeText});

  @override
  final String targetText;
  @override
  final String nativeText;

  @override
  String get targetAnswer => targetText;
}

/// Ending card: pronoun + conjugated form in target language.
class EndingCard implements CardModel {
  const EndingCard({
    required this.pronoun,
    required this.targetText,
    required this.nativeText,
  });

  final String pronoun;
  @override
  final String targetText;
  @override
  final String nativeText;

  @override
  String get targetAnswer => '$pronoun $targetText';

  factory EndingCard.fromJson(Map<String, dynamic> json) => EndingCard(
        pronoun: json['pronoun'] as String,
        targetText: json['serbian'] as String,
        nativeText: json['english'] as String,
      );
}
