import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/constants/enums/enums.dart';

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
      default:
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
        icon = Icons.check_circle_rounded;
        label = 'Approved';
        break;
      case ApprovalStatus.rejected:
        icon = Icons.cancel_rounded;
        label = 'Rejected';
        break;
      case ApprovalStatus.unconfirmed:
      default:
        icon = Icons.hourglass_bottom_rounded;
        label = 'Unconfirmed';
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w8,
        vertical: BaseSize.h6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: BaseSize.w16, color: color),
          Gap.w6,
          Text(
            label,
            style: BaseTypography.bodyMedium.copyWith(
              color: BaseColor.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
