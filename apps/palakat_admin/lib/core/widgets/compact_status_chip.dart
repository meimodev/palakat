import 'package:flutter/material.dart';
import 'package:palakat_admin/core/models/approval_status.dart';

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

  factory CompactStatusChip.forApproval(ApprovalStatus status) {
    final (bg, fg, label) = switch (status) {
      ApprovalStatus.unconfirmed => (
        Colors.orange.shade50,
        Colors.orange.shade700,
        ApprovalStatus.unconfirmed.name.toUpperCase(),
      ),
      ApprovalStatus.approved => (
        Colors.green.shade50,
        Colors.green.shade700,
        ApprovalStatus.approved.name.toUpperCase(),
      ),
      ApprovalStatus.rejected => (
        Colors.red.shade50,
        Colors.red.shade700,
        ApprovalStatus.rejected.name.toUpperCase(),
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
              "UNCONFIRMED" => Icons.pending,
              "APPROVED" => Icons.check_circle,
              "REJECTED" => Icons.cancel,
              _ => Icons.help_outline,
            },
            color: foreground,
            size: 14,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w500,
                fontSize: 12,
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
