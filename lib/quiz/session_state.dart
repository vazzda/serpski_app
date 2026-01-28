import '../data/models/card_model.dart';
import 'quiz_mode.dart';

/// State of an active or finished quiz session.
class SessionState {
  const SessionState({
    required this.groupId,
    required this.mode,
    required this.requestedCount,
    this.queue = const [],
    this.correctCount = 0,
    this.wrongCount = 0,
    this.missedCards = const [],
  });

  final String groupId;
  final QuizMode mode;
  final int requestedCount;

  /// Remaining cards to answer (front = current). Wrong answers are moved to end.
  final List<CardModel> queue;

  final int correctCount;
  final int wrongCount;

  /// Cards that were answered wrong (for review at end).
  final List<CardModel> missedCards;

  CardModel? get currentCard => queue.isNotEmpty ? queue.first : null;

  bool get isFinished => queue.isEmpty;

  SessionState copyWith({
    List<CardModel>? queue,
    int? correctCount,
    int? wrongCount,
    List<CardModel>? missedCards,
  }) {
    return SessionState(
      groupId: groupId,
      mode: mode,
      requestedCount: requestedCount,
      queue: queue ?? this.queue,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      missedCards: missedCards ?? this.missedCards,
    );
  }
}
