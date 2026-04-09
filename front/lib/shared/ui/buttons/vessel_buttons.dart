import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srpski_card/app/providers/theme_provider.dart';
import 'package:srpski_card/app/theme/vessel_themes.dart';
import 'package:srpski_card/shared/ui/buttons/vessel_button_styles.dart';

export 'vessel_button_styles.dart' show VesselButtonSize;

class VesselButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final VesselButtonSize size;
  final bool condensed;
  final EdgeInsets margin;

  const VesselButton({
    super.key,
    this.onPressed,
    this.label,
    this.icon,
    this.size = VesselButtonSize.medium,
    this.condensed = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 4),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final colors = VesselButtonStyleResolver.resolveColors(
      context,
      theme: theme,
      variant: ButtonVariant.base,
    );
    final iconOnly = icon != null && (label == null || label!.isEmpty);
    final hasIconAndText = icon != null && label != null && label!.isNotEmpty;
    final iconSize = iconOnly
        ? VesselButtonStyleResolver.getIconOnlySize(size)
        : VesselButtonStyleResolver.getIconWithTextSize(size);
    final effectiveMargin = condensed
        ? EdgeInsets.symmetric(horizontal: margin.horizontal / 4)
        : margin;

    final themeData = VesselThemes.getThemeData(theme);
    final button = OutlinedButton(
      onPressed: onPressed,
      style: VesselButtonStyleResolver.style(
        context: context,
        colors: colors,
        iconOnly: iconOnly,
        hasIconAndText: hasIconAndText,
        size: size,
        condensed: condensed,
        variant: ButtonVariant.base,
      ),
      child: _buildChild(iconOnly, iconSize),
    );

    Widget result = button;
    if (themeData.componentShadow != null) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(themeData.buttonBorderRadius),
          boxShadow: themeData.componentShadow,
        ),
        child: result,
      );
    }

    return effectiveMargin == EdgeInsets.zero
        ? result
        : Padding(padding: effectiveMargin, child: result);
  }

  Widget _buildChild(bool iconOnly, double iconSize) {
    final iconWidget = icon != null ? Icon(icon, size: iconSize) : null;
    if (iconOnly) return iconWidget!;
    if (iconWidget != null && label != null && label!.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [iconWidget, const SizedBox(width: 8), Text(label!.toUpperCase())],
      );
    }
    return Text((label ?? '').toUpperCase());
  }
}

class VesselAccentButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final VesselButtonSize size;
  final bool condensed;
  final EdgeInsets margin;

  const VesselAccentButton({
    super.key,
    this.onPressed,
    this.label,
    this.icon,
    this.size = VesselButtonSize.medium,
    this.condensed = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 4),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final colors = VesselButtonStyleResolver.resolveColors(
      context,
      theme: theme,
      variant: ButtonVariant.accent,
    );
    final iconOnly = icon != null && (label == null || label!.isEmpty);
    final hasIconAndText = icon != null && label != null && label!.isNotEmpty;
    final iconSize = iconOnly
        ? VesselButtonStyleResolver.getIconOnlySize(size)
        : VesselButtonStyleResolver.getIconWithTextSize(size);
    final effectiveMargin = condensed
        ? EdgeInsets.symmetric(horizontal: margin.horizontal / 4)
        : margin;

    final themeData = VesselThemes.getThemeData(theme);
    final button = OutlinedButton(
      onPressed: onPressed,
      style: VesselButtonStyleResolver.style(
        context: context,
        colors: colors,
        iconOnly: iconOnly,
        hasIconAndText: hasIconAndText,
        size: size,
        condensed: condensed,
        variant: ButtonVariant.accent,
      ),
      child: _buildChild(iconOnly, iconSize),
    );

    Widget result = button;
    if (themeData.componentShadow != null) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(themeData.buttonBorderRadius),
          boxShadow: themeData.componentShadow,
        ),
        child: result,
      );
    }

    return effectiveMargin == EdgeInsets.zero
        ? result
        : Padding(padding: effectiveMargin, child: result);
  }

  Widget _buildChild(bool iconOnly, double iconSize) {
    final iconWidget = icon != null ? Icon(icon, size: iconSize) : null;
    if (iconOnly) return iconWidget!;
    if (iconWidget != null && label != null && label!.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [iconWidget, const SizedBox(width: 8), Text(label!.toUpperCase())],
      );
    }
    return Text((label ?? '').toUpperCase());
  }
}

class VesselDangerButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final VesselButtonSize size;
  final bool condensed;
  final EdgeInsets margin;

  const VesselDangerButton({
    super.key,
    this.onPressed,
    this.label,
    this.icon,
    this.size = VesselButtonSize.medium,
    this.condensed = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 4),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final colors = VesselButtonStyleResolver.resolveColors(
      context,
      theme: theme,
      variant: ButtonVariant.danger,
    );
    final iconOnly = icon != null && (label == null || label!.isEmpty);
    final hasIconAndText = icon != null && label != null && label!.isNotEmpty;
    final iconSize = iconOnly
        ? VesselButtonStyleResolver.getIconOnlySize(size)
        : VesselButtonStyleResolver.getIconWithTextSize(size);
    final effectiveMargin = condensed
        ? EdgeInsets.symmetric(horizontal: margin.horizontal / 4)
        : margin;

    final themeData = VesselThemes.getThemeData(theme);
    final button = OutlinedButton(
      onPressed: onPressed,
      style: VesselButtonStyleResolver.style(
        context: context,
        colors: colors,
        iconOnly: iconOnly,
        hasIconAndText: hasIconAndText,
        size: size,
        condensed: condensed,
        variant: ButtonVariant.danger,
      ),
      child: _buildChild(iconOnly, iconSize),
    );

    Widget result = button;
    if (themeData.componentShadow != null) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(themeData.buttonBorderRadius),
          boxShadow: themeData.componentShadow,
        ),
        child: result,
      );
    }

    return effectiveMargin == EdgeInsets.zero
        ? result
        : Padding(padding: effectiveMargin, child: result);
  }

  Widget _buildChild(bool iconOnly, double iconSize) {
    final iconWidget = icon != null ? Icon(icon, size: iconSize) : null;
    if (iconOnly) return iconWidget!;
    if (iconWidget != null && label != null && label!.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [iconWidget, const SizedBox(width: 8), Text(label!.toUpperCase())],
      );
    }
    return Text((label ?? '').toUpperCase());
  }
}

class VesselAccentTextButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final VesselButtonSize size;
  final bool condensed;
  final EdgeInsets margin;

  const VesselAccentTextButton({
    super.key,
    this.onPressed,
    this.label,
    this.icon,
    this.size = VesselButtonSize.medium,
    this.condensed = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 4),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final colors = VesselButtonStyleResolver.resolveColors(
      context,
      theme: theme,
      variant: ButtonVariant.textAccent,
    );
    final iconOnly = icon != null && (label == null || label!.isEmpty);
    final hasIconAndText = icon != null && label != null && label!.isNotEmpty;
    final iconSize = iconOnly
        ? VesselButtonStyleResolver.getIconOnlySize(size)
        : VesselButtonStyleResolver.getIconWithTextSize(size);
    final effectiveMargin = condensed
        ? EdgeInsets.symmetric(horizontal: margin.horizontal / 4)
        : margin;

    final button = OutlinedButton(
      onPressed: onPressed,
      style: VesselButtonStyleResolver.style(
        context: context,
        colors: colors,
        iconOnly: iconOnly,
        hasIconAndText: hasIconAndText,
        size: size,
        condensed: condensed,
        variant: ButtonVariant.textAccent,
      ),
      child: _buildChild(iconOnly, iconSize),
    );

    return effectiveMargin == EdgeInsets.zero
        ? button
        : Padding(padding: effectiveMargin, child: button);
  }

  Widget _buildChild(bool iconOnly, double iconSize) {
    final iconWidget = icon != null ? Icon(icon, size: iconSize) : null;
    if (iconOnly) return iconWidget!;
    if (iconWidget != null && label != null && label!.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [iconWidget, const SizedBox(width: 8), Text(label!.toUpperCase())],
      );
    }
    return Text((label ?? '').toUpperCase());
  }
}

class VesselTextButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final VesselButtonSize size;
  final bool condensed;
  final EdgeInsets margin;

  const VesselTextButton({
    super.key,
    this.onPressed,
    this.label,
    this.icon,
    this.size = VesselButtonSize.medium,
    this.condensed = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 4),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final colors = VesselButtonStyleResolver.resolveColors(
      context,
      theme: theme,
      variant: ButtonVariant.text,
    );
    final iconOnly = icon != null && (label == null || label!.isEmpty);
    final hasIconAndText = icon != null && label != null && label!.isNotEmpty;
    final iconSize = iconOnly
        ? VesselButtonStyleResolver.getIconOnlySize(size)
        : VesselButtonStyleResolver.getIconWithTextSize(size);
    final effectiveMargin = condensed
        ? EdgeInsets.symmetric(horizontal: margin.horizontal / 4)
        : margin;

    final button = OutlinedButton(
      onPressed: onPressed,
      style: VesselButtonStyleResolver.style(
        context: context,
        colors: colors,
        iconOnly: iconOnly,
        hasIconAndText: hasIconAndText,
        size: size,
        condensed: condensed,
        variant: ButtonVariant.text,
      ),
      child: _buildChild(iconOnly, iconSize),
    );

    return effectiveMargin == EdgeInsets.zero
        ? button
        : Padding(padding: effectiveMargin, child: button);
  }

  Widget _buildChild(bool iconOnly, double iconSize) {
    final iconWidget = icon != null ? Icon(icon, size: iconSize) : null;
    if (iconOnly) return iconWidget!;
    if (iconWidget != null && label != null && label!.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [iconWidget, const SizedBox(width: 8), Text(label!.toUpperCase())],
      );
    }
    return Text((label ?? '').toUpperCase());
  }
}

class VesselDangerTextButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final VesselButtonSize size;
  final bool condensed;
  final EdgeInsets margin;

  const VesselDangerTextButton({
    super.key,
    this.onPressed,
    this.label,
    this.icon,
    this.size = VesselButtonSize.medium,
    this.condensed = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 4),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final colors = VesselButtonStyleResolver.resolveColors(
      context,
      theme: theme,
      variant: ButtonVariant.textDanger,
    );
    final iconOnly = icon != null && (label == null || label!.isEmpty);
    final hasIconAndText = icon != null && label != null && label!.isNotEmpty;
    final iconSize = iconOnly
        ? VesselButtonStyleResolver.getIconOnlySize(size)
        : VesselButtonStyleResolver.getIconWithTextSize(size);
    final effectiveMargin = condensed
        ? EdgeInsets.symmetric(horizontal: margin.horizontal / 4)
        : margin;

    final button = OutlinedButton(
      onPressed: onPressed,
      style: VesselButtonStyleResolver.style(
        context: context,
        colors: colors,
        iconOnly: iconOnly,
        hasIconAndText: hasIconAndText,
        size: size,
        condensed: condensed,
        variant: ButtonVariant.textDanger,
      ),
      child: _buildChild(iconOnly, iconSize),
    );

    return effectiveMargin == EdgeInsets.zero
        ? button
        : Padding(padding: effectiveMargin, child: button);
  }

  Widget _buildChild(bool iconOnly, double iconSize) {
    final iconWidget = icon != null ? Icon(icon, size: iconSize) : null;
    if (iconOnly) return iconWidget!;
    if (iconWidget != null && label != null && label!.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [iconWidget, const SizedBox(width: 8), Text(label!.toUpperCase())],
      );
    }
    return Text((label ?? '').toUpperCase());
  }
}
