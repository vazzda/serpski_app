import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'db_schema.dart';

/// Tracks which terms have been touched per target language (running total).
class LanguageStatsRepository {
  LanguageStatsRepository({required Database db}) : _db = db;

  final Database _db;

  /// Returns the set of term IDs ever touched for a target language.
  Future<Set<String>> getTermsTouched(String targetLang) async {
    final rows = await _db.query(
      DbSchema.tableLanguageStats,
      where: '${DbSchema.colTargetLang} = ?',
      whereArgs: [targetLang],
    );
    if (rows.isEmpty) return {};
    final json = rows.first[DbSchema.colTermsTouchedIds] as String;
    return (jsonDecode(json) as List<dynamic>).cast<String>().toSet();
  }

  /// Deletes all stats for a target language.
  Future<void> deleteForLanguage(String targetLang) async {
    await _db.delete(
      DbSchema.tableLanguageStats,
      where: '${DbSchema.colTargetLang} = ?',
      whereArgs: [targetLang],
    );
  }

  /// Merges new term IDs into the running set for a target language.
  Future<int> addTermsTouched(
      String targetLang, Set<String> newTermIds) async {
    final existing = await getTermsTouched(targetLang);
    existing.addAll(newTermIds);

    await _db.insert(
      DbSchema.tableLanguageStats,
      {
        DbSchema.colTargetLang: targetLang,
        DbSchema.colTermsTouchedIds: jsonEncode(existing.toList()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return existing.length;
  }
}
