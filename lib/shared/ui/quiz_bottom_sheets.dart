import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../quiz/quiz_mode.dart';

/// Shows mode selection bottom sheet. Returns selected [QuizMode] or null if dismissed.
Future<QuizMode?> showModeBottomSheet(
  BuildContext context,
  AppLocalizations l10n,
) {
  final theme = Theme.of(context);
  final noBorderListTileTheme = ListTileThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
  return showModalBottomSheet<QuizMode>(
    context: context,
    backgroundColor: theme.colorScheme.surface,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Theme(
          data: theme.copyWith(listTileTheme: noBorderListTileTheme),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  l10n.chooseMode,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              ListTile(
                title: Text(l10n.modeSerbianShown),
                onTap: () => Navigator.of(context).pop(QuizMode.serbianShown),
              ),
              ListTile(
                title: Text(l10n.modeEnglishShown),
                onTap: () => Navigator.of(context).pop(QuizMode.englishShown),
              ),
              ListTile(
                title: Text(l10n.modeWrite),
                onTap: () => Navigator.of(context).pop(QuizMode.write),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Shows question count selection bottom sheet. Returns selected count (5, 10, 20, 50) or null if dismissed.
Future<int?> showCountBottomSheet(
  BuildContext context,
  AppLocalizations l10n,
) {
  final theme = Theme.of(context);
  final noBorderListTileTheme = ListTileThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
  final counts = [5, 10, 20, 50];
  final labels = [
    l10n.questions5,
    l10n.questions10,
    l10n.questions20,
    l10n.questions50,
  ];
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: theme.colorScheme.surface,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Theme(
          data: theme.copyWith(listTileTheme: noBorderListTileTheme),
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
              ...List.generate(4, (i) {
                return ListTile(
                  title: Text(labels[i]),
                  onTap: () => Navigator.of(context).pop(counts[i]),
                );
              }),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
