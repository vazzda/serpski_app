import 'package:hive/hive.dart';

import 'models/app_settings.dart';
import 'models/decay_formula.dart';

/// Persists and reads app settings.
class AppSettingsRepository {
  AppSettingsRepository({required Box<dynamic> box}) : _box = box;

  final Box<dynamic> _box;
  static const _settingsKey = 'app_settings';

  /// Returns current app settings.
  AppSettings getSettings() {
    final stored = _box.get(_settingsKey);
    if (stored == null) return const AppSettings();
    try {
      return AppSettings.fromMap(stored as Map<dynamic, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  /// Updates the decay formula.
  Future<void> setDecayFormula(DecayFormula formula) async {
    final current = getSettings();
    final updated = current.copyWith(decayFormula: formula);
    await _box.put(_settingsKey, updated.toMap());
  }

  /// Saves full settings.
  Future<void> saveSettings(AppSettings settings) async {
    await _box.put(_settingsKey, settings.toMap());
  }
}
