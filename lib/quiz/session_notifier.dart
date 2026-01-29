import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/card_model.dart';
import '../data/models/group_model.dart';
import 'quiz_mode.dart';
import 'session_state.dart';

/// Builds initial queue: shuffle group cards and take [count].
List<CardModel> _buildInitialQueue(List<CardModel> cards, int count) {
  if (cards.isEmpty) return [];
  final shuffled = List<CardModel>.from(cards)..shuffle(Random());
  final take = count.clamp(1, shuffled.length);
  return shuffled.take(take).toList();
}

/// Notifier that holds session state and applies answer (correct → remove from queue; wrong → move to end, add to missed).
class SessionNotifier extends StateNotifier<SessionState?> {
  SessionNotifier(Ref ref) : super(null);

  void start({
    required GroupModel group,
    required QuizMode mode,
    required int questionCount,
  }) {
    final queue = _buildInitialQueue(group.cards, questionCount);
    state = SessionState(
      groupId: group.id,
      mode: mode,
      requestedCount: questionCount,
      queue: queue,
    );
  }

  void answerCorrect() {
    if (state == null || state!.queue.isEmpty) return;
    final rest = state!.queue.skip(1).toList();
    state = state!.copyWith(
      queue: rest,
      correctCount: state!.correctCount + 1,
    );
  }

  /// [userTypedAnswer] optional; pass in Write mode to show "you wrote" on result screen.
  void answerWrong({String? userTypedAnswer}) {
    if (state == null || state!.queue.isEmpty) return;
    final card = state!.queue.first;
    final rest = state!.queue.skip(1).toList();
    final entry = MissedEntry(card: card, userTypedAnswer: userTypedAnswer);
    state = state!.copyWith(
      queue: [...rest, card],
      wrongCount: state!.wrongCount + 1,
      missedEntries: [...state!.missedEntries, entry],
    );
  }

  void endSession() {
    state = null;
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState?>((ref) {
  return SessionNotifier(ref);
});
