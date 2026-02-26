import '../../../entities/card/vocab_card.dart';
import '../../../entities/group/vocab_group_model.dart';
import '../../../entities/language/language_pack.dart';
import '../../../entities/language/translation_entry.dart';

/// Generates VocabCards by joining a group's concepts with target + native translations.
class CardGenerationService {
  /// Build a list of VocabCards for a vocabulary group.
  ///
  /// One VocabCard per target translation entry. If a concept has aspect pairs
  /// (e.g., kupovati + kupiti), each gets its own card.
  ///
  /// Skips concepts that are missing from either language pack.
  List<VocabCard> buildCards({
    required VocabGroupModel group,
    required LanguagePack targetPack,
    required LanguagePack nativePack,
  }) {
    final cards = <VocabCard>[];

    for (final conceptId in group.conceptIds) {
      final targetEntries = targetPack.translations[conceptId];
      final nativeEntries = nativePack.translations[conceptId];

      // Skip concepts missing in either pack.
      if (targetEntries == null || nativeEntries == null) continue;
      if (targetEntries.isEmpty || nativeEntries.isEmpty) continue;

      final nativeText = _buildNativeText(nativeEntries);

      for (var i = 0; i < targetEntries.length; i++) {
        final t = targetEntries[i];
        cards.add(VocabCard(
          conceptId: conceptId,
          translationIndex: i,
          targetText: t.text,
          nativeText: _nativeWithAspect(nativeText, t),
          targetNote: t.note,
          nativeNote: nativeEntries.first.note,
          gender: t.gender,
          aspect: t.aspect,
          forms: t.forms,
        ));
      }
    }

    return cards;
  }

  /// Joins all native entries with " / " (e.g., "to buy / to purchase").
  String _buildNativeText(List<TranslationEntry> entries) {
    return entries.map((e) => e.text).join(' / ');
  }

  /// Appends aspect label to native text if the target entry has an aspect.
  String _nativeWithAspect(String baseNative, TranslationEntry target) {
    if (target.aspect == null) return baseNative;
    final label = target.aspect == 'perfective' ? '(pf.)' : '(impf.)';
    return '$baseNative $label';
  }
}
