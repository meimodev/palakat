import 'package:flutter/material.dart';
import 'package:palakat_admin/core/constants/enums.dart';

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize ?? 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              type.displayName,
              style: (theme.textTheme.labelMedium ?? const TextStyle())
                  .copyWith(
                    color: color,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
