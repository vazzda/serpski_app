import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/test_result_repository.dart';

/// Provider for the test result repository. Must be overridden in main.dart.
final testResultRepositoryProvider = Provider<TestResultRepository>((ref) {
  throw UnimplementedError('testResultRepositoryProvider must be overridden');
});

/// Notifier that holds all test results and can update them.
class TestResultsNotifier extends StateNotifier<Map<String, TestResult>> {
  TestResultsNotifier(this._repository) : super({}) {
    _load();
  }

  final TestResultRepository _repository;

  void _load() {
    state = _repository.getAllResults();
  }

  /// Save a test result and update state.
  Future<void> saveResult(String groupId, int percentage) async {
    await _repository.saveResult(groupId, percentage);
    state = _repository.getAllResults();
  }

  /// Reload from storage.
  void reload() {
    _load();
  }
}

/// Provider for all test results (groupId → TestResult).
final testResultsProvider =
    StateNotifierProvider<TestResultsNotifier, Map<String, TestResult>>(
  (ref) => TestResultsNotifier(ref.watch(testResultRepositoryProvider)),
);
