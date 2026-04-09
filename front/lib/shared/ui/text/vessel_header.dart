import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/vessel_themes.dart';

/// Project-wide header component for section titles
class VesselHeader extends StatelessWidget {
  final String text;

  const VesselHeader({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = VesselThemes.of(context);

    return Text(
      text,
      style: VesselFonts.textSubtitle.copyWith(color: theme.textPrimary),
    );
  }
}
