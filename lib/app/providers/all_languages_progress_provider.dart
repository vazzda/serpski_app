import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dictionary_provider.dart';
import 'group_progress_provider.dart';

/// Returns `Map<langCode, completionFraction>` (0.0–1.0) for all target languages
/// that have at least one group_progress row.
///
/// completionFraction = sum(group.totalProgress) / (totalGroups * 100)
///
/// Watches [groupProgressProvider] so it re-evaluates after sessions are recorded.
final allLanguagesProgressProvider = FutureProvider<Map<String, double>>((ref) async {
  // Re-run whenever current language's progress changes (session recorded).
  ref.watch(groupProgressProvider);

  final repository = ref.read(groupProgressRepositoryProvider);
  final asyncDict = ref.watch(dictionaryProvider);
  final totalGroups = asyncDict.valueOrNull?.groups.length ?? 0;

  if (totalGroups == 0) return {};

  final sumByLang = await repository.getSumProgressAllLanguages();

  return {
    for (final entry in sumByLang.entries)
      entry.key: (entry.value / (totalGroups * 100.0)).clamp(0.0, 1.0),
  };
});
