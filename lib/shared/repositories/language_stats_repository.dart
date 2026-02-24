import 'dart:convert';

import 'package:sqflite/sqflite.dart';

/// Tracks which concepts have been touched per target language (running total).
class LanguageStatsRepository {
  LanguageStatsRepository({required Database db}) : _db = db;

  final Database _db;

  /// Returns the set of concept IDs ever touched for a target language.
  Future<Set<String>> getConceptsTouched(String targetLang) async {
    final rows = await _db.query(
      'language_stats',
      where: 'target_lang = ?',
      whereArgs: [targetLang],
    );
    if (rows.isEmpty) return {};
    final json = rows.first['concepts_touched_ids'] as String;
    return (jsonDecode(json) as List<dynamic>).cast<String>().toSet();
  }

  /// Merges new concept IDs into the running set for a target language.
  Future<int> addConceptsTouched(
      String targetLang, Set<String> newConceptIds) async {
    final existing = await getConceptsTouched(targetLang);
    existing.addAll(newConceptIds);

    await _db.insert(
      'language_stats',
      {
        'target_lang': targetLang,
        'concepts_touched_ids': jsonEncode(existing.toList()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return existing.length;
  }
}
