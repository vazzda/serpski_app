import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../l10n/app_localizations.dart';
import '../../../app/layout/vessel_layout.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/vessel_themes.dart';
import 'vessel_navbar_icon.dart';

/// Flat bottom navigation bar with 4 tabs.
/// Active tab is detected from the current route.
class VesselNavBar extends StatelessWidget {
  const VesselNavBar({super.key, this.onSettingsDisabledTap});

  final VoidCallback? onSettingsDisabledTap;

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentPath = GoRouterState.of(context).uri.path;

    final isLanguage = currentPath == AppRoutes.language;
    final isVocabulary = currentPath == AppRoutes.home;
    final isTools = currentPath == AppRoutes.tools ||
        currentPath == AppRoutes.conjugations ||
        currentPath == AppRoutes.agreement;
    final isSettings = currentPath == AppRoutes.settings;

    return Container(
      decoration: BoxDecoration(
        color: t.navbarBackground,
        border: Border(
          top: BorderSide(
            color: t.navbarBorderColor,
            width: t.navbarBorderWidth,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: VesselLayout.navbarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              VesselNavBarIcon(
                icon: PhosphorIconsRegular.globe,
                activeIcon: PhosphorIconsFill.globe,
                tooltip: l10n.navLanguage,
                isEnabled: !isLanguage,
                enabledColor: t.navbarIconColor,
                disabledColor: t.navbarDisabledIconColor,
                onPressed: !isLanguage
                    ? () => context.go(AppRoutes.language)
                    : null,
              ),
              VesselNavBarIcon(
                icon: PhosphorIconsRegular.books,
                activeIcon: PhosphorIconsFill.books,
                tooltip: l10n.navVocabulary,
                isEnabled: !isVocabulary,
                enabledColor: t.navbarIconColor,
                disabledColor: t.navbarDisabledIconColor,
                onPressed: !isVocabulary
                    ? () => context.go(AppRoutes.home)
                    : null,
              ),
              VesselNavBarIcon(
                icon: PhosphorIconsRegular.puzzlePiece,
                activeIcon: PhosphorIconsFill.puzzlePiece,
                tooltip: l10n.navTools,
                isEnabled: !isTools,
                enabledColor: t.navbarIconColor,
                disabledColor: t.navbarDisabledIconColor,
                onPressed: !isTools
                    ? () => context.go(AppRoutes.tools)
                    : null,
              ),
              VesselNavBarIcon(
                icon: PhosphorIconsRegular.gearSix,
                activeIcon: PhosphorIconsFill.gearSix,
                tooltip: l10n.navSettings,
                isEnabled: !isSettings,
                enabledColor: t.navbarIconColor,
                disabledColor: t.navbarDisabledIconColor,
                onPressed: !isSettings
                    ? () => context.go(AppRoutes.settings)
                    : null,
                onDisabledTap: isSettings ? onSettingsDisabledTap : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
