import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/vessel_themes.dart';
import 'package:srpski_card/entities/tag/tag.dart';

/// A small colored chip that displays a tag
///
/// For tags with color: filled background with white text
/// For tags with no color (TagColor.none): transparent with border
class VesselTagChip extends StatelessWidget {
  final Tag tag;
  final VoidCallback? onTap;
  final bool showName;

  const VesselTagChip({
    super.key,
    required this.tag,
    this.onTap,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = VesselThemes.of(context);
    final tagColor = tag.color.getColor(themeData);
    final isTransparent = tag.color == TagColor.none;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isTransparent ? Colors.transparent : tagColor,
          borderRadius: BorderRadius.circular(themeData.tagBorderRadius),
          border: Border.all(
            color: isTransparent ? themeData.tagChipBorder : tagColor,
            width: themeData.tagBorderWidth,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isTransparent ? themeData.tagChipBorder : themeData.controlAccentForeground,
                shape: BoxShape.circle,
              ),
            ),
            if (showName) ...[
              const SizedBox(width: 6),
              Text(
                tag.name,
                style: VesselFonts.textVesselTagChip.copyWith(
                  color: isTransparent ? themeData.textPrimary : themeData.controlAccentForeground,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A small colored square preview for tag color selection
class VesselTagColorPreview extends StatelessWidget {
  final TagColor tagColor;
  final bool isSelected;
  final VoidCallback? onTap;

  const VesselTagColorPreview({
    super.key,
    required this.tagColor,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = VesselThemes.of(context);
    final color = tagColor.getColor(themeData);
    final isTransparent = tagColor == TagColor.none;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isTransparent ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(themeData.tagBorderRadius),
          border: Border.all(
            color: isSelected
                ? themeData.accentColor
                : (isTransparent ? themeData.tagChipBorder : color),
            width: isSelected ? 3 : themeData.tagBorderWidth,
          ),
        ),
        child: isTransparent
            ? Icon(
                Icons.do_not_disturb_alt,
                size: 16,
                color: themeData.tagChipBorder,
              )
            : null,
      ),
    );
  }
}
