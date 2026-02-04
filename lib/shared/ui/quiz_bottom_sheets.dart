import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../quiz/quiz_mode.dart';
import 'app_outlined_button.dart';

/// Shows mode selection bottom sheet.
/// [showAllModes] - if true, shows all 3 modes; if false, shows only WRITING.
/// Returns [QuizMode] or null if dismissed.
Future<QuizMode?> showModeBottomSheet(
  BuildContext context,
  AppLocalizations l10n, {
  bool showAllModes = true,
}) {
  final theme = Theme.of(context);
  return showModalBottomSheet<QuizMode>(
    context: context,
    backgroundColor: theme.colorScheme.surface,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                l10n.chooseMode,
                style: theme.textTheme.titleLarge,
              ),
            ),
            // Mode buttons
            if (showAllModes) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppOutlinedButton(
                  label: l10n.modeEngCards,
                  onPressed: () => Navigator.of(context).pop(QuizMode.serbianShown),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppOutlinedButton(
                  label: l10n.modeSrpskiCards,
                  onPressed: () => Navigator.of(context).pop(QuizMode.englishShown),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AppOutlinedButton(
                label: l10n.modeWriting,
                onPressed: () => Navigator.of(context).pop(QuizMode.write),
              ),
            ),
            // Cancel
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Shows question count selection bottom sheet.
/// [totalCount] - total cards available in the group.
/// Returns selected count or null if dismissed.
/// 
/// Options shown based on totalCount:
/// - totalCount > 10: "5", "10", "ALL (N)"
/// - totalCount > 5: "5", "ALL (N)"
/// - totalCount <= 5: returns totalCount immediately (no sheet shown)
/// - totalCount <= 0: returns null (invalid)
Future<int?> showCountBottomSheet(
  BuildContext context,
  AppLocalizations l10n, {
  required int totalCount,
}) async {
  // No cards available
  if (totalCount <= 0) return null;

  // 5 or fewer cards - skip selection, use all
  if (totalCount <= 5) return totalCount;

  // Build options based on total
  final counts = <int>[];
  final labels = <String>[];

  // Always show 5
  counts.add(5);
  labels.add(l10n.questions5);

  // Show 10 if we have more than 10
  if (totalCount > 10) {
    counts.add(10);
    labels.add(l10n.questions10);
  }

  // Always show ALL
  counts.add(totalCount);
  labels.add(l10n.questionsAll(totalCount));

  final theme = Theme.of(context);
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: theme.colorScheme.surface,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                l10n.chooseQuestionsCount,
                style: theme.textTheme.titleLarge,
              ),
            ),
            ...List.generate(counts.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppOutlinedButton(
                  label: labels[i],
                  onPressed: () => Navigator.of(context).pop(counts[i]),
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
