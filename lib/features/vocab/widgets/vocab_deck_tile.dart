import 'package:flutter/material.dart';

import '../../../app/theme/vessel_themes.dart';
import 'package:srpski_card/shared/lib/deck_icons.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/progress_bar/vessel_progress_bar.dart';
import '../../../shared/ui/tile/vessel_tile.dart';
import '../../../app/layout/vessel_layout.dart';
import 'vocab_deck_tile_data.dart';

class VocabDeckTile extends StatelessWidget {
  const VocabDeckTile({
    super.key,
    required this.item,
    required this.l10n,
    required this.width,
    required this.onTap,
  });

  final VocabDeckTileData item;
  final AppLocalizations l10n;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);
    final barValue = item.percentage != null ? item.percentage! / 100.0 : 0.0;
    final iconData = item.icon != null
        ? DeckIcons.fromString(item.icon!)
        : DeckIcons.fallback;

    return SizedBox(
      width: width,
      height: VesselLayout.vocabTileHeight,
      child: VesselTile(
        onTap: item.cardCount > 0 ? onTap : null,
        child: Stack(
          children: [
            // Header: icon (left) + stats column (right)
            Positioned(
              top: VesselLayout.vocabTileHeaderTop,
              left: VesselLayout.vocabTileHeaderLeft,
              right: VesselLayout.vocabTileHeaderRight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: const Offset(0, VesselLayout.deckIconTopOffset),
                    child: Container(
                      padding: const EdgeInsets.all(VesselLayout.deckIconPadding),
                      decoration: BoxDecoration(
                        color: t.deckIconBackground,
                        borderRadius: BorderRadius.circular(
                          t.deckIconBorderRadius,
                        ),
                      ),
                      child: Icon(
                        iconData,
                        size: VesselLayout.vocabTileIconSize,
                        color: t.deckIconColor,
                      ),
                    ),
                  ),
                  SizedBox(width: VesselLayout.vocabTileHeaderGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.vocab_conceptsCount(item.cardCount),
                          textAlign: TextAlign.start,
                          style: VesselFonts.textTileCounter.copyWith(
                            color: t.tileForeground,
                          ),
                        ),
                        SizedBox(height: VesselLayout.vocabTileHeaderRowGap),
                        Row(
                          children: [
                            Expanded(
                              child: VesselProgressBar(
                                value: barValue,
                                mode: VesselProgressBarMode.compact,
                              ),
                            ),
                            const SizedBox(
                              width: VesselLayout.vocabTileProgressPercentGap,
                            ),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: VesselFonts.textTileContent.copyWith(
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
