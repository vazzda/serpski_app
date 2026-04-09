import 'package:flutter/material.dart';

import '../../../app/theme/vessel_themes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/buttons/vessel_buttons.dart';
import '../../../pages/group_list_screen.dart'
    show retentionColor, retentionLabel, formatRelativeDate;
import '../../../app/layout/vessel_layout.dart';
import 'vocab_deck_tile_data.dart';

class VocabLevelStatsRow extends StatelessWidget {
  const VocabLevelStatsRow({
    super.key,
    required this.item,
    required this.l10n,
  });

  final VocabLevelData item;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);
    final dateText = item.latestDate != null
        ? formatRelativeDate(item.latestDate!, l10n)
        : '-';
    final levelColor = retentionColor(item.strengthLevel, t);
    final levelLabel = retentionLabel(item.strengthLevel, l10n);

    const chipPadding = EdgeInsets.symmetric(
      horizontal: VesselLayout.chipPaddingH,
      vertical: VesselLayout.chipPaddingV,
    );
    final outlineChipStyle = VesselFonts.textProgressChip.copyWith(
      color: t.textPrimary,
    );
    final filledChipStyle = VesselFonts.textProgressChip.copyWith(
      color: t.retentionText,
    );

    return Row(
      children: [
        Container(
          padding: chipPadding,
          decoration: BoxDecoration(
            color: t.cardBackground,
            border: Border.all(color: t.textPrimary, width: t.cardBorderWidth),
            borderRadius: BorderRadius.circular(t.badgeBorderRadius),
          ),
          child: Text(dateText, style: outlineChipStyle),
        ),
        const SizedBox(width: VesselLayout.chipSpacing),
        Container(
          padding: chipPadding,
          decoration: BoxDecoration(
            color: levelColor,
            border: Border.all(color: t.textPrimary, width: t.cardBorderWidth),
            borderRadius: BorderRadius.circular(t.badgeBorderRadius),
          ),
          child: Text(levelLabel, style: filledChipStyle),
        ),
        const Spacer(),
        VesselAccentButton(
          label: l10n.vocab_train,
          onPressed: null,
          size: VesselButtonSize.small,
          margin: EdgeInsets.zero,
        ),
      ],
    );
  }
}
