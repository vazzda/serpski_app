import 'dart:math';

import '../data/models/card_model.dart';
import 'quiz_mode.dart';

/// Builds 4 options for multiple choice: 1 correct + 3 wrong from same group.
/// [correctAnswer] is the right answer (english or serbian depending on mode).
/// [allCards] are all cards in the group (to pick wrong answers from).
List<String> buildMultipleChoiceOptions({
  required QuizMode mode,
  required String correctAnswer,
  required List<CardModel> allCards,
  required Random random,
}) {
  final allAnswers = mode == QuizMode.serbianShown
      ? allCards.map((c) => c.english).toSet().toList()
      : allCards.map((c) => c.serbianAnswer).toSet().toList();
  final wrongPool = allAnswers.where((a) => a != correctAnswer).toList();
  final wrong = <String>[];
  while (wrong.length < 3 && wrongPool.isNotEmpty) {
    wrongPool.shuffle(random);
    final pick = wrongPool.removeAt(0);
    if (!wrong.contains(pick)) wrong.add(pick);
  }
  while (wrong.length < 3) {
    wrong.add(correctAnswer);
  }
  final options = [correctAnswer, ...wrong]..shuffle(random);
  return options;
}

/// Builds 4 option cards for serbianShown mode (1 correct + 3 wrong). Use for display with displayEnglishForCard.
List<CardModel> buildMultipleChoiceOptionCards({
  required CardModel correctCard,
  required List<CardModel> allCards,
  required Random random,
}) {
  final correctAnswer = correctCard.english;
  final wrongPool = allCards.where((c) => c.english != correctAnswer).toList();
  final wrong = <CardModel>[];
  while (wrong.length < 3 && wrongPool.isNotEmpty) {
    wrongPool.shuffle(random);
    wrong.add(wrongPool.removeAt(0));
  }
  while (wrong.length < 3) {
    wrong.add(correctCard);
  }
  final options = [correctCard, ...wrong]..shuffle(random);
  return options;
}
