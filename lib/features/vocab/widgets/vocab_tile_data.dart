import '../../../entities/group/vocab_group_model.dart';
import '../../../entities/level/level.dart';
import '../../../entities/plan/level_tier.dart';
import '../../../shared/repositories/models/group_progress.dart';
import '../../../shared/repositories/models/retention_level.dart';

class VocabGroupTileData {
  VocabGroupTileData({
    required this.group,
    required this.name,
    required this.cardCount,
    required this.retention,
    required this.words,
    this.icon,
    this.percentage,
    this.progress,
  });

  final VocabGroupModel group;
  final String name;
  final String? icon;
  final int cardCount;
  final List<String> words;
  final int? percentage; // null = no sessions yet
  final GroupProgress? progress;
  final double retention;
}

class VocabLevelData {
  VocabLevelData({
    required this.level,
    required this.name,
    required this.tier,
    required this.levelProgress,
    required this.groups,
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
  final List<VocabGroupTileData> groups;
  final DateTime? latestDate;
  final RetentionLevel strengthLevel;
  final int totalCardCount;
}
