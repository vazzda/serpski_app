import '../../entities/card/card_model.dart';
import 'quiz_mode.dart';

/// Type of session (for title, "Again", and options).
enum SessionType { vocabulary, conjugations, agreement }

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
    required this.deckId,
    required this.mode,
    required this.requestedCount,
    required this.sessionType,
    required this.originRoute,
    this.originScrollOffset = 0.0,
    this.adjectiveGroupId,
    this.deckName,
    this.isTest = false,
    this.totalDeckConcepts = 0,
    this.queue = const [],
    this.allCards,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.firstPassCorrect = 0,
    this.attemptedCardIds = const {},
    this.missedEntries = const [],
    this.sessionWordIds = const {},
  });

  final String deckId;
  final QuizMode mode;
  final int requestedCount;
  final SessionType sessionType;
  /// Route to navigate back to when session ends or is cancelled.
  final String originRoute;
  /// Scroll offset to restore when navigating back to origin.
  final double originScrollOffset;
  /// For agreement sessions: the adjective group id (without "agreement:" prefix).
  final String? adjectiveGroupId;
  /// Resolved deck name for session title display (from meta system).
  final String? deckName;

  /// Whether this is a test session (direct score → progress, ratchet only).
  final bool isTest;

  /// Total concepts in the deck (for coverage calculation).
  final int totalDeckConcepts;

  /// Remaining cards to answer (front = current). Wrong answers are moved to end.
  final List<CardModel> queue;

  /// All cards generated for this session (for MCQ option pool).
  /// Set for vocab sessions; null for legacy/agreement sessions (which use group.cards).
  final List<CardModel>? allCards;

  final int correctCount;
  final int wrongCount;

  /// Cards answered correctly on first attempt (for test scoring).
  final int firstPassCorrect;

  /// Card IDs that have been attempted at least once (for first-pass detection).
  final Set<String> attemptedCardIds;

  /// Entries that were answered wrong (for review at end). Write mode stores userTypedAnswer.
  final List<MissedEntry> missedEntries;

  /// Distinct word IDs in this session (for daily "words touched").
  final Set<String> sessionWordIds;

  CardModel? get currentCard => queue.isNotEmpty ? queue.first : null;

  bool get isFinished => queue.isEmpty;

  /// Number of unique concepts in this session (for coverage calculation).
  int get sessionConceptCount => sessionWordIds.length;

  SessionState copyWith({
    List<CardModel>? queue,
    int? correctCount,
    int? wrongCount,
    int? firstPassCorrect,
    Set<String>? attemptedCardIds,
    List<MissedEntry>? missedEntries,
    Set<String>? sessionWordIds,
  }) {
    return SessionState(
      deckId: deckId,
      mode: mode,
      requestedCount: requestedCount,
      sessionType: sessionType,
      originRoute: originRoute,
      originScrollOffset: originScrollOffset,
      adjectiveGroupId: adjectiveGroupId,
      deckName: deckName,
      isTest: isTest,
      totalDeckConcepts: totalDeckConcepts,
      queue: queue ?? this.queue,
      allCards: allCards,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      firstPassCorrect: firstPassCorrect ?? this.firstPassCorrect,
      attemptedCardIds: attemptedCardIds ?? this.attemptedCardIds,
      missedEntries: missedEntries ?? this.missedEntries,
      sessionWordIds: sessionWordIds ?? this.sessionWordIds,
    );
  }
}
