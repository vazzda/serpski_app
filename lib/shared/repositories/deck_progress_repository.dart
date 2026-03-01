import 'package:sqflite/sqflite.dart';

import 'db_schema.dart';
import 'models/deck_progress.dart';
import 'models/session_record.dart';
import '../../features/quiz/quiz_mode.dart';

/// Persists and reads deck progress via SQLite, scoped by target language.
class DeckProgressRepository {
  DeckProgressRepository({required Database db}) : _db = db;

  final Database _db;

  /// Returns progress for a deck in a target language, or empty progress if none exists.
  Future<DeckProgress> getProgress(String targetLang, String deckId) async {
    final rows = await _db.query(
      DbSchema.tableDeckProgress,
      where: '${DbSchema.colTargetLang} = ? AND ${DbSchema.colDeckId} = ?',
      whereArgs: [targetLang, deckId],
    );
    final sessions = await _getRecentSessions(targetLang, deckId);

    if (rows.isEmpty) return DeckProgress(deckId: deckId);

    final row = rows.first;
    return DeckProgress(
      deckId: deckId,
      targetShownProgress:
          (row[DbSchema.colTargetShownProgress] as num).toDouble(),
      nativeShownProgress:
          (row[DbSchema.colNativeShownProgress] as num).toDouble(),
      writeProgress: (row[DbSchema.colWriteProgress] as num).toDouble(),
      peakRetention: (row[DbSchema.colPeakRetention] as num).toDouble(),
      recentSessions: sessions,
      lastSessionDate: row[DbSchema.colLastSessionDate] != null
          ? DateTime.parse(row[DbSchema.colLastSessionDate] as String)
          : null,
    );
  }

  /// Returns all progress for a target language as a map of deckId → DeckProgress.
  Future<Map<String, DeckProgress>> getAllProgress(String targetLang) async {
    final rows = await _db.query(
      DbSchema.tableDeckProgress,
      where: '${DbSchema.colTargetLang} = ?',
      whereArgs: [targetLang],
    );
    final results = <String, DeckProgress>{};

    for (final row in rows) {
      final deckId = row[DbSchema.colDeckId] as String;
      final sessions = await _getRecentSessions(targetLang, deckId);
      results[deckId] = DeckProgress(
        deckId: deckId,
        targetShownProgress:
            (row[DbSchema.colTargetShownProgress] as num).toDouble(),
        nativeShownProgress:
            (row[DbSchema.colNativeShownProgress] as num).toDouble(),
        writeProgress: (row[DbSchema.colWriteProgress] as num).toDouble(),
        peakRetention: (row[DbSchema.colPeakRetention] as num).toDouble(),
        recentSessions: sessions,
        lastSessionDate: row[DbSchema.colLastSessionDate] != null
            ? DateTime.parse(row[DbSchema.colLastSessionDate] as String)
            : null,
      );
    }
    return results;
  }

  /// Records a session result and updates progress for a deck.
  Future<DeckProgress> recordSession({
    required String targetLang,
    required String deckId,
    required double score,
    required QuizMode mode,
  }) async {
    final current = await getProgress(targetLang, deckId);
    final now = DateTime.now();

    // Insert session record
    await _db.insert(DbSchema.tableSessionRecords, {
      DbSchema.colTargetLang: targetLang,
      DbSchema.colDeckId: deckId,
      DbSchema.colDate: now.toIso8601String(),
      DbSchema.colScore: score,
      DbSchema.colMode: mode.name,
    });

    // Trim to last 3 session records per (target_lang, deck)
    await _db.rawDelete('''
      DELETE FROM ${DbSchema.tableSessionRecords}
      WHERE ${DbSchema.colTargetLang} = ? AND ${DbSchema.colDeckId} = ? AND id NOT IN (
        SELECT id FROM ${DbSchema.tableSessionRecords}
        WHERE ${DbSchema.colTargetLang} = ? AND ${DbSchema.colDeckId} = ?
        ORDER BY ${DbSchema.colDate} DESC
        LIMIT 3
      )
    ''', [targetLang, deckId, targetLang, deckId]);

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
        newWrite = (current.writeProgress + contribution).clamp(0.0, 100.0);
        break;
    }

    // Upsert deck_progress
    await _db.insert(
      DbSchema.tableDeckProgress,
      {
        DbSchema.colTargetLang: targetLang,
        DbSchema.colDeckId: deckId,
        DbSchema.colTargetShownProgress: newTargetShown,
        DbSchema.colNativeShownProgress: newNativeShown,
        DbSchema.colWriteProgress: newWrite,
        DbSchema.colPeakRetention: current.peakRetention,
        DbSchema.colLastSessionDate: now.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return getProgress(targetLang, deckId);
  }

  /// Updates peak retention for a deck (call after calculating current retention).
  Future<void> updatePeakRetention(
      String targetLang, String deckId, double currentRetention) async {
    final current = await getProgress(targetLang, deckId);
    if (currentRetention > current.peakRetention) {
      await _db.update(
        DbSchema.tableDeckProgress,
        {DbSchema.colPeakRetention: currentRetention},
        where:
            '${DbSchema.colTargetLang} = ? AND ${DbSchema.colDeckId} = ?',
        whereArgs: [targetLang, deckId],
      );
    }
  }

  /// Returns summed totalProgress per target language across all decks.
  /// Only includes languages that have at least one deck_progress row.
  Future<Map<String, double>> getSumProgressAllLanguages() async {
    final rows = await _db.query(DbSchema.tableDeckProgress);
    final Map<String, double> sumByLang = {};
    for (final row in rows) {
      final lang = row[DbSchema.colTargetLang] as String;
      final dp = DeckProgress(
        deckId: row[DbSchema.colDeckId] as String,
        targetShownProgress:
            (row[DbSchema.colTargetShownProgress] as num).toDouble(),
        nativeShownProgress:
            (row[DbSchema.colNativeShownProgress] as num).toDouble(),
        writeProgress: (row[DbSchema.colWriteProgress] as num).toDouble(),
      );
      sumByLang[lang] = (sumByLang[lang] ?? 0.0) + dp.totalProgress;
    }
    return sumByLang;
  }

  /// Returns the last 3 session records for a (target_lang, deck), newest first.
  Future<List<SessionRecord>> _getRecentSessions(
      String targetLang, String deckId) async {
    final rows = await _db.query(
      DbSchema.tableSessionRecords,
      where:
          '${DbSchema.colTargetLang} = ? AND ${DbSchema.colDeckId} = ?',
      whereArgs: [targetLang, deckId],
      orderBy: '${DbSchema.colDate} DESC',
      limit: 3,
    );
    return rows
        .map((row) => SessionRecord(
              date: DateTime.parse(row[DbSchema.colDate] as String),
              score: (row[DbSchema.colScore] as num).toDouble(),
              mode: QuizMode.values.firstWhere(
                (m) => m.name == row[DbSchema.colMode],
                orElse: () => QuizMode.write,
              ),
            ))
        .toList();
  }
}
