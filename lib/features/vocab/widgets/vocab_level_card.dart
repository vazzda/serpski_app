import 'package:flutter/material.dart';

import '../../../app/theme/app_themes.dart';
import '../../../entities/group/vocab_group_model.dart';
import '../../../entities/plan/level_tier.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/card/project_card.dart';
import '../../../shared/ui/progress_bar/project_progress_bar.dart';
import 'vocab_group_tile.dart';
import 'vocab_layout.dart';
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
      padding: const EdgeInsets.all(VocabLayout.levelCardPadding),
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
                const SizedBox(height: VocabLayout.headerToProgressGap),
                Row(
                  children: [
                    SizedBox(
                      width: VocabLayout.progressWordsWidth,
                      child: Text(
                        '${item.totalCardCount}',
                        textAlign: TextAlign.start,
                        style: AppFontStyles.textLevelCounter.copyWith(
                          color: t.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: VocabLayout.progressPercentGap),
                    Expanded(
                      child: ProjectProgressBar(
                        value: (item.levelProgress / 100.0).clamp(0.0, 1.0),
                        mode: ProgressBarMode.detailed,
                      ),
                    ),
                    const SizedBox(width: VocabLayout.progressPercentGap),
                    SizedBox(
                      width: VocabLayout.progressPercentWidth,
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
            const SizedBox(height: VocabLayout.progressSpacingAfter),
            if (item.description != null) ...[
              Text(
                item.description!,
                style: AppFontStyles.textCaption.copyWith(color: t.textSecondary),
              ),
              const SizedBox(height: VocabLayout.descSpacingAfter),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final t = AppThemes.of(context);
                final n =
                    ((constraints.maxWidth + t.tileGap) /
                            (t.tileMinWidth + t.tileGap))
                        .floor()
                        .clamp(1, 100);
                final tileWidth =
                    (constraints.maxWidth - t.tileGap * (n - 1)) / n;
                return Wrap(
                  spacing: t.tileGap,
                  runSpacing: t.tileGap,
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
            const SizedBox(height: VocabLayout.tilesToStatsGap),
            VocabLevelStatsRow(item: item, l10n: l10n),
          ],
        ],
      ),
    );
  }
}
