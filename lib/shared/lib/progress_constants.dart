/// All tunable progress knobs live here.
/// Change caps, contribution rates, or retention thresholds in one place.
class ProgressConstants {
  ProgressConstants._();

  // ---------------------------------------------------------------------------
  // MODE CAPS — maximum deck progress reachable per mode (overlapping, not additive)
  // ---------------------------------------------------------------------------

  /// Guessing from native cards (easiest). Progress ceiling: 20%.
  static const double capNativeShown = 20.0;

  /// Guessing from target cards. Progress ceiling: 40%.
  static const double capTargetShown = 40.0;

  /// Writing (training, not test). Progress ceiling: 80%.
  static const double capWrite = 80.0;

  /// Test (write all cards, scored on first pass). No ceiling.
  static const double capTest = 100.0;

  // ---------------------------------------------------------------------------
  // SESSION CONTRIBUTION — how much a single non-test session can add
  // ---------------------------------------------------------------------------

  /// Base points added per session before coverage & accuracy modifiers.
  /// Effective contribution = coverage * accuracy * baseContribution.
  ///   coverage = conceptsInSession / totalConceptsInDeck
  ///   accuracy = correctCount / (correctCount + wrongCount)
  static const double baseContribution = 10.0;

  // ---------------------------------------------------------------------------
  // RETENTION LEVEL CAPS — max retention level based on progress percentage
  // ---------------------------------------------------------------------------

  /// Progress thresholds for retention level capping.
  /// Below threshold → retention level is capped to the corresponding tier.
  static const double retentionCapWeak = 20.0;
  static const double retentionCapGood = 40.0;
  static const double retentionCapStrong = 60.0;
  // Above retentionCapStrong → uncapped (super possible).

  /// Retention floor multiplier. Floor = peakRetention * this value.
  static const double retentionFloorMultiplier = 0.5;
}
