import 'package:flutter/material.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
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
    final l10n = context.l10n;
    final (bg, fg, label, icon) = switch (status) {
      ApprovalStatus.unconfirmed => (
        Colors.orange.shade50,
        Colors.orange.shade700,
        l10n.status_unconfirmed.toUpperCase(),
        Icons.pending,
      ),
      ApprovalStatus.approved => (
        Colors.green.shade50,
        Colors.green.shade700,
        l10n.status_approved.toUpperCase(),
        Icons.check_circle,
      ),
      ApprovalStatus.rejected => (
        Colors.red.shade50,
        Colors.red.shade700,
        l10n.status_rejected.toUpperCase(),
        Icons.cancel,
      ),
    };
    return CompactStatusChip(
      label: label,
      background: bg,
      foreground: fg,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final iconOnly =
            constraints.maxWidth.isFinite &&
            constraints.maxWidth > 0 &&
            constraints.maxWidth < 80;

        final double maxLabelWidth = constraints.maxWidth.isFinite
            ? (constraints.maxWidth - (14 + 6 + 16)).clamp(0, 140).toDouble()
            : 140.0;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: iconOnly ? 6 : 8,
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
              Icon(icon, color: foreground, size: 14),
              if (!iconOnly) ...[
                const SizedBox(width: 6),
                ConstrainedBox(
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
              ],
            ],
          ),
        );
      },
    );
  }
}
