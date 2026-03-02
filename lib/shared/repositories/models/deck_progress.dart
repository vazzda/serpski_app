import 'package:srpski_card/shared/lib/progress_constants.dart';
import 'session_record.dart';

/// Progress tracking for a single deck, scoped by target language.
///
/// Single [progress] value (0–100) with mode-based caps:
///   nativeShown → 20%  |  targetShown → 40%  |  write → 80%  |  test → 100%
/// Caps overlap (not additive). See [ProgressConstants] for tuning.
class DeckProgress {
  const DeckProgress({
    required this.deckId,
    this.progress = 0.0,
    this.peakRetention = 0.0,
    this.recentSessions = const [],
    this.lastSessionDate,
  });

  final String deckId;

  /// Unified deck progress (0–100).
  final double progress;

  /// Highest retention ever achieved. Used to calculate decay floor.
  final double peakRetention;

  /// Last 3 sessions for retention calculation.
  final List<SessionRecord> recentSessions;

  /// Date of most recent session.
  final DateTime? lastSessionDate;

  /// Alias for consistency with existing UI code.
  double get totalProgress => progress;

  /// Decay floor — retention cannot drop below this.
  double get retentionFloor =>
      peakRetention * ProgressConstants.retentionFloorMultiplier;

  DeckProgress copyWith({
    double? progress,
    double? peakRetention,
    List<SessionRecord>? recentSessions,
    DateTime? lastSessionDate,
  }) {
    return DeckProgress(
      deckId: deckId,
      progress: progress ?? this.progress,
      peakRetention: peakRetention ?? this.peakRetention,
      recentSessions: recentSessions ?? this.recentSessions,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
    );
  }

  Map<String, dynamic> toMap() => {
        'deckId': deckId,
        'progress': progress,
        'peakRetention': peakRetention,
        'recentSessions': recentSessions.map((s) => s.toMap()).toList(),
        'lastSessionDate': lastSessionDate?.toIso8601String(),
      };

  factory DeckProgress.fromMap(Map<dynamic, dynamic> map) {
    final sessionsList = (map['recentSessions'] as List<dynamic>?)
            ?.map((s) => SessionRecord.fromMap(s as Map<dynamic, dynamic>))
            .toList() ??
        [];
    final lastDateStr = map['lastSessionDate'] as String?;
    return DeckProgress(
      deckId: map['deckId'] as String,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      peakRetention: (map['peakRetention'] as num?)?.toDouble() ?? 0.0,
      recentSessions: sessionsList,
      lastSessionDate:
          lastDateStr != null ? DateTime.parse(lastDateStr) : null,
    );
  }
}
