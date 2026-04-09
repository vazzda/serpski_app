import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entities/language/language_settings.dart';
import '../../shared/repositories/language_settings_repository.dart';

/// Provider for the language settings repository. Must be overridden in main.dart.
final languageSettingsRepositoryProvider =
    Provider<LanguageSettingsRepository>((ref) {
  throw UnimplementedError(
      'languageSettingsRepositoryProvider must be overridden');
});

/// Notifier that holds current language settings and persists changes.
class LanguageSettingsNotifier extends StateNotifier<LanguageSettings> {
  LanguageSettingsNotifier(this._repository)
      : super(LanguageSettings.defaultSettings) {
    _load();
  }

  final LanguageSettingsRepository _repository;

  Future<void> _load() async {
    state = await _repository.load();
  }

  Future<void> setTargetLang(String code) async {
    await _repository.setTargetLang(code);
    state = state.copyWith(targetLang: code);
  }

  Future<void> setNativeLang(String code) async {
    await _repository.setNativeLang(code);
    state = state.copyWith(nativeLang: code);
  }

  Future<void> setUiLang(String code) async {
    await _repository.setUiLang(code);
    state = state.copyWith(uiLang: code);
  }
}

/// Provider for language settings.
final languageSettingsProvider =
    StateNotifierProvider<LanguageSettingsNotifier, LanguageSettings>(
  (ref) => LanguageSettingsNotifier(
      ref.watch(languageSettingsRepositoryProvider)),
);
