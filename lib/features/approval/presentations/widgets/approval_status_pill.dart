import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

class ApprovalStatusPill extends StatelessWidget {
  const ApprovalStatusPill({super.key, required this.status});

  final ApprovalStatus status;

  Color _statusColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.approved:
        return BaseColor.green.shade600;
      case ApprovalStatus.rejected:
        return BaseColor.red.shade500;
      case ApprovalStatus.unconfirmed:
        return BaseColor.yellow.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    IconData icon;
    String label;
    switch (status) {
      case ApprovalStatus.approved:
        icon = Icons.check_circle;
        label = 'Approved';
        break;
      case ApprovalStatus.rejected:
        icon = Icons.cancel;
        label = 'Rejected';
        break;
      case ApprovalStatus.unconfirmed:
        icon = Icons.pending;
        label = 'Pending';
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w12,
        vertical: BaseSize.h8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: BaseSize.w20, color: color),
          Gap.w8,
          Text(
            label,
            style: BaseTypography.bodyMedium.copyWith(
              color: BaseColor.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
