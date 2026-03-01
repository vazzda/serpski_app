import 'package:flutter/material.dart';

import '../../../app/theme/app_themes.dart';
import '../../../entities/group/vocab_group_model.dart';
import '../../../entities/plan/level_tier.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/card/project_card.dart';
import '../../../shared/ui/progress_bar/project_progress_bar.dart';
import 'vocab_group_tile.dart';
import '../../../app/layout/app_layout.dart';
import 'vocab_level_stats_row.dart';
import 'vocab_tile_data.dart';

class VocabLevelCard extends StatelessWidget {
  const VocabLevelCard({
    super.key,
    required this.item,
    required this.l10n,
    required this.isExpanded,
    required this.onToggle,
    required this.onGroupTap,
  });

  final VocabLevelData item;
  final AppLocalizations l10n;
  final bool isExpanded;
  final VoidCallback onToggle;
  final void Function(VocabGroupModel group, int cardCount) onGroupTap;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    final isPremium = item.tier == LevelTier.premium;

    return ProjectCard(
      padding: const EdgeInsets.all(AppLayout.vocabLevelCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tappable header: name row + progress bar row
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppFontStyles.textLevelHeader.copyWith(
                          color: t.textPrimary,
                        ),
                      ),
                    ),
                    if (isPremium)
                      Icon(Icons.lock_outline, size: 16, color: t.textSecondary),
                  ],
                ),
                const SizedBox(height: AppLayout.vocabHeaderToProgressGap),
                Row(
                  children: [
                    SizedBox(
                      width: AppLayout.vocabProgressWordsWidth,
                      child: Text(
                        '${item.totalCardCount}',
                        textAlign: TextAlign.start,
                        style: AppFontStyles.textLevelCounter.copyWith(
                          color: t.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppLayout.vocabProgressPercentGap),
                    Expanded(
                      child: ProjectProgressBar(
                        value: (item.levelProgress / 100.0).clamp(0.0, 1.0),
                        mode: ProgressBarMode.detailed,
                      ),
                    ),
                    const SizedBox(width: AppLayout.vocabProgressPercentGap),
                    SizedBox(
                      width: AppLayout.vocabProgressPercentWidth,
                      child: Text(
                        '${item.levelProgress.round()}%',
                        textAlign: TextAlign.end,
                        style: AppFontStyles.textLevelCounter.copyWith(
                          color: t.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Body: visible only when expanded
          if (isExpanded) ...[
            const SizedBox(height: AppLayout.vocabProgressSpacingAfter),
            if (item.description != null) ...[
              Text(
                item.description!,
                style: AppFontStyles.textCaption.copyWith(color: t.textSecondary),
              ),
              const SizedBox(height: AppLayout.vocabDescSpacingAfter),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final n =
                    ((constraints.maxWidth + AppLayout.vocabTileGap) /
                            (AppLayout.vocabTileMinWidth + AppLayout.vocabTileGap))
                        .floor()
                        .clamp(1, 100);
                final tileWidth =
                    (constraints.maxWidth - AppLayout.vocabTileGap * (n - 1)) / n;
                return Wrap(
                  spacing: AppLayout.vocabTileGap,
                  runSpacing: AppLayout.vocabTileGap,
                  children: item.groups
                      .map(
                        (g) => VocabGroupTile(
                          item: g,
                          l10n: l10n,
                          width: tileWidth,
                          onTap: () => onGroupTap(g.group, g.cardCount),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: AppLayout.vocabTilesToStatsGap),
            VocabLevelStatsRow(item: item, l10n: l10n),
          ],
        ],
      ),
    );
  }
}
