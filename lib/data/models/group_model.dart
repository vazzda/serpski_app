import 'card_model.dart';

/// A group of cards (words or endings). labelKey is the l10n key for display.
class GroupModel {
  const GroupModel({
    required this.id,
    required this.labelKey,
    required this.type,
    required this.cards,
  });

  final String id;
  final String labelKey;
  final GroupType type;
  final List<CardModel> cards;

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final type = GroupType.values.byName(json['type'] as String);
    final cardsJson = json['cards'] as List<dynamic>;
    final cards = switch (type) {
      GroupType.words => cardsJson
          .map((e) => WordCard.fromJson(e as Map<String, dynamic>))
          .toList(),
      GroupType.endings => cardsJson
          .map((e) => EndingCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    };
    return GroupModel(
      id: json['id'] as String,
      labelKey: json['labelKey'] as String,
      type: type,
      cards: cards,
    );
  }
}

enum GroupType { words, endings }
