import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/repositories/daily_activity_repository.dart';
import 'language_settings_provider.dart';

/// Must be overridden in main.dart with a Database-backed instance.
final dailyActivityRepositoryProvider = Provider<DailyActivityRepository>((ref) {
  throw UnimplementedError('dailyActivityRepositoryProvider must be overridden');
});

/// Today's stats (correct, wrong, distinct words touched), scoped by current target language.
class DailyActivityNotifier extends StateNotifier<AsyncValue<DailyActivityStats>> {
  DailyActivityNotifier(this._ref, this._targetLang)
      : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;
  final String _targetLang;

  Future<void> _load() async {
    if (!state.hasValue && mounted) state = const AsyncValue.loading();
    try {
      final repo = _ref.read(dailyActivityRepositoryProvider);
      final stats = await repo.readToday(_targetLang);
      if (mounted) state = AsyncValue.data(stats);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  /// Set stats directly after persisting a session (avoids read-after-write timing).
  void setStats(DailyActivityStats stats) {
    state = AsyncValue.data(stats);
  }

  /// Reload from storage.
  Future<void> load() async {
    await _load();
  }
}

final dailyActivityProvider =
    StateNotifierProvider<DailyActivityNotifier, AsyncValue<DailyActivityStats>>(
  (ref) {
    final targetLang = ref.watch(languageSettingsProvider).targetLang;
    return DailyActivityNotifier(ref, targetLang);
  },
);
