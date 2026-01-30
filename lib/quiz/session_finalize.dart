import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/daily_activity_provider.dart';
import '../providers/test_result_provider.dart';
import 'session_notifier.dart';

/// Persists the current session into today's daily activity and updates
/// [dailyActivityProvider] with the new stats (no read-after-write). Call when
/// the session has just finished (before navigating to result).
/// If session is a test, also saves the test result.
Future<void> persistSessionToDailyActivity(WidgetRef ref) async {
  try {
    final session = ref.read(sessionProvider);
    if (session == null) {
      debugPrint('persistSessionToDailyActivity: session is null');
      return;
    }
    final stats = await ref.read(dailyActivityRepositoryProvider).addSession(
          correct: session.correctCount,
          wrong: session.wrongCount,
          wordIds: session.sessionWordIds,
        );
    ref.read(dailyActivityProvider.notifier).setStats(stats);

    // Save test result if this is a test session
    if (session.isTest) {
      final total = session.correctCount + session.wrongCount;
      final percentage = total > 0
          ? (session.correctCount * 100 / total).round()
          : 0;
      await ref.read(testResultsProvider.notifier).saveResult(
            session.groupId,
            percentage,
          );
    }
  } catch (e, st) {
    debugPrint('persistSessionToDailyActivity error: $e\n$st');
  }
}
