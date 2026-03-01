import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/repositories/deck_progress_repository.dart';
import '../../shared/repositories/models/deck_progress.dart';
import '../../features/quiz/quiz_mode.dart';
import 'language_settings_provider.dart';

/// Provider for the deck progress repository. Must be overridden in main.dart.
final deckProgressRepositoryProvider = Provider<DeckProgressRepository>((ref) {
  throw UnimplementedError('deckProgressRepositoryProvider must be overridden');
});

/// Notifier that holds all deck progress for the current target language.
class DeckProgressNotifier extends StateNotifier<Map<String, DeckProgress>> {
  DeckProgressNotifier(this._repository, this._targetLang) : super({}) {
    _load();
  }

  final DeckProgressRepository _repository;
  final String _targetLang;

  Future<void> _load() async {
    final data = await _repository.getAllProgress(_targetLang);
    if (mounted) state = data;
  }

  /// Record a session result and update state.
  Future<void> recordSession({
    required String deckId,
    required double score,
    required QuizMode mode,
  }) async {
    await _repository.recordSession(
      targetLang: _targetLang,
      deckId: deckId,
      score: score,
      mode: mode,
    );
    final data = await _repository.getAllProgress(_targetLang);
    if (mounted) state = data;
  }

  /// Update peak retention for a deck.
  Future<void> updatePeakRetention(String deckId, double retention) async {
    await _repository.updatePeakRetention(_targetLang, deckId, retention);
    final data = await _repository.getAllProgress(_targetLang);
    if (mounted) state = data;
  }

  /// Get progress for a specific deck from current state.
  DeckProgress getProgress(String deckId) {
    return state[deckId] ?? DeckProgress(deckId: deckId);
  }

  /// Reload from storage.
  Future<void> reload() async {
    await _load();
  }
}

/// Provider for all deck progress (deckId → DeckProgress), scoped by current target language.
final deckProgressProvider =
    StateNotifierProvider<DeckProgressNotifier, Map<String, DeckProgress>>(
  (ref) {
    final targetLang = ref.watch(languageSettingsProvider).targetLang;
    return DeckProgressNotifier(
      ref.watch(deckProgressRepositoryProvider),
      targetLang,
    );
  },
);
