import 'package:flutter/material.dart';

import '../../../app/theme/app_themes.dart';
import '../../../l10n/app_localizations.dart';
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppFontStyles.textTileContent.copyWith(
                  color: t.tileForeground,
                ),
              ),
            ),
            // Counter row: word count (left) + completion % (right)
            Positioned(
              bottom: VocabLayout.tileCounterBottom,
              left: VocabLayout.tileCounterLeft,
              right: VocabLayout.tileCounterRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.wordsCount(item.cardCount),
                    style: AppFontStyles.textTileCounter.copyWith(
                      color: t.tileForeground,
                    ),
                  ),
                  if (item.percentage != null)
                    Text(
                      '${item.percentage}%',
                      style: AppFontStyles.textTileCounter.copyWith(
                        color: t.tileForeground,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
