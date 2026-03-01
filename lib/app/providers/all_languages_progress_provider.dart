import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dictionary_provider.dart';
import 'deck_progress_provider.dart';

/// Returns `Map<langCode, completionFraction>` (0.0–1.0) for all target languages
/// that have at least one deck_progress row.
///
/// completionFraction = sum(group.totalProgress) / (totalDecks * 100)
///
/// Watches [deckProgressProvider] so it re-evaluates after sessions are recorded.
final allLanguagesProgressProvider = FutureProvider<Map<String, double>>((ref) async {
  // Re-run whenever current language's progress changes (session recorded).
  ref.watch(deckProgressProvider);

  final repository = ref.read(deckProgressRepositoryProvider);
  final asyncDict = ref.watch(dictionaryProvider);
  final totalDecks = asyncDict.valueOrNull?.decks.length ?? 0;

  if (totalDecks == 0) return {};

  final sumByLang = await repository.getSumProgressAllLanguages();

  return {
    for (final entry in sumByLang.entries)
      entry.key: (entry.value / (totalDecks * 100.0)).clamp(0.0, 1.0),
  };
});
