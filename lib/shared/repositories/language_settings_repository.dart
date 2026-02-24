import 'package:sqflite/sqflite.dart';

import '../../entities/language/language_settings.dart';

/// Reads and writes language settings (target, native, UI) from app_settings table.
class LanguageSettingsRepository {
  LanguageSettingsRepository({required Database db}) : _db = db;

  final Database _db;

  /// Reads current language settings. Returns defaults if not set.
  Future<LanguageSettings> load() async {
    final rows = await _db.query(
      'app_settings',
      where: "key IN ('target_lang', 'native_lang', 'ui_lang')",
    );

    String targetLang = LanguageSettings.defaultSettings.targetLang;
    String nativeLang = LanguageSettings.defaultSettings.nativeLang;
    String uiLang = LanguageSettings.defaultSettings.uiLang;

    for (final row in rows) {
      final key = row['key'] as String;
      final value = row['value'] as String;
      switch (key) {
        case 'target_lang':
          targetLang = value;
        case 'native_lang':
          nativeLang = value;
        case 'ui_lang':
          uiLang = value;
      }
    }

    return LanguageSettings(
      targetLang: targetLang,
      nativeLang: nativeLang,
      uiLang: uiLang,
    );
  }

  /// Persists a single language setting.
  Future<void> _set(String key, String value) async {
    await _db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates target language.
  Future<void> setTargetLang(String code) => _set('target_lang', code);

  /// Updates native language.
  Future<void> setNativeLang(String code) => _set('native_lang', code);

  /// Updates UI language.
  Future<void> setUiLang(String code) => _set('ui_lang', code);
}
