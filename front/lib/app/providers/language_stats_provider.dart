import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/repositories/language_stats_repository.dart';

/// Provider for the language stats repository. Must be overridden in main.dart.
final languageStatsRepositoryProvider = Provider<LanguageStatsRepository>((ref) {
  throw UnimplementedError('languageStatsRepositoryProvider must be overridden');
});
