import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entities/language/dictionary.dart';
import '../../entities/language/language_pack.dart';
import '../../shared/repositories/dictionary_repository.dart';
import 'language_settings_provider.dart';

/// Singleton DictionaryRepository provider.
final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) {
  return DictionaryRepository();
});

/// Universal dictionary (concepts + groups). Loaded once from assets.
final dictionaryProvider = FutureProvider<Dictionary>((ref) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  return repo.loadDictionary();
});

/// Target language pack. Reloads when target language changes.
final targetPackProvider = FutureProvider<LanguagePack>((ref) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  final settings = ref.watch(languageSettingsProvider);
  return repo.loadLanguagePack(settings.targetLang);
});

/// Native language pack. Reloads when native language changes.
final nativePackProvider = FutureProvider<LanguagePack>((ref) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  final settings = ref.watch(languageSettingsProvider);
  return repo.loadLanguagePack(settings.nativeLang);
});

/// All available language packs (for language selection screen).
final allPacksProvider = FutureProvider<List<LanguagePack>>((ref) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  return repo.loadAllPacks();
});
