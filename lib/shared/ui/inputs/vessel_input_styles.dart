import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/vessel_themes.dart';

class VesselInputStyles {
  static OutlineInputBorder _border(BuildContext context) {
    final theme = VesselThemes.of(context);
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(theme.controlBorderRadius),
      borderSide: BorderSide(
        color: theme.controlBorder,
        width: theme.controlBorderWidth,
      ),
    );
  }

  static InputDecoration decoration({
    required BuildContext context,
    String? label,
    String? hint,
  }) {
    final theme = VesselThemes.of(context);
    final border = _border(context);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: VesselFonts.textControlInput.copyWith(
        color: theme.controlForeground,
      ),
      hintStyle: VesselFonts.textControlHint.copyWith(color: theme.textSecondary),
      filled: true,
      fillColor: theme.controlBackground,
      isDense: true,
      enabledBorder: border,
      focusedBorder: border,
      border: border,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  static TextStyle textStyle(BuildContext context) {
    final theme = VesselThemes.of(context);
    return VesselFonts.textControlInput.copyWith(color: theme.controlForeground);
  }
}
