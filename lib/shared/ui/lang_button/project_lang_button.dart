import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/theme_provider.dart';
import '../../../app/theme/app_themes.dart';
import '../../../entities/language/lang_codes.dart';
import '../buttons/project_button_styles.dart';

const _kFlagWidth = 32.0;
const _kFlagHeight = 22.0;
const _kFlagBorderRadius = 4.0;

class ProjectLangButton extends ConsumerWidget {
  const ProjectLangButton({
    super.key,
    required this.langCode,
    required this.label,
    this.onPressed,
  });

  final String langCode;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final colors = ProjectButtonStyleResolver.resolveColors(
      context,
      theme: theme,
      variant: ButtonVariant.base,
    );
    final themeData = AppThemes.getThemeData(theme);
    final countryCode = LangCodes.flagCountryCode(langCode);

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (countryCode != null) ...[
          CountryFlag.fromCountryCode(
            countryCode,
            theme: const ImageTheme(
              width: _kFlagWidth,
              height: _kFlagHeight,
              shape: RoundedRectangle(_kFlagBorderRadius),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Text(label.toUpperCase()),
      ],
    );

    final button = OutlinedButton(
      onPressed: onPressed,
      style: ProjectButtonStyleResolver.style(
        context: context,
        colors: colors,
        iconOnly: false,
        hasIconAndText: countryCode != null,
        size: ButtonSize.medium,
        variant: ButtonVariant.base,
      ),
      child: child,
    );

    if (themeData.componentShadow != null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(themeData.buttonBorderRadius),
          boxShadow: themeData.componentShadow,
        ),
        child: button,
      );
    }

    return button;
  }
}
