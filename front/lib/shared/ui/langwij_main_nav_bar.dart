import 'package:flessel/flessel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langwij/shared/lib/constants.dart';

import '../../app/router/app_router.dart';
import '../../l10n/app_localizations.dart';

/// Langwij's main navigation — items + current-index helpers for
/// [FlesselScaffold]. Maps the four primary tabs (Language, Vocabulary,
/// Tools, Settings) to router paths and absorbs the dev-access secret-tap
/// mechanic on Settings.
class LangwijMainNavBar {
  const LangwijMainNavBar._();

  static List<FlesselNavBarItem> items(
    BuildContext context, {
    VoidCallback? onDevAccessTapsReached,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return [
      FlesselNavBarItem(
        icon: PhosphorIconsRegular.globe,
        activeIcon: PhosphorIconsFill.globe,
        tooltip: l10n.navLanguage,
        onTap: () => context.go(AppRoutes.language),
      ),
      FlesselNavBarItem(
        icon: PhosphorIconsRegular.books,
        activeIcon: PhosphorIconsFill.books,
        tooltip: l10n.navVocabulary,
        onTap: () => context.go(AppRoutes.home),
      ),
      FlesselNavBarItem(
        icon: PhosphorIconsRegular.puzzlePiece,
        activeIcon: PhosphorIconsFill.puzzlePiece,
        tooltip: l10n.navTools,
        onTap: () => context.go(AppRoutes.tools),
      ),
      FlesselNavBarItem(
        icon: PhosphorIconsRegular.gearSix,
        activeIcon: PhosphorIconsFill.gearSix,
        tooltip: l10n.navSettings,
        onTap: () => context.go(AppRoutes.settings),
        secretTapCount: AppConstants.devAccessTapCount,
        onSecretTapsReached: onDevAccessTapsReached,
      ),
    ];
  }

  static int currentIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path == AppRoutes.language) return 0;
    if (path == AppRoutes.home) return 1;
    if (path == AppRoutes.tools ||
        path == AppRoutes.conjugations ||
        path == AppRoutes.agreement) {
      return 2;
    }
    if (path == AppRoutes.settings) return 3;
    return -1;
  }
}
