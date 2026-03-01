import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srpski_card/app/theme/vessel_themes.dart';
import 'package:srpski_card/app/providers/theme_provider.dart';
import 'package:srpski_card/shared/ui/buttons/vessel_button_styles.dart';

/// Configuration for a single button in a button group
class VesselButtonGroupItem {
  final IconData? icon;
  final String? label;
  final VoidCallback? onPressed;
  final bool isSelected;

  const VesselButtonGroupItem({
    this.icon,
    this.label,
    this.onPressed,
    this.isSelected = false,
  }) : assert(icon != null || label != null, 'Either icon or label must be provided');
}

/// A group of buttons that share borders and appear as a single connected unit.
///
/// When [maxPerRow] is set, items are chunked into rows of that size.
/// Each row is independently rounded and rows are separated by a small gap.
class ProjectButtonGroup extends ConsumerWidget {
  final List<VesselButtonGroupItem> items;
  final VesselButtonSize size;
  final bool expanded;

  /// When set, wraps items into rows of this many buttons.
  /// null = single row (default behavior).
  final int? maxPerRow;

  const ProjectButtonGroup({
    super.key,
    required this.items,
    this.size = VesselButtonSize.medium,
    this.expanded = false,
    this.maxPerRow,
  }) : assert(items.length >= 1, 'Button group must have at least 1 item');


  List<List<VesselButtonGroupItem>> get _chunks {
    final n = maxPerRow!;
    final result = <List<VesselButtonGroupItem>>[];
    for (var i = 0; i < items.length; i += n) {
      result.add(items.sublist(i, (i + n).clamp(0, items.length)));
    }
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = VesselThemes.of(context);
    final appTheme = ref.watch(themeProvider);
    final baseColors = VesselButtonStyleResolver.resolveColors(
      context,
      theme: appTheme,
      variant: ButtonVariant.base,
    );
    final accentColors = VesselButtonStyleResolver.resolveColors(
      context,
      theme: appTheme,
      variant: ButtonVariant.accent,
    );

    final borderRadius = theme.buttonBorderRadius;
    final borderWidth = size == VesselButtonSize.large
        ? theme.buttonBorderWidth * 2
        : theme.buttonBorderWidth;

    if (maxPerRow != null) {
      final chunks = _chunks;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(chunks.length, (rowIndex) {
          final isLastRow = rowIndex == chunks.length - 1;
          final chunk = chunks[rowIndex];
          return Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            children: List.generate(chunk.length, (index) {
              final item = chunk[index];
              final isFirst = index == 0;
              final isLast = index == chunk.length - 1;
              final colors = item.isSelected ? accentColors : baseColors;
              return expanded
                  ? Expanded(child: _buildButton(context, item, isFirst, isLast, colors, borderRadius, borderWidth, isLastRow: isLastRow))
                  : _buildButton(context, item, isFirst, isLast, colors, borderRadius, borderWidth, isLastRow: isLastRow);
            }),
          );
        }),
      );
    }

    return Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isFirst = index == 0;
        final isLast = index == items.length - 1;
        final colors = item.isSelected ? accentColors : baseColors;

        return expanded
            ? Expanded(child: _buildButton(context, item, isFirst, isLast, colors, borderRadius, borderWidth))
            : _buildButton(context, item, isFirst, isLast, colors, borderRadius, borderWidth);
      }),
    );
  }

  Widget _buildButton(
    BuildContext context,
    VesselButtonGroupItem item,
    bool isFirst,
    bool isLast,
    VesselButtonColors colors,
    double borderRadius,
    double borderWidth, {
    bool isLastRow = true,
  }) {
    final isEnabled = item.onPressed != null;
    final useFullColors = isEnabled || item.isSelected;
    final bgColor = useFullColors ? colors.background : colors.disabledBackground;
    final fgColor = useFullColors ? colors.foreground : colors.disabledForeground;
    final borderColor = useFullColors ? colors.border : colors.disabledBorder;

    final radius = Radius.circular(borderRadius);
    const noRadius = Radius.zero;

    final borderSide = BorderSide(color: borderColor, width: borderWidth);
    // Non-last rows suppress their bottom border to avoid double-border at seam.
    final bottomBorder = isLastRow ? borderSide : BorderSide.none;
    // Bottom radius only on last row.
    final bottomLeftRadius = isFirst && isLastRow ? radius : noRadius;
    final bottomRightRadius = isLast && isLastRow ? radius : noRadius;

    final double minHeight;
    final double hPadding;
    final double iconSize;
    final TextStyle textStyle;

    switch (size) {
      case VesselButtonSize.small:
        minHeight = 32.0;
        hPadding = 10.0;
        iconSize = 20.0;
        textStyle = VesselFonts.textButtonSmall;
        break;
      case VesselButtonSize.medium:
        minHeight = 44.0;
        hPadding = 16.0;
        iconSize = 28.0;
        textStyle = VesselFonts.textButton;
        break;
      case VesselButtonSize.large:
        minHeight = 56.0;
        hPadding = 24.0;
        iconSize = 32.0;
        textStyle = VesselFonts.textButtonLarge;
        break;
    }

    Widget child;
    final iconOnly = item.icon != null && (item.label == null || item.label!.isEmpty);

    if (iconOnly) {
      child = Icon(item.icon, size: iconSize, color: fgColor);
    } else if (item.icon != null && item.label != null && item.label!.isNotEmpty) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: iconSize * 0.8, color: fgColor),
          const SizedBox(width: 8),
          Text(item.label!.toUpperCase(), style: textStyle.copyWith(color: fgColor)),
        ],
      );
    } else {
      child = Text(item.label!.toUpperCase(), style: textStyle.copyWith(color: fgColor));
    }

    return GestureDetector(
      onTap: item.onPressed,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: EdgeInsets.symmetric(
          horizontal: iconOnly ? hPadding * 0.6 : hPadding,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: isFirst ? radius : noRadius,
            bottomLeft: bottomLeftRadius,
            topRight: isLast ? radius : noRadius,
            bottomRight: bottomRightRadius,
          ),
          border: Border(
            top: borderSide,
            bottom: bottomBorder,
            left: isFirst ? borderSide : BorderSide.none,
            right: borderSide,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}
