import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/vessel_themes.dart';

/// Themed divider control
class VesselDivider extends StatelessWidget {
  const VesselDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = VesselThemes.of(context);
    return Divider(
      height: 1,
      thickness: theme.dividerWidth,
      color: theme.dividerColor,
    );
  }
}
