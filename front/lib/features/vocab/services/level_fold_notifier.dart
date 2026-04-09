import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_settings_provider.dart';
import '../../../app/providers/language_settings_provider.dart';
import '../../../shared/repositories/app_settings_repository.dart';

/// Holds user-set fold overrides for level cards, scoped to [targetLang].
/// Map key = levelId, value = isExpanded (true = expanded, false = folded).
/// Absence of a key means no override — default logic applies.
class LevelFoldNotifier extends StateNotifier<Map<String, bool>> {
  LevelFoldNotifier(this._repository, this._targetLang) : super({}) {
    _load();
  }

  final AppSettingsRepository _repository;
  final String _targetLang;

  Future<void> _load() async {
    final data = await _repository.getLevelFoldOverrides(_targetLang);
    if (mounted) state = data;
  }

  /// Toggles and persists the fold state for [levelId].
  Future<void> toggle(String levelId, {required bool currentlyExpanded}) async {
    final next = !currentlyExpanded;
    await _repository.setLevelFoldOverride(_targetLang, levelId, next);
    if (mounted) state = {...state, levelId: next};
  }
}

/// Provider for level fold overrides, scoped to the current target language.
final levelFoldOverridesProvider =
    StateNotifierProvider<LevelFoldNotifier, Map<String, bool>>(
  (ref) {
    final targetLang = ref.watch(languageSettingsProvider).targetLang;
    return LevelFoldNotifier(
      ref.watch(appSettingsRepositoryProvider),
      targetLang,
    );
  },
);
