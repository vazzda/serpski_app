import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/vessel_themes.dart';

/// Informational note widget with themed background, border, and text.
class VesselNote extends StatelessWidget {
  final String text;
  final bool accented;

  const VesselNote({super.key, required this.text, this.accented = false});

  @override
  Widget build(BuildContext context) {
    final theme = VesselThemes.of(context);

    final bg = accented ? theme.noteAccentBackground : theme.noteBackground;
    final border = accented ? theme.noteAccentBorderColor : theme.noteBorderColor;
    final textColor = accented ? theme.noteAccentTextColor : theme.noteTextColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(theme.noteBorderRadius),
        border: Border.all(
          color: border,
          width: theme.noteBorderWidth,
        ),
      ),
      child: Text(
        text,
        style: VesselFonts.textNote.copyWith(color: textColor),
      ),
    );
  }
}
