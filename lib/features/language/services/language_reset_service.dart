import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/daily_activity_provider.dart';
import '../../../app/providers/deck_progress_provider.dart';
import '../../../app/providers/all_languages_progress_provider.dart';
import '../../../app/providers/language_settings_provider.dart';
import '../../../app/providers/language_stats_provider.dart';

/// Orchestrates a full progress reset for a single target language.
/// Clears deck_progress, round_records, language_stats, and daily_activity.
class LanguageResetService {
  LanguageResetService(this._ref);

  final Ref _ref;

  /// Deletes all progress data for [targetLang] and refreshes providers.
  Future<void> resetLanguage(String targetLang) async {
    final deckProgressRepo = _ref.read(deckProgressRepositoryProvider);
    final languageStatsRepo = _ref.read(languageStatsRepositoryProvider);
    final dailyActivityRepo = _ref.read(dailyActivityRepositoryProvider);

    await deckProgressRepo.deleteForLanguage(targetLang);
    await languageStatsRepo.deleteForLanguage(targetLang);
    await dailyActivityRepo.deleteForLanguage(targetLang);

    // Refresh providers
    _ref.invalidate(allLanguagesProgressProvider);

    final currentTarget = _ref.read(languageSettingsProvider).targetLang;
    if (targetLang == currentTarget) {
      await _ref.read(deckProgressProvider.notifier).reload();
      await _ref.read(dailyActivityProvider.notifier).load();
    }
  }
}

final languageResetServiceProvider = Provider<LanguageResetService>((ref) {
  return LanguageResetService(ref);
});
