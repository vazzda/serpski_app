import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/vessel_themes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/repositories/daily_activity_repository.dart';
import '../../../shared/ui/card/vessel_card.dart';
import '../../../app/layout/vessel_layout.dart';

class VocabDailyActivityCard extends StatelessWidget {
  const VocabDailyActivityCard({
    super.key,
    required this.asyncStats,
    required this.l10n,
  });

  final AsyncValue<DailyActivityStats> asyncStats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);
    return VesselCard(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.dailyActivityTitle,
              style: VesselFonts.textListItem.copyWith(color: t.textPrimary),
            ),
            const SizedBox(height: VesselLayout.vocabDailyCardTitleGap),
            asyncStats.when(
              data: (stats) {
                final isEmpty =
                    stats.correct == 0 &&
                    stats.wrong == 0 &&
                    stats.wordsTouched == 0;
                return Text(
                  isEmpty
                      ? l10n.dailyActivityEmpty
                      : '${l10n.correctCount(stats.correct)} · ${l10n.wrongCount(stats.wrong)} · ${l10n.wordsCount(stats.wordsTouched)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: VesselFonts.textCaption.copyWith(
                    color: t.textSecondary,
                  ),
                );
              },
              loading: () => Text(
                l10n.dailyActivityEmpty,
                style: VesselFonts.textCaption.copyWith(
                  color: t.textSecondary,
                ),
              ),
              // ignore: unnecessary_underscores
              error: (_, __) => Text(
                l10n.dailyActivityEmpty,
                style: VesselFonts.textCaption.copyWith(
                  color: t.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
