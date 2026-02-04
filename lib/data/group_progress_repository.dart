import 'package:hive/hive.dart';

import 'models/group_progress.dart';
import 'models/session_record.dart';
import '../quiz/quiz_mode.dart';

/// Persists and reads group progress.
class GroupProgressRepository {
  GroupProgressRepository({required Box<dynamic> box}) : _box = box;

  final Box<dynamic> _box;

  /// Returns progress for a group, or empty progress if none exists.
  GroupProgress getProgress(String groupId) {
    final stored = _box.get(groupId);
    if (stored == null) return GroupProgress(groupId: groupId);
    try {
      return GroupProgress.fromMap(stored as Map<dynamic, dynamic>);
    } catch (_) {
      return GroupProgress(groupId: groupId);
    }
  }

  /// Returns all progress as a map of groupId → GroupProgress.
  Map<String, GroupProgress> getAllProgress() {
    final results = <String, GroupProgress>{};
    for (final key in _box.keys) {
      final progress = getProgress(key as String);
      results[key] = progress;
    }
    return results;
  }

  /// Records a session result and updates progress for a group.
  Future<GroupProgress> recordSession({
    required String groupId,
    required double score,
    required QuizMode mode,
  }) async {
    final current = getProgress(groupId);
    final now = DateTime.now();

    // Create session record
    final sessionRecord = SessionRecord(
      date: now,
      score: score,
      mode: mode,
    );

    // Update recent sessions (keep last 3)
    final updatedSessions = [sessionRecord, ...current.recentSessions];
    if (updatedSessions.length > 3) {
      updatedSessions.removeRange(3, updatedSessions.length);
    }

    // Calculate progress contribution from this session
    // Each session can add up to 10% to the mode's progress (with diminishing returns)
    const sessionContribution = 10.0;
    double newSerbianProgress = current.serbianCardsProgress;
    double newEnglishProgress = current.englishCardsProgress;
    double newWriteProgress = current.writeProgress;

    final contribution = (score / 100.0) * sessionContribution;

    switch (mode) {
      case QuizMode.serbianShown:
        newSerbianProgress =
            (current.serbianCardsProgress + contribution).clamp(0.0, 100.0);
        break;
      case QuizMode.englishShown:
        newEnglishProgress =
            (current.englishCardsProgress + contribution).clamp(0.0, 100.0);
        break;
      case QuizMode.write:
        newWriteProgress =
            (current.writeProgress + contribution).clamp(0.0, 100.0);
        break;
    }

    final updated = current.copyWith(
      serbianCardsProgress: newSerbianProgress,
      englishCardsProgress: newEnglishProgress,
      writeProgress: newWriteProgress,
      recentSessions: updatedSessions,
      lastSessionDate: now,
    );

    await _box.put(groupId, updated.toMap());
    return updated;
  }

  /// Updates peak retention for a group (call after calculating current retention).
  Future<void> updatePeakRetention(
      String groupId, double currentRetention) async {
    final current = getProgress(groupId);
    if (currentRetention > current.peakRetention) {
      final updated = current.copyWith(peakRetention: currentRetention);
      await _box.put(groupId, updated.toMap());
    }
  }
}
