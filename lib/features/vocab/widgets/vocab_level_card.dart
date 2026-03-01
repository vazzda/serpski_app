import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../app/theme/vessel_themes.dart';
import '../../../entities/deck/vocab_deck_model.dart';
import '../../../entities/plan/level_tier.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/card/vessel_card.dart';
import '../../../shared/ui/progress_bar/vessel_progress_bar.dart';
import 'vocab_deck_tile.dart';
import '../../../app/layout/vessel_layout.dart';
import 'vocab_level_stats_row.dart';
import 'vocab_deck_tile_data.dart';

class VocabLevelCard extends StatelessWidget {
  const VocabLevelCard({
    super.key,
    required this.item,
    required this.l10n,
    required this.isExpanded,
    required this.onToggle,
    required this.onDeckTap,
  });

  final VocabLevelData item;
  final AppLocalizations l10n;
  final bool isExpanded;
  final VoidCallback onToggle;
  final void Function(VocabDeckModel deck, int cardCount) onDeckTap;

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);
    final isPremium = item.tier == LevelTier.premium;

    return VesselCard(
      padding: const EdgeInsets.all(VesselLayout.vocabLevelCardPadding),
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
                        style: VesselFonts.textLevelHeader.copyWith(
                          color: t.textPrimary,
                        ),
                      ),
                    ),
                    if (isPremium)
                      Icon(PhosphorIconsRegular.lock, size: 16, color: t.textSecondary),
                  ],
                ),
                const SizedBox(height: VesselLayout.vocabHeaderToProgressGap),
                Row(
                  children: [
                    SizedBox(
                      width: VesselLayout.vocabProgressWordsWidth,
                      child: Text(
                        '${item.totalCardCount}',
                        textAlign: TextAlign.start,
                        style: VesselFonts.textLevelCounter.copyWith(
                          color: t.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: VesselLayout.vocabProgressPercentGap),
                    Expanded(
                      child: VesselProgressBar(
                        value: (item.levelProgress / 100.0).clamp(0.0, 1.0),
                        mode: VesselProgressBarMode.detailed,
                      ),
                    ),
                    const SizedBox(width: VesselLayout.vocabProgressPercentGap),
                    SizedBox(
                      width: VesselLayout.vocabProgressPercentWidth,
                      child: Text(
                        '${item.levelProgress.round()}%',
                        textAlign: TextAlign.end,
                        style: VesselFonts.textLevelCounter.copyWith(
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
            const SizedBox(height: VesselLayout.vocabProgressSpacingAfter),
            if (item.description != null) ...[
              Text(
                item.description!,
                style: VesselFonts.textCaption.copyWith(color: t.textSecondary),
              ),
              const SizedBox(height: VesselLayout.vocabDescSpacingAfter),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final n =
                    ((constraints.maxWidth + VesselLayout.vocabTileGap) /
                            (VesselLayout.vocabTileMinWidth + VesselLayout.vocabTileGap))
                        .floor()
                        .clamp(1, 100);
                final tileWidth =
                    (constraints.maxWidth - VesselLayout.vocabTileGap * (n - 1)) / n;
                return Wrap(
                  spacing: VesselLayout.vocabTileGap,
                  runSpacing: VesselLayout.vocabTileGap,
                  children: item.decks
                      .map(
                        (g) => VocabDeckTile(
                          item: g,
                          l10n: l10n,
                          width: tileWidth,
                          onTap: () => onDeckTap(g.deck, g.cardCount),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: VesselLayout.vocabTilesToStatsGap),
            VocabLevelStatsRow(item: item, l10n: l10n),
          ],
        ],
      ),
    );
  }
}
