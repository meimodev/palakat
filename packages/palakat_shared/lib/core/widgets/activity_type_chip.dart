import 'package:flutter/material.dart';
import 'package:palakat_shared/core/constants/enums.dart';

/// A reusable chip widget for displaying activity types with appropriate
/// colors and icons across the app.
class ActivityTypeChip extends StatelessWidget {
  final ActivityType type;
  final double? iconSize;
  final double? fontSize;

  const ActivityTypeChip({
    super.key,
    required this.type,
    this.iconSize,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, icon) = switch (type) {
      ActivityType.service => (Colors.teal, Icons.handshake),
      ActivityType.event => (Colors.red, Icons.event),
      ActivityType.announcement => (Colors.blue, Icons.campaign),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final double iconW = iconSize ?? 14.0;
        final iconOnly =
            constraints.maxWidth.isFinite &&
            constraints.maxWidth > 0 &&
            constraints.maxWidth < 80;

        final double maxLabelWidth = constraints.maxWidth.isFinite
            ? (constraints.maxWidth - (iconW + 6 + 20)).clamp(0, 160).toDouble()
            : 160.0;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: iconOnly ? 8 : 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconW, color: color),
              if (!iconOnly) ...[
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxLabelWidth),
                  child: Text(
                    type.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: (theme.textTheme.labelMedium ?? const TextStyle())
                        .copyWith(
                          color: color,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
