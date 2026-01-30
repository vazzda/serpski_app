import 'package:hive/hive.dart';

/// Result of a test session for a group.
class TestResult {
  const TestResult({
    required this.percentage,
    required this.date,
  });

  /// Percentage of correct answers (0-100).
  final int percentage;

  /// Date when the test was taken.
  final DateTime date;

  Map<String, dynamic> toMap() => {
        'percentage': percentage,
        'date': date.toIso8601String(),
      };

  factory TestResult.fromMap(Map<dynamic, dynamic> map) {
    return TestResult(
      percentage: (map['percentage'] as num).toInt(),
      date: DateTime.parse(map['date'] as String),
    );
  }
}

/// Persists and reads test results per group.
class TestResultRepository {
  TestResultRepository({required Box<dynamic> box}) : _box = box;

  final Box<dynamic> _box;

  /// Returns the last test result for a group, or null if never tested.
  TestResult? getResult(String groupId) {
    final stored = _box.get(groupId);
    if (stored == null) return null;
    try {
      return TestResult.fromMap(stored as Map<dynamic, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Returns all test results as a map of groupId → TestResult.
  Map<String, TestResult> getAllResults() {
    final results = <String, TestResult>{};
    for (final key in _box.keys) {
      final result = getResult(key as String);
      if (result != null) {
        results[key] = result;
      }
    }
    return results;
  }

  /// Saves a test result for a group.
  Future<void> saveResult(String groupId, int percentage) async {
    final result = TestResult(
      percentage: percentage,
      date: DateTime.now(),
    );
    await _box.put(groupId, result.toMap());
  }
}
