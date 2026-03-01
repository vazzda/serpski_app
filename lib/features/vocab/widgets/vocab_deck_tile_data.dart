import '../../../entities/deck/vocab_deck_model.dart';
import '../../../entities/level/level.dart';
import '../../../entities/plan/level_tier.dart';
import '../../../shared/repositories/models/deck_progress.dart';
import '../../../shared/repositories/models/retention_level.dart';

class VocabDeckTileData {
  VocabDeckTileData({
    required this.deck,
    required this.name,
    required this.cardCount,
    required this.retention,
    required this.words,
    this.icon,
    this.percentage,
    this.progress,
  });

  final VocabDeckModel deck;
  final String name;
  final String? icon;
  final int cardCount;
  final List<String> words;
  final int? percentage; // null = no sessions yet
  final DeckProgress? progress;
  final double retention;
}

class VocabLevelData {
  VocabLevelData({
    required this.level,
    required this.name,
    required this.tier,
    required this.levelProgress,
    required this.decks,
    required this.strengthLevel,
    required this.totalCardCount,
    this.description,
    this.latestDate,
  });

  final Level level;
  final String name;
  final String? description;
  final LevelTier tier;
  final double levelProgress; // 0–100
  final List<VocabDeckTileData> decks;
  final DateTime? latestDate;
  final RetentionLevel strengthLevel;
  final int totalCardCount;
}
