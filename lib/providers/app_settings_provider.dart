import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_settings_repository.dart';
import '../data/models/app_settings.dart';
import '../data/models/decay_formula.dart';

/// Provider for the app settings repository. Must be overridden in main.dart.
final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  throw UnimplementedError('appSettingsRepositoryProvider must be overridden');
});

/// Notifier that holds app settings and can update them.
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier(this._repository) : super(const AppSettings()) {
    _load();
  }

  final AppSettingsRepository _repository;

  void _load() {
    state = _repository.getSettings();
  }

  /// Update the decay formula.
  Future<void> setDecayFormula(DecayFormula formula) async {
    await _repository.setDecayFormula(formula);
    state = _repository.getSettings();
  }

  /// Reload from storage.
  void reload() {
    _load();
  }
}

/// Provider for app settings.
final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(ref.watch(appSettingsRepositoryProvider)),
);
