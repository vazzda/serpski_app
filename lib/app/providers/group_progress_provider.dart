import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/repositories/group_progress_repository.dart';
import '../../shared/repositories/models/group_progress.dart';
import '../../features/quiz/quiz_mode.dart';
import 'language_settings_provider.dart';

/// Provider for the group progress repository. Must be overridden in main.dart.
final groupProgressRepositoryProvider = Provider<GroupProgressRepository>((ref) {
  throw UnimplementedError('groupProgressRepositoryProvider must be overridden');
});

/// Notifier that holds all group progress for the current target language.
class GroupProgressNotifier extends StateNotifier<Map<String, GroupProgress>> {
  GroupProgressNotifier(this._repository, this._targetLang) : super({}) {
    _load();
  }

  final GroupProgressRepository _repository;
  final String _targetLang;

  Future<void> _load() async {
    final data = await _repository.getAllProgress(_targetLang);
    if (mounted) state = data;
  }

  /// Record a session result and update state.
  Future<void> recordSession({
    required String groupId,
    required double score,
    required QuizMode mode,
  }) async {
    await _repository.recordSession(
      targetLang: _targetLang,
      groupId: groupId,
      score: score,
      mode: mode,
    );
    final data = await _repository.getAllProgress(_targetLang);
    if (mounted) state = data;
  }

  /// Update peak retention for a group.
  Future<void> updatePeakRetention(String groupId, double retention) async {
    await _repository.updatePeakRetention(_targetLang, groupId, retention);
    final data = await _repository.getAllProgress(_targetLang);
    if (mounted) state = data;
  }

  /// Get progress for a specific group from current state.
  GroupProgress getProgress(String groupId) {
    return state[groupId] ?? GroupProgress(groupId: groupId);
  }

  /// Reload from storage.
  Future<void> reload() async {
    await _load();
  }
}

/// Provider for all group progress (groupId → GroupProgress), scoped by current target language.
final groupProgressProvider =
    StateNotifierProvider<GroupProgressNotifier, Map<String, GroupProgress>>(
  (ref) {
    final targetLang = ref.watch(languageSettingsProvider).targetLang;
    return GroupProgressNotifier(
      ref.watch(groupProgressRepositoryProvider),
      targetLang,
    );
  },
);
