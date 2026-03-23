import 'package:flutter/material.dart';
import 'package:palakat_shared/core/extension/approval_status_extension.dart';
import 'package:palakat_shared/core/models/approval_status.dart';

class CompactStatusChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final IconData icon;

  const CompactStatusChip({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
  });

  /// Creates a CompactStatusChip for the given approval status with localized label.
  /// Requires BuildContext to access l10n translations.
  static CompactStatusChip forApproval(
    BuildContext context,
    ApprovalStatus status,
  ) {
    final (bg, fg, label, icon) = status.displayProperties;
    return CompactStatusChip(
      label: label.toUpperCase(),
      background: bg,
      foreground: fg,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const iconSize = 14.0;
        final horizontalPadding =
            constraints.maxWidth.isFinite && constraints.maxWidth < 110
            ? 6.0
            : 8.0;
        final spacing =
            constraints.maxWidth.isFinite && constraints.maxWidth < 110
            ? 4.0
            : 6.0;
        final minLabelWidth = 52.0;
        final iconOnly =
            constraints.maxWidth.isFinite &&
            constraints.maxWidth > 0 &&
            constraints.maxWidth <
                (iconSize + spacing + (horizontalPadding * 2) + minLabelWidth);

        final double maxLabelWidth = constraints.maxWidth.isFinite
            ? (constraints.maxWidth -
                      iconSize -
                      (iconOnly ? 0 : spacing) -
                      (horizontalPadding * 2))
                  .clamp(0, 140)
                  .toDouble()
            : 140.0;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: foreground.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: foreground, size: iconSize),
              if (!iconOnly) ...[
                SizedBox(width: spacing),
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxLabelWidth),
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
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
