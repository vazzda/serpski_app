import 'package:hive/hive.dart';

/// Per-day stats: correct, wrong, and distinct word IDs touched today.
class DailyActivityStats {
  const DailyActivityStats({
    this.correct = 0,
    this.wrong = 0,
    this.wordsTouched = 0,
  });

  final int correct;
  final int wrong;
  final int wordsTouched;
}

String _dateKey(DateTime date) {
  final y = date.year;
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return 'daily_activity_$y-$m-$d';
}

/// Persists and reads daily activity (correct, wrong, distinct words) per calendar day.
class DailyActivityRepository {
  DailyActivityRepository({required Box<dynamic> box}) : _box = box;

  final Box<dynamic> _box;

  /// Returns today's stats (local date).
  Future<DailyActivityStats> readToday() async {
    final key = _dateKey(DateTime.now());
    final stored = _box.get(key);
    if (stored == null) return const DailyActivityStats();
    try {
      final map = stored as Map<dynamic, dynamic>;
      final correct = (map['correct'] as num?)?.toInt() ?? 0;
      final wrong = (map['wrong'] as num?)?.toInt() ?? 0;
      final ids = (map['wordIds'] as List<dynamic>?)?.cast<String>() ?? [];
      return DailyActivityStats(
        correct: correct,
        wrong: wrong,
        wordsTouched: ids.length,
      );
    } catch (_) {
      return const DailyActivityStats();
    }
  }

  /// Merges a completed session into today's totals. [wordIds] = distinct word IDs from that session.
  /// Returns the new daily stats after the merge (so UI can update without reading back).
  Future<DailyActivityStats> addSession({
    required int correct,
    required int wrong,
    required Set<String> wordIds,
  }) async {
    final key = _dateKey(DateTime.now());
    final stored = _box.get(key);
    int totalCorrect = correct;
    int totalWrong = wrong;
    final Set<String> allIds = Set.from(wordIds);
    if (stored != null) {
      try {
        final map = stored as Map<dynamic, dynamic>;
        totalCorrect += (map['correct'] as num?)?.toInt() ?? 0;
        totalWrong += (map['wrong'] as num?)?.toInt() ?? 0;
        final list = (map['wordIds'] as List<dynamic>?)?.cast<String>() ?? [];
        allIds.addAll(list);
      } catch (_) {}
    }
    final map = <String, dynamic>{
      'correct': totalCorrect,
      'wrong': totalWrong,
      'wordIds': allIds.toList(),
    };
    await _box.put(key, map);
    return DailyActivityStats(
      correct: totalCorrect,
      wrong: totalWrong,
      wordsTouched: allIds.length,
    );
  }
}
