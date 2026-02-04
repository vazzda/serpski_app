import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_settings_provider.dart';
import '../providers/daily_activity_provider.dart';
import '../providers/group_progress_provider.dart';
import '../utils/progress_calculator.dart';
import 'session_notifier.dart';

/// Persists the current session into today's daily activity and group progress.
/// Updates [dailyActivityProvider] and [groupProgressProvider] with new stats.
/// Call when the session has just finished (before navigating to result).
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

    // Calculate session score and record progress
    final total = session.correctCount + session.wrongCount;
    final score = total > 0 ? (session.correctCount * 100.0 / total) : 0.0;

    await ref.read(groupProgressProvider.notifier).recordSession(
          groupId: session.groupId,
          score: score,
          mode: session.mode,
        );

    // Update peak retention if needed
    final settings = ref.read(appSettingsProvider);
    final progress =
        ref.read(groupProgressProvider.notifier).getProgress(session.groupId);
    final retention =
        ProgressCalculator.calculateRetention(progress, settings.decayFormula);
    if (ProgressCalculator.shouldUpdatePeak(progress, retention)) {
      await ref
          .read(groupProgressProvider.notifier)
          .updatePeakRetention(session.groupId, retention);
    }
  } catch (e, st) {
    debugPrint('persistSessionToDailyActivity error: $e\n$st');
  }
}
