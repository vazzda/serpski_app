import 'package:flutter/material.dart';

import '../../../app/theme/app_themes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/buttons/project_buttons.dart';
import '../../../pages/group_list_screen.dart'
    show retentionColor, retentionLabel, formatRelativeDate;
import 'vocab_layout.dart';
import 'vocab_tile_data.dart';

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
    final t = AppThemes.of(context);
    final dateText = item.latestDate != null
        ? formatRelativeDate(item.latestDate!, l10n)
        : '-';
    final levelColor = retentionColor(item.strengthLevel, t);
    final levelLabel = retentionLabel(item.strengthLevel, l10n);

    const chipPadding = EdgeInsets.symmetric(
      horizontal: VocabLayout.chipPaddingH,
      vertical: VocabLayout.chipPaddingV,
    );
    final outlineChipStyle = AppFontStyles.textProgressChip.copyWith(
      color: t.textPrimary,
    );
    final filledChipStyle = AppFontStyles.textProgressChip.copyWith(
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
        const SizedBox(width: VocabLayout.chipSpacing),
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
        AccentButton(
          label: l10n.vocab_train,
          onPressed: null,
          size: ButtonSize.small,
          margin: EdgeInsets.zero,
        ),
      ],
    );
  }
}
