import '../../entities/card/card_model.dart';
import '../../l10n/app_localizations.dart';

/// Returns the verb part of [text] by stripping a leading "you " (case insensitive).
String _verbPart(String text) {
  final t = text.trim();
  if (t.length >= 4 && t.substring(0, 4).toLowerCase() == 'you ') {
    return t.substring(4).trim();
  }
  return t;
}

/// Display string for the native side of a card. Ti → "you (informal, singular) …", Vi → "you (formal, plural) …".
String displayNativeForCard(CardModel card, AppLocalizations l10n) {
  if (card is! EndingCard) return card.nativeText;
  final p = card.pronoun.toLowerCase();
  if (p == 'ti') return '${l10n.pronounYouInformal} ${_verbPart(card.nativeText)}';
  if (p == 'vi') return '${l10n.pronounYouFormal} ${_verbPart(card.nativeText)}';
  return card.nativeText;
}
