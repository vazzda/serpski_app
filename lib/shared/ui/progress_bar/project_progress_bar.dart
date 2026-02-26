import 'package:flutter/material.dart';

import '../../../app/theme/app_themes.dart';

/// Display mode for the progress bar.
enum ProgressBarMode {
  /// Compact: thinner bar, suitable for list rows and tiles.
  compact,

  /// Detailed: taller bar, suitable for detail views and cards.
  detailed,
}

/// A themed linear progress bar.
///
/// [value] must be between 0.0 and 1.0.
/// Sizing and colors come entirely from [AppThemeData].
class ProjectProgressBar extends StatelessWidget {
  const ProjectProgressBar({
    super.key,
    required this.value,
    this.mode = ProgressBarMode.compact,
  });

  final double value;
  final ProgressBarMode mode;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    final height = mode == ProgressBarMode.compact
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
