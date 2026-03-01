import 'package:flutter/material.dart';

import '../../../app/theme/vessel_themes.dart';

/// Display mode for the progress bar.
enum VesselProgressBarMode {
  /// Compact: thinner bar, suitable for list rows and tiles.
  compact,

  /// Detailed: taller bar, suitable for detail views and cards.
  detailed,
}

/// A themed linear progress bar.
///
/// [value] must be between 0.0 and 1.0.
/// Sizing and colors come entirely from [VesselThemeData].
class VesselProgressBar extends StatelessWidget {
  const VesselProgressBar({
    super.key,
    required this.value,
    this.mode = VesselProgressBarMode.compact,
  });

  final double value;
  final VesselProgressBarMode mode;

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);
    final height = mode == VesselProgressBarMode.compact
        ? t.progressBarCompactHeight
        : t.progressBarDetailedHeight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(t.progressBarBorderRadius),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        backgroundColor: t.progressBarUnfilled,
        valueColor: AlwaysStoppedAnimation<Color>(t.progressBarFilled),
        minHeight: height,
      ),
    );
  }
}
