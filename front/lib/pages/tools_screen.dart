import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/app_localizations.dart';
import '../app/providers/language_settings_provider.dart';
import '../entities/language/lang_codes.dart';
import '../app/router/app_router.dart';
import '../app/theme/vessel_themes.dart';
import '../shared/ui/card/vessel_card.dart';
import '../shared/ui/screen_layout/vessel_scaffold.dart';
import '../app/layout/vessel_layout.dart';

/// Tools screen — language-specific practice tools.
/// For Serbian: conjugation endings and gender agreement drills.
class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = VesselThemes.of(context);
    final langSettings = ref.watch(languageSettingsProvider);

    // Tools available per target language.
    final tools = _toolsForLanguage(langSettings.targetLang);

    return VesselScaffold(
      title: l10n.navTools,
      showBottomNav: true,
      child: tools.isEmpty
          ? Center(
              child: Text(
                l10n.tools_emptyState,
                style: VesselFonts.textBody.copyWith(color: t.textSecondary),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(VesselLayout.screenPadding),
              children: tools.map((tool) {
                final label = _toolLabel(tool, l10n);
                return Padding(
                  padding: const EdgeInsets.only(bottom: VesselLayout.listItemGap),
                  child: VesselCard(
                    onTap: () => _onToolTap(context, tool),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: VesselFonts.textListItem.copyWith(color: t.textPrimary),
                          ),
                        ),
                        Icon(
                          PhosphorIconsRegular.caretRight,
                          size: 16,
                          color: t.textPrimary,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  void _onToolTap(BuildContext context, _Tool tool) {
    switch (tool) {
      case _Tool.conjugations:
        context.go(AppRoutes.conjugations);
      case _Tool.agreement:
        context.go(AppRoutes.agreement);
    }
  }
}

enum _Tool { conjugations, agreement }

List<_Tool> _toolsForLanguage(String targetLang) {
  switch (targetLang) {
    case LangCodes.serbian:
      return [_Tool.conjugations, _Tool.agreement];
    default:
      return [];
  }
}

String _toolLabel(_Tool tool, AppLocalizations l10n) {
  switch (tool) {
    case _Tool.conjugations:
      return l10n.tools_conjugations;
    case _Tool.agreement:
      return l10n.tools_agreement;
  }
}
