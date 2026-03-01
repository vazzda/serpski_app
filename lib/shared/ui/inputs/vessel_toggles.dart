import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/vessel_themes.dart';

/// Label position for labeled controls
enum VesselLabelPosition { left, right }

CheckboxThemeData _checkboxTheme(BuildContext context) {
  final theme = VesselThemes.of(context);
  return CheckboxThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(theme.toggleBorderRadius),
    ),
    side: BorderSide(color: theme.textPrimary, width: theme.controlBorderWidth),
    fillColor: WidgetStateProperty.all(theme.controlBackground),
    checkColor: WidgetStateProperty.all(theme.textPrimary),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );
}

SwitchThemeData _switchTheme(BuildContext context) {
  final theme = VesselThemes.of(context);
  return SwitchThemeData(
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    thumbColor: WidgetStateProperty.all(theme.controlForeground),
    trackColor: WidgetStateProperty.all(theme.controlBackground),
    trackOutlineColor: WidgetStateProperty.all(theme.controlForeground),
    trackOutlineWidth: WidgetStateProperty.all(theme.controlBorderWidth),
  );
}

// =============================================================================
// BASE CONTROLS (no label)
// =============================================================================

class VesselCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const VesselCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(checkboxTheme: _checkboxTheme(context)),
      child: Checkbox(value: value, onChanged: onChanged),
    );
  }
}

class VesselSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const VesselSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(switchTheme: _switchTheme(context)),
      child: Switch(value: value, onChanged: onChanged),
    );
  }
}

// =============================================================================
// LABELED CONTROLS
// =============================================================================

class VesselCheckboxLabeled extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String label;
  final String? subtitle;
  final VesselLabelPosition labelPosition;
  final bool fullWidth;

  const VesselCheckboxLabeled({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.subtitle,
    this.labelPosition = VesselLabelPosition.right,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = VesselThemes.of(context);
    final checkbox = VesselCheckbox(value: value, onChanged: onChanged);

    final labelWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: VesselFonts.textControlInput.copyWith(color: theme.controlForeground),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: VesselFonts.textControlLabel.copyWith(color: theme.controlForeground),
          ),
      ],
    );

    final children = labelPosition == VesselLabelPosition.left
        ? [
            fullWidth ? Expanded(child: labelWidget) : Flexible(child: labelWidget),
            const SizedBox(width: 8),
            checkbox,
          ]
        : [
            checkbox,
            const SizedBox(width: 8),
            fullWidth ? Expanded(child: labelWidget) : Flexible(child: labelWidget),
          ];

    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class VesselSwitchLabeled extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;
  final VesselLabelPosition labelPosition;
  final bool fullWidth;

  const VesselSwitchLabeled({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.labelPosition = VesselLabelPosition.left,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = VesselThemes.of(context);
    final switchWidget = VesselSwitch(value: value, onChanged: onChanged);

    final labelWidget = Text(
      label,
      style: VesselFonts.textControlInput.copyWith(color: theme.controlForeground),
    );

    final children = labelPosition == VesselLabelPosition.left
        ? [
            fullWidth ? Expanded(child: labelWidget) : Flexible(child: labelWidget),
            const SizedBox(width: 8),
            switchWidget,
          ]
        : [
            switchWidget,
            const SizedBox(width: 8),
            fullWidth ? Expanded(child: labelWidget) : Flexible(child: labelWidget),
          ];

    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: children,
      ),
    );
  }
}
