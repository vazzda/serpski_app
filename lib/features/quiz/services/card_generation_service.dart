import '../../../entities/card/vocab_card.dart';
import '../../../entities/deck/vocab_deck_model.dart';
import '../../../entities/language/lang_entry.dart';
import '../../../entities/language/language_pack.dart';

/// Generates VocabCards by joining a deck's terms with target + native translations.
class CardGenerationService {
  /// Build a list of VocabCards for a vocabulary deck.
  ///
  /// One VocabCard per term. Entry type determines card subtype:
  ///   [AspectPairEntry] → [PairVocabCard] (two-input write quiz)
  ///   [SimpleEntry] / [AdjectiveEntry] → [SimpleVocabCard]
  ///
  /// Skips terms missing from either pack.
  List<VocabCard> buildCards({
    required VocabDeckModel deck,
    required LanguagePack targetPack,
    required LanguagePack nativePack,
  }) {
    final cards = <VocabCard>[];

    for (final termId in deck.termIds) {
      final targetEntry = targetPack.translations[termId];
      final nativeEntry = nativePack.translations[termId];
      if (targetEntry == null || nativeEntry == null) continue;

      final nativeText = _nativeText(nativeEntry);
      final nativeNote = nativeEntry.note;

      switch (targetEntry) {
        case AspectPairEntry(
            :final imperfective,
            :final perfective,
            :final note,
          ):
          cards.add(PairVocabCard(
            termId: termId,
            nativeText: nativeText,
            imperfectiveText: imperfective,
            perfectiveText: perfective,
            nativeNote: nativeNote,
            targetNote: note,
          ));

        case SimpleEntry(:final text, :final note):
          cards.add(SimpleVocabCard(
            termId: termId,
            nativeText: nativeText,
            targetText: text,
            nativeNote: nativeNote,
            targetNote: note,
          ));

        case AdjectiveEntry(:final m, :final note):
          cards.add(SimpleVocabCard(
            termId: termId,
            nativeText: nativeText,
            targetText: m,
            nativeNote: nativeNote,
            targetNote: note,
          ));
      }
    }

    return cards;
  }

  /// Returns the primary display text for the native side of a card.
  String _nativeText(LangEntry entry) => switch (entry) {
        SimpleEntry(:final text) => text,
        AspectPairEntry(:final imperfective, :final perfective) =>
          '$imperfective / $perfective',
        AdjectiveEntry(:final m) => m,
      };
}
