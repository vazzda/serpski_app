import 'dart:math' as math;

import '../repositories/models/decay_formula.dart';
import '../repositories/models/deck_progress.dart';
import '../repositories/models/retention_level.dart';
import 'progress_constants.dart';

/// Calculates retention and progress for decks.
class ProgressCalculator {
  const ProgressCalculator._();

  /// Calculate current retention percentage (0-100) for a deck.
  /// Uses weighted average of recent rounds with time decay.
  /// Retention cannot drop below floor (half of peak retention).
  static double calculateRetention(
    DeckProgress progress,
    DecayFormula formula,
  ) {
    if (progress.recentRounds.isEmpty) {
      return 0.0;
    }

    final now = DateTime.now();
    final halfLife = formula.halfLifeDays.toDouble();
    double totalWeight = 0.0;
    double weightedSum = 0.0;

    for (final round in progress.recentRounds) {
      final daysSince = now.difference(round.date).inHours / 24.0;
      // Exponential decay: 0.5^(days / halfLife)
      final decay = math.pow(0.5, daysSince / halfLife);
      final weight = decay;
      weightedSum += round.score * weight;
      totalWeight += weight;
    }

    if (totalWeight <= 0) return 0.0;

    final rawRetention = weightedSum / totalWeight;
    final floor = progress.retentionFloor;

    return rawRetention.clamp(floor, 100.0);
  }

  /// Get retention level from percentage, capped by progress.
  /// You can't have high retention on material you haven't covered.
  static RetentionLevel getRetentionLevel(
    double retentionPercentage,
    double progressPercentage,
  ) {
    final rawLevel = RetentionLevelExtension.fromPercentage(retentionPercentage);

    // Cap retention level based on progress (thresholds in ProgressConstants)
    RetentionLevel maxLevel;
    if (progressPercentage <= ProgressConstants.retentionCapWeak) {
      maxLevel = RetentionLevel.weak;
    } else if (progressPercentage <= ProgressConstants.retentionCapGood) {
      maxLevel = RetentionLevel.good;
    } else if (progressPercentage <= ProgressConstants.retentionCapStrong) {
      maxLevel = RetentionLevel.strong;
    } else {
      maxLevel = RetentionLevel.super_;
    }

    // Return the lower of raw level and max level
    if (rawLevel.index > maxLevel.index) {
      return maxLevel;
    }
    return rawLevel;
  }

  /// Calculate if peak retention should be updated.
  static bool shouldUpdatePeak(DeckProgress progress, double currentRetention) {
    return currentRetention > progress.peakRetention;
  }
}
