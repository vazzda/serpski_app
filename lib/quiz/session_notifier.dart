import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/card_model.dart';
import '../data/models/group_model.dart';
import 'quiz_mode.dart';
import 'session_state.dart';

/// Builds initial queue and set of distinct word IDs for the session.
/// Words group: wordId = groupId:serbian (infinitive). Endings: wordId = groupId:blockIndex.
({List<CardModel> queue, Set<String> wordIds}) _buildQueueAndWordIds(
  GroupModel group,
  int count,
) {
  if (group.cards.isEmpty) return (queue: [], wordIds: {});
  final indices = List.generate(group.cards.length, (i) => i)..shuffle(Random());
  final take = count.clamp(1, indices.length);
  final selected = indices.take(take).toList();
  final queue = selected.map((i) => group.cards[i]).toList();
  final wordIds = <String>{};
  for (final i in selected) {
    if (group.type == GroupType.words) {
      wordIds.add('${group.id}:${group.cards[i].serbian}');
    } else {
      wordIds.add('${group.id}:${i ~/ 6}');
    }
  }
  return (queue: queue, wordIds: wordIds);
}

/// Notifier that holds session state and applies answer (correct → remove from queue; wrong → move to end, add to missed).
class SessionNotifier extends StateNotifier<SessionState?> {
  SessionNotifier(Ref ref) : super(null);

  void start({
    required GroupModel group,
    required QuizMode mode,
    required int questionCount,
  }) {
    final result = _buildQueueAndWordIds(group, questionCount);
    state = SessionState(
      groupId: group.id,
      mode: mode,
      requestedCount: questionCount,
      queue: result.queue,
      sessionWordIds: result.wordIds,
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
