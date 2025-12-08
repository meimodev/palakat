import 'package:flutter/material.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/models/approval_status.dart';

class CompactStatusChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const CompactStatusChip({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  /// Creates a CompactStatusChip for the given approval status with localized label.
  /// Requires BuildContext to access l10n translations.
  static CompactStatusChip forApproval(
    BuildContext context,
    ApprovalStatus status,
  ) {
    final l10n = context.l10n;
    final (bg, fg, label) = switch (status) {
      ApprovalStatus.unconfirmed => (
        Colors.orange.shade50,
        Colors.orange.shade700,
        l10n.status_unconfirmed.toUpperCase(),
      ),
      ApprovalStatus.approved => (
        Colors.green.shade50,
        Colors.green.shade700,
        l10n.status_approved.toUpperCase(),
      ),
      ApprovalStatus.rejected => (
        Colors.red.shade50,
        Colors.red.shade700,
        l10n.status_rejected.toUpperCase(),
      ),
    };
    return CompactStatusChip(label: label, background: bg, foreground: fg);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: foreground.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            switch (label.toUpperCase()) {
              "UNCONFIRMED" || "BELUM DIKONFIRMASI" => Icons.pending,
              "APPROVED" || "DISETUJUI" => Icons.check_circle,
              "REJECTED" || "DITOLAK" => Icons.cancel,
              _ => Icons.help_outline,
            },
            color: foreground,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
