import 'package:flutter/material.dart';

import '../../../app/theme/vessel_themes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/progress_bar/vessel_progress_bar.dart';
import '../../../shared/ui/tile/vessel_tile.dart';
import '../../../app/layout/vessel_layout.dart';
import 'vocab_tile_data.dart';

class VocabGroupTile extends StatelessWidget {
  const VocabGroupTile({
    super.key,
    required this.item,
    required this.l10n,
    required this.width,
    required this.onTap,
  });

  final VocabGroupTileData item;
  final AppLocalizations l10n;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);
    final barValue = item.percentage != null ? item.percentage! / 100.0 : 0.0;

    return SizedBox(
      width: width,
      height: VesselLayout.vocabTileHeight,
      child: VesselTile(
        onTap: item.cardCount > 0 ? onTap : null,
        child: Stack(
          children: [
            // Title
            Positioned(
              top: VesselLayout.vocabTileNameTop,
              left: VesselLayout.vocabTileNameLeft,
              right: VesselLayout.vocabTileNameRight,
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VesselFonts.textTileHeader.copyWith(
                  color: t.tileForeground,
                ),
              ),
            ),
            // Word list
            Positioned(
              top: VesselLayout.vocabTileWordsTop,
              left: VesselLayout.vocabTileWordsLeft,
              right: VesselLayout.vocabTileWordsRight,
              child: Text(
                item.words.join(', '),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: VesselFonts.textTileContent.copyWith(
                  color: t.tileForeground,
                ),
              ),
            ),
            // Progress bar row
            Positioned(
              bottom: VesselLayout.vocabTileProgressBottom,
              left: VesselLayout.vocabTileProgressLeft,
              right: VesselLayout.vocabTileProgressRight,
              child: Row(
                children: [
                  Expanded(
                    child: VesselProgressBar(
                      value: barValue,
                      mode: VesselProgressBarMode.compact,
                    ),
                  ),
                  const SizedBox(width: VesselLayout.vocabTileProgressPercentGap),
                  SizedBox(
                    width: VesselLayout.vocabTileProgressPercentWidth,
                    child: Text(
                      '${item.percentage ?? 0}%',
                      textAlign: TextAlign.end,
                      style: VesselFonts.textTileCounter.copyWith(
                        color: item.percentage != null
                            ? t.tileForeground
                            : t.textPrimaryDimmed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Counter row
            Positioned(
              bottom: VesselLayout.vocabTileCounterBottom,
              left: VesselLayout.vocabTileCounterLeft,
              right: VesselLayout.vocabTileCounterRight,
              child: Text(
                l10n.wordsCount(item.cardCount),
                style: VesselFonts.textTileCounter.copyWith(
                  color: t.tileForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
