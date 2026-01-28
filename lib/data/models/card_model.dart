/// A single flashcard. For "words" groups: infinitive ↔ English.
/// For "endings" groups: pronoun + conjugated form ↔ English.
abstract interface class CardModel {
  String get serbian;
  String get english;

  /// Serbian side used for display and grading. For endings: pronoun + form; for words: infinitive.
  String get serbianAnswer;
}

/// Word card: infinitive (neutral) form ↔ English.
class WordCard implements CardModel {
  const WordCard({required this.serbian, required this.english});

  @override
  final String serbian;
  @override
  final String english;

  @override
  String get serbianAnswer => serbian;

  factory WordCard.fromJson(Map<String, dynamic> json) => WordCard(
        serbian: json['serbian'] as String,
        english: json['english'] as String,
      );
}

/// Ending card: pronoun + conjugated form ↔ English.
class EndingCard implements CardModel {
  const EndingCard({
    required this.pronoun,
    required this.serbian,
    required this.english,
  });

  final String pronoun;
  @override
  final String serbian;
  @override
  final String english;

  @override
  String get serbianAnswer => '$pronoun $serbian';

  factory EndingCard.fromJson(Map<String, dynamic> json) => EndingCard(
        pronoun: json['pronoun'] as String,
        serbian: json['serbian'] as String,
        english: json['english'] as String,
      );
}
