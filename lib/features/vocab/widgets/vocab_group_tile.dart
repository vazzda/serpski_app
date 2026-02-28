import 'package:flutter/material.dart';

import '../../../app/theme/app_themes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/progress_bar/project_progress_bar.dart';
import '../../../shared/ui/tile/project_tile.dart';
import 'vocab_layout.dart';
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
    final t = AppThemes.of(context);
    final barValue = item.percentage != null ? item.percentage! / 100.0 : 0.0;

    return SizedBox(
      width: width,
      height: t.tileHeight,
      child: ProjectTile(
        onTap: item.cardCount > 0 ? onTap : null,
        child: Stack(
          children: [
            // Title
            Positioned(
              top: VocabLayout.tileNameTop,
              left: VocabLayout.tileNameLeft,
              right: VocabLayout.tileNameRight,
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFontStyles.textTileHeader.copyWith(
                  color: t.tileForeground,
                ),
              ),
            ),
            // Word list
            Positioned(
              top: VocabLayout.tileWordsTop,
              left: VocabLayout.tileWordsLeft,
              right: VocabLayout.tileWordsRight,
              child: Text(
                item.words.join(', '),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppFontStyles.textTileContent.copyWith(
                  color: t.tileForeground,
                ),
              ),
            ),
            // Progress bar row
            Positioned(
              bottom: VocabLayout.tileProgressBottom,
              left: VocabLayout.tileProgressLeft,
              right: VocabLayout.tileProgressRight,
              child: Row(
                children: [
                  Expanded(
                    child: ProjectProgressBar(
                      value: barValue,
                      mode: ProgressBarMode.compact,
                    ),
                  ),
                  const SizedBox(width: VocabLayout.tileProgressPercentGap),
                  SizedBox(
                    width: VocabLayout.tileProgressPercentWidth,
                    child: Text(
                      '${item.percentage ?? 0}%',
                      textAlign: TextAlign.end,
                      style: AppFontStyles.textTileCounter.copyWith(
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
              bottom: VocabLayout.tileCounterBottom,
              left: VocabLayout.tileCounterLeft,
              right: VocabLayout.tileCounterRight,
              child: Text(
                l10n.wordsCount(item.cardCount),
                style: AppFontStyles.textTileCounter.copyWith(
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
