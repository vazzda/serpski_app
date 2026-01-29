import '../data/models/card_model.dart';
import 'quiz_mode.dart';

/// One missed card; in Write mode [userTypedAnswer] is what the user wrongly typed.
class MissedEntry {
  const MissedEntry({required this.card, this.userTypedAnswer});

  final CardModel card;
  /// Non-null only in Write mode when we recorded the wrong typed answer.
  final String? userTypedAnswer;
}

/// State of an active or finished quiz session.
class SessionState {
  const SessionState({
    required this.groupId,
    required this.mode,
    required this.requestedCount,
    this.queue = const [],
    this.correctCount = 0,
    this.wrongCount = 0,
    this.missedEntries = const [],
    this.sessionWordIds = const {},
  });

  final String groupId;
  final QuizMode mode;
  final int requestedCount;

  /// Remaining cards to answer (front = current). Wrong answers are moved to end.
  final List<CardModel> queue;

  final int correctCount;
  final int wrongCount;

  /// Entries that were answered wrong (for review at end). Write mode stores userTypedAnswer.
  final List<MissedEntry> missedEntries;

  /// Distinct word IDs in this session (for daily "words touched").
  final Set<String> sessionWordIds;

  CardModel? get currentCard => queue.isNotEmpty ? queue.first : null;

  bool get isFinished => queue.isEmpty;

  SessionState copyWith({
    List<CardModel>? queue,
    int? correctCount,
    int? wrongCount,
    List<MissedEntry>? missedEntries,
    Set<String>? sessionWordIds,
  }) {
    return SessionState(
      groupId: groupId,
      mode: mode,
      requestedCount: requestedCount,
      queue: queue ?? this.queue,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      missedEntries: missedEntries ?? this.missedEntries,
      sessionWordIds: sessionWordIds ?? this.sessionWordIds,
    );
  }
}
