import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final bool elevated;
  final EdgeInsets? padding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderWidth;
  final Color? borderColor;
  final bool fullWidth;

  const StatusChip({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    this.elevated = false,
    this.padding,
    this.fontSize,
    this.fontWeight,
    this.borderWidth,
    this.borderColor,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    final resolvedWeight = fontWeight ?? FontWeight.w600;
    final resolvedFontSize = fontSize;
    final resolvedBorderWidth = borderWidth ?? 1;
    final resolvedBorderColor =
        borderColor ?? foreground.withValues(alpha: 0.2);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double iconSizePx = (resolvedFontSize ?? 13).toDouble() + 3;
        final iconOnly =
            icon != null &&
            constraints.maxWidth.isFinite &&
            constraints.maxWidth > 0 &&
            constraints.maxWidth < 80;

        final double maxLabelWidth = constraints.maxWidth.isFinite
            ? (constraints.maxWidth -
                      (icon == null ? 0 : (iconSizePx + 6)) -
                      resolvedPadding.horizontal)
                  .clamp(0, 200)
                  .toDouble()
            : 200.0;

        return Container(
          width: fullWidth ? double.infinity : null,
          padding: resolvedPadding,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: resolvedBorderColor,
              width: resolvedBorderWidth,
            ),
            boxShadow: elevated
                ? [
                    BoxShadow(
                      color: foreground.withValues(alpha: 0.18),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: fullWidth
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: foreground, size: iconSizePx),
                if (!iconOnly) const SizedBox(width: 6),
              ],
              if (!iconOnly)
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxLabelWidth),
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: resolvedWeight,
                      fontSize: resolvedFontSize,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
