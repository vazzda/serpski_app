import 'package:flutter/material.dart';

import '../../../app/theme/vessel_themes.dart';

/// Radio tile for single-value selection. Theme only.
class VesselRadioTile<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;
  final String label;
  final EdgeInsets contentPadding;

  const VesselRadioTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
    this.contentPadding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = VesselThemes.of(context);
    return RadioGroup<T>(
      groupValue: groupValue,
      onChanged: onChanged ?? (_) {},
      child: RadioListTile<T>(
        value: value,
        title: Text(
          label,
          style: VesselFonts.textControlInput.copyWith(
            color: theme.controlForeground,
          ),
        ),
        activeColor: theme.controlForeground,
        contentPadding: contentPadding,
        visualDensity: VisualDensity.compact,
        dense: true,
      ),
    );
  }
}
