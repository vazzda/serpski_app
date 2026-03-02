import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_settings_provider.dart';
import '../../../app/providers/daily_activity_provider.dart';
import '../../../app/providers/deck_progress_provider.dart';
import '../../../app/providers/groups_provider.dart';
import '../../../app/providers/language_settings_provider.dart';
import '../../../app/providers/language_stats_provider.dart';
import '../../../app/router/app_router.dart';
import 'package:srpski_card/shared/lib/progress_calculator.dart';
import 'package:srpski_card/shared/lib/progress_constants.dart';
import '../quiz_mode.dart';
import '../session_notifier.dart';

/// Service for session lifecycle operations.
/// Handles persistence, provider cleanup, and invalidation sequences.
class QuizSessionService {
  QuizSessionService(this._ref);

  final Ref _ref;

  /// Whether the last persisted session actually contributed to progress.
  /// `false` when session mode cap was already exceeded.
  bool lastSessionContributed = true;

  /// Persists the current session into today's daily activity and deck progress.
  /// Updates all relevant providers with the new stats.
  Future<void> persistSession() async {
    try {
      final session = _ref.read(sessionProvider);
      if (session == null) {
        debugPrint('QuizSessionService.persistSession: session is null');
        return;
      }
      final targetLang = _ref.read(languageSettingsProvider).targetLang;
      final stats = await _ref.read(dailyActivityRepositoryProvider).addSession(
            targetLang: targetLang,
            correct: session.correctCount,
            wrong: session.wrongCount,
            wordIds: session.sessionWordIds,
          );
      _ref.read(dailyActivityProvider.notifier).setStats(stats);

      // Calculate session score (all attempts)
      final total = session.correctCount + session.wrongCount;
      final score = total > 0 ? (session.correctCount * 100.0 / total) : 0.0;

      if (session.isTest) {
        await _persistTestSession(session, targetLang, score);
      } else {
        await _persistTrainingSession(session, targetLang, score);
      }

      // Update peak retention if needed
      final settings = _ref.read(appSettingsProvider);
      final progress =
          _ref.read(deckProgressProvider.notifier).getProgress(session.deckId);
      final retention =
          ProgressCalculator.calculateRetention(progress, settings.decayFormula);
      if (ProgressCalculator.shouldUpdatePeak(progress, retention)) {
        await _ref
            .read(deckProgressProvider.notifier)
            .updatePeakRetention(session.deckId, retention);
      }

      // Record concepts touched for vocab sessions (language-level progress)
      if (session.allCards != null) {
        final conceptIds = session.sessionWordIds
            .map((wid) => wid.split(':').first)
            .toSet();
        await _ref
            .read(languageStatsRepositoryProvider)
            .addConceptsTouched(targetLang, conceptIds);
      }
    } catch (e, st) {
      debugPrint('QuizSessionService.persistSession error: $e\n$st');
    }
  }

  Future<void> _persistTestSession(
    dynamic session,
    String targetLang,
    double sessionScore,
  ) async {
    // First-pass score: cards correct on first attempt / total deck concepts
    final totalConcepts = session.totalDeckConcepts;
    final firstPassScore = totalConcepts > 0
        ? (session.firstPassCorrect * 100.0 / totalConcepts)
        : 0.0;

    lastSessionContributed =
        await _ref.read(deckProgressProvider.notifier).recordTestResult(
              deckId: session.deckId,
              firstPassScore: firstPassScore,
              sessionScore: sessionScore,
              mode: session.mode,
            );
  }

  Future<void> _persistTrainingSession(
    dynamic session,
    String targetLang,
    double sessionScore,
  ) async {
    final modeCap = _modeCap(session.mode);
    final totalConcepts = session.totalDeckConcepts;
    final coverage = totalConcepts > 0
        ? session.sessionConceptCount / totalConcepts
        : 0.0;
    final total = session.correctCount + session.wrongCount;
    final accuracy = total > 0 ? session.correctCount / total : 0.0;

    lastSessionContributed =
        await _ref.read(deckProgressProvider.notifier).recordSession(
              deckId: session.deckId,
              score: sessionScore,
              mode: session.mode,
              modeCap: modeCap,
              coverage: coverage,
              accuracy: accuracy,
            );
  }

  /// Resolves the progress cap for a given quiz mode (non-test).
  static double _modeCap(QuizMode mode) {
    return switch (mode) {
      QuizMode.nativeShown => ProgressConstants.capNativeShown,
      QuizMode.targetShown => ProgressConstants.capTargetShown,
      QuizMode.write => ProgressConstants.capWrite,
    };
  }

  /// Cleans up session state and returns the origin route for navigation.
  String endSession() {
    final session = _ref.read(sessionProvider);
    final originRoute = session?.originRoute ?? AppRoutes.home;
    final scrollOffset = session?.originScrollOffset ?? 0.0;
    _ref.read(scrollOffsetToRestoreProvider.notifier).state = scrollOffset;
    _ref.read(sessionProvider.notifier).endSession();
    _ref.read(selectedGroupProvider.notifier).state = null;
    return originRoute;
  }
}

final quizSessionServiceProvider = Provider<QuizSessionService>((ref) {
  return QuizSessionService(ref);
});
