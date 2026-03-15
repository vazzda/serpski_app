import 'package:flutter/material.dart';

import '../../../app/theme/vessel_themes.dart';

enum VesselTileVariant { standard, roundAnswer }

/// Tappable themed tile for use inside cards or grids.
///
/// Uses [Ink] + [InkWell] — no Card widget, no outer margin, no inner padding.
/// All sizing and appearance driven by theme tile properties.
/// Content should be fully positioned using [Stack] + [Positioned].
class VesselTile extends StatelessWidget {
  const VesselTile({
    super.key,
    required this.child,
    this.onTap,
    this.variant = VesselTileVariant.standard,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VesselTileVariant variant;

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);
    final radius = BorderRadius.circular(t.tileBorderRadius);

    final Color bg;
    final Color borderColor;
    final double borderWidth;
    switch (variant) {
      case VesselTileVariant.standard:
        bg = t.tileBackground;
        borderColor = t.tileBorderColor;
        borderWidth = t.tileBorderWidth;
      case VesselTileVariant.roundAnswer:
        bg = t.roundAnswerTileBackground;
        borderColor = t.roundAnswerTileBorderColor;
        borderWidth = t.roundAnswerTileBorderWidth;
    }

    return Ink(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        borderRadius: radius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: child,
      ),
    );
  }
}
