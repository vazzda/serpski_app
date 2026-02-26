import 'package:sqflite/sqflite.dart';

import 'models/group_progress.dart';
import 'models/session_record.dart';
import '../../features/quiz/quiz_mode.dart';

/// Persists and reads group progress via SQLite, scoped by target language.
class GroupProgressRepository {
  GroupProgressRepository({required Database db}) : _db = db;

  final Database _db;

  /// Returns progress for a group in a target language, or empty progress if none exists.
  Future<GroupProgress> getProgress(String targetLang, String groupId) async {
    final rows = await _db.query(
      'group_progress',
      where: 'target_lang = ? AND group_id = ?',
      whereArgs: [targetLang, groupId],
    );
    final sessions = await _getRecentSessions(targetLang, groupId);

    if (rows.isEmpty) return GroupProgress(groupId: groupId);

    final row = rows.first;
    return GroupProgress(
      groupId: groupId,
      targetShownProgress: (row['target_shown_progress'] as num).toDouble(),
      nativeShownProgress: (row['native_shown_progress'] as num).toDouble(),
      writeProgress: (row['write_progress'] as num).toDouble(),
      peakRetention: (row['peak_retention'] as num).toDouble(),
      recentSessions: sessions,
      lastSessionDate: row['last_session_date'] != null
          ? DateTime.parse(row['last_session_date'] as String)
          : null,
    );
  }

  /// Returns all progress for a target language as a map of groupId → GroupProgress.
  Future<Map<String, GroupProgress>> getAllProgress(String targetLang) async {
    final rows = await _db.query(
      'group_progress',
      where: 'target_lang = ?',
      whereArgs: [targetLang],
    );
    final results = <String, GroupProgress>{};

    for (final row in rows) {
      final groupId = row['group_id'] as String;
      final sessions = await _getRecentSessions(targetLang, groupId);
      results[groupId] = GroupProgress(
        groupId: groupId,
        targetShownProgress:
            (row['target_shown_progress'] as num).toDouble(),
        nativeShownProgress:
            (row['native_shown_progress'] as num).toDouble(),
        writeProgress: (row['write_progress'] as num).toDouble(),
        peakRetention: (row['peak_retention'] as num).toDouble(),
        recentSessions: sessions,
        lastSessionDate: row['last_session_date'] != null
            ? DateTime.parse(row['last_session_date'] as String)
            : null,
      );
    }
    return results;
  }

  /// Records a session result and updates progress for a group.
  Future<GroupProgress> recordSession({
    required String targetLang,
    required String groupId,
    required double score,
    required QuizMode mode,
  }) async {
    final current = await getProgress(targetLang, groupId);
    final now = DateTime.now();

    // Insert session record
    await _db.insert('session_records', {
      'target_lang': targetLang,
      'group_id': groupId,
      'date': now.toIso8601String(),
      'score': score,
      'mode': mode.name,
    });

    // Trim to last 3 session records per (target_lang, group)
    await _db.rawDelete('''
      DELETE FROM session_records
      WHERE target_lang = ? AND group_id = ? AND id NOT IN (
        SELECT id FROM session_records
        WHERE target_lang = ? AND group_id = ?
        ORDER BY date DESC
        LIMIT 3
      )
    ''', [targetLang, groupId, targetLang, groupId]);

    // Calculate progress contribution
    const sessionContribution = 10.0;
    double newTargetShown = current.targetShownProgress;
    double newNativeShown = current.nativeShownProgress;
    double newWrite = current.writeProgress;

    final contribution = (score / 100.0) * sessionContribution;

    switch (mode) {
      case QuizMode.targetShown:
        newTargetShown =
            (current.targetShownProgress + contribution).clamp(0.0, 100.0);
        break;
      case QuizMode.nativeShown:
        newNativeShown =
            (current.nativeShownProgress + contribution).clamp(0.0, 100.0);
        break;
      case QuizMode.write:
        newWrite =
            (current.writeProgress + contribution).clamp(0.0, 100.0);
        break;
    }

    // Upsert group_progress
    await _db.insert(
      'group_progress',
      {
        'target_lang': targetLang,
        'group_id': groupId,
        'target_shown_progress': newTargetShown,
        'native_shown_progress': newNativeShown,
        'write_progress': newWrite,
        'peak_retention': current.peakRetention,
        'last_session_date': now.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return getProgress(targetLang, groupId);
  }

  /// Updates peak retention for a group (call after calculating current retention).
  Future<void> updatePeakRetention(
      String targetLang, String groupId, double currentRetention) async {
    final current = await getProgress(targetLang, groupId);
    if (currentRetention > current.peakRetention) {
      await _db.update(
        'group_progress',
        {'peak_retention': currentRetention},
        where: 'target_lang = ? AND group_id = ?',
        whereArgs: [targetLang, groupId],
      );
    }
  }

  /// Returns summed totalProgress per target language across all groups.
  /// Only includes languages that have at least one group_progress row.
  Future<Map<String, double>> getSumProgressAllLanguages() async {
    final rows = await _db.query('group_progress');
    final Map<String, double> sumByLang = {};
    for (final row in rows) {
      final lang = row['target_lang'] as String;
      final gp = GroupProgress(
        groupId: row['group_id'] as String,
        targetShownProgress: (row['target_shown_progress'] as num).toDouble(),
        nativeShownProgress: (row['native_shown_progress'] as num).toDouble(),
        writeProgress: (row['write_progress'] as num).toDouble(),
      );
      sumByLang[lang] = (sumByLang[lang] ?? 0.0) + gp.totalProgress;
    }
    return sumByLang;
  }

  /// Returns the last 3 session records for a (target_lang, group), newest first.
  Future<List<SessionRecord>> _getRecentSessions(
      String targetLang, String groupId) async {
    final rows = await _db.query(
      'session_records',
      where: 'target_lang = ? AND group_id = ?',
      whereArgs: [targetLang, groupId],
      orderBy: 'date DESC',
      limit: 3,
    );
    return rows.map((row) => SessionRecord(
      date: DateTime.parse(row['date'] as String),
      score: (row['score'] as num).toDouble(),
      mode: QuizMode.values.firstWhere(
        (m) => m.name == row['mode'],
        orElse: () => QuizMode.write,
      ),
    )).toList();
  }
}
