import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entities/level/level.dart';
import 'dictionary_provider.dart';
import 'deck_progress_provider.dart';

/// Progress for a single level (0.0–100.0), averaged from its decks.
///
/// Decks with no progress contribute 0.0. Returns 0.0 if the level
/// is not found or has no decks.
final levelProgressProvider = Provider.family<double, String>((ref, levelId) {
  final dictionary = ref.watch(dictionaryProvider).valueOrNull;
  if (dictionary == null) return 0.0;

  Level? level;
  for (final l in dictionary.levels) {
    if (l.id == levelId) {
      level = l;
      break;
    }
  }
  if (level == null || level.deckIds.isEmpty) return 0.0;

  final allProgress = ref.watch(deckProgressProvider);
  final total = level.deckIds.fold(
    0.0,
    (sum, gid) => sum + (allProgress[gid]?.totalProgress ?? 0.0),
  );
  return total / level.deckIds.length;
});
