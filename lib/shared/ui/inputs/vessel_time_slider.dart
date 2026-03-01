import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/vessel_themes.dart';
import 'package:srpski_card/shared/ui/inputs/vessel_slider_input.dart';

/// A dual-slider time input with hours (left) and minutes (right).
class VesselTimeSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;
  final int max;
  final bool showButtons;
  final bool showInput;
  final String? label;

  const VesselTimeSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.max = 480,
    this.showButtons = false,
    this.showInput = true,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = VesselThemes.of(context);
    final hours = value ~/ 60;
    final minutes = value % 60;
    final maxHours = max ~/ 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: VesselFonts.textFormLabel.copyWith(color: theme.textPrimary),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: VesselSliderInput(
                value: hours,
                min: 0,
                max: maxHours,
                inputSuffix: 'H',
                showButtons: showButtons,
                expandedButtons: true,
                showInput: showInput,
                onChanged: onChanged != null
                    ? (newHours) => onChanged!(newHours * 60 + minutes)
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: VesselSliderInput(
                value: minutes,
                min: 0,
                max: 59,
                step: showButtons ? 5 : 1,
                inputSuffix: 'M',
                showButtons: showButtons,
                expandedButtons: true,
                showInput: showInput,
                onChanged: onChanged != null
                    ? (newMin) => onChanged!(hours * 60 + newMin)
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
