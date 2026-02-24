import 'session_record.dart';

/// Progress tracking for a single group, scoped by target language.
class GroupProgress {
  const GroupProgress({
    required this.groupId,
    this.targetShownProgress = 0.0,
    this.nativeShownProgress = 0.0,
    this.writeProgress = 0.0,
    this.peakRetention = 0.0,
    this.recentSessions = const [],
    this.lastSessionDate,
  });

  final String groupId;

  /// Progress from targetShown mode (0-100). Contributes max 20% to total.
  final double targetShownProgress;

  /// Progress from nativeShown mode (0-100). Contributes max 20% to total.
  final double nativeShownProgress;

  /// Progress from write mode (0-100). Contributes max 60% to total.
  final double writeProgress;

  /// Highest retention ever achieved. Used to calculate decay floor.
  final double peakRetention;

  /// Last 3 sessions for retention calculation.
  final List<SessionRecord> recentSessions;

  /// Date of most recent session.
  final DateTime? lastSessionDate;

  /// Mode contribution caps.
  static const double targetShownCap = 20.0;
  static const double nativeShownCap = 20.0;
  static const double writeCap = 60.0;

  /// Total progress (0-100) with mode caps applied.
  double get totalProgress {
    final targetCapped = (targetShownProgress / 100.0 * targetShownCap)
        .clamp(0.0, targetShownCap);
    final nativeCapped = (nativeShownProgress / 100.0 * nativeShownCap)
        .clamp(0.0, nativeShownCap);
    final writeCapped =
        (writeProgress / 100.0 * writeCap).clamp(0.0, writeCap);
    return (targetCapped + nativeCapped + writeCapped).clamp(0.0, 100.0);
  }

  /// Decay floor - retention cannot drop below half of peak.
  double get retentionFloor => peakRetention * 0.5;

  GroupProgress copyWith({
    double? targetShownProgress,
    double? nativeShownProgress,
    double? writeProgress,
    double? peakRetention,
    List<SessionRecord>? recentSessions,
    DateTime? lastSessionDate,
  }) {
    return GroupProgress(
      groupId: groupId,
      targetShownProgress: targetShownProgress ?? this.targetShownProgress,
      nativeShownProgress: nativeShownProgress ?? this.nativeShownProgress,
      writeProgress: writeProgress ?? this.writeProgress,
      peakRetention: peakRetention ?? this.peakRetention,
      recentSessions: recentSessions ?? this.recentSessions,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
    );
  }

  Map<String, dynamic> toMap() => {
        'groupId': groupId,
        'targetShownProgress': targetShownProgress,
        'nativeShownProgress': nativeShownProgress,
        'writeProgress': writeProgress,
        'peakRetention': peakRetention,
        'recentSessions': recentSessions.map((s) => s.toMap()).toList(),
        'lastSessionDate': lastSessionDate?.toIso8601String(),
      };

  factory GroupProgress.fromMap(Map<dynamic, dynamic> map) {
    final sessionsList = (map['recentSessions'] as List<dynamic>?)
            ?.map((s) => SessionRecord.fromMap(s as Map<dynamic, dynamic>))
            .toList() ??
        [];
    final lastDateStr = map['lastSessionDate'] as String?;
    return GroupProgress(
      groupId: map['groupId'] as String,
      targetShownProgress:
          (map['targetShownProgress'] as num?)?.toDouble() ?? 0.0,
      nativeShownProgress:
          (map['nativeShownProgress'] as num?)?.toDouble() ?? 0.0,
      writeProgress: (map['writeProgress'] as num?)?.toDouble() ?? 0.0,
      peakRetention: (map['peakRetention'] as num?)?.toDouble() ?? 0.0,
      recentSessions: sessionsList,
      lastSessionDate: lastDateStr != null ? DateTime.parse(lastDateStr) : null,
    );
  }
}
