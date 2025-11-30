import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/activity.dart';
import 'package:palakat_shared/core/models/finance_type.dart';
import 'package:palakat_shared/extensions.dart';

/// Widget displaying a single supervised activity item.
/// Shows activity title, formatted date, activity type badge, and approval status via color-coded border.
///
/// Approval status colors:
/// - Green: All approvers approved
/// - Red: Any approver rejected
/// - Orange/Amber: Pending (unconfirmed)
///
/// Requirements: 1.3, 1.4
class SupervisedActivityItemWidget extends StatelessWidget {
  const SupervisedActivityItemWidget({
    super.key,
    required this.activity,
    required this.onTap,
  });

  final Activity activity;
  final VoidCallback onTap;

  /// Determines the overall approval status based on all approvers
  _ApprovalStatusInfo get _approvalStatus {
    final approvers = activity.approvers;

    if (approvers.isEmpty) {
      return _ApprovalStatusInfo(
        color: BaseColor.neutral[400]!,
        label: 'No approvers',
      );
    }

    // Check if any approver rejected
    final hasRejected = approvers.any(
      (a) => a.status == ApprovalStatus.rejected,
    );
    if (hasRejected) {
      return _ApprovalStatusInfo(color: BaseColor.red[500]!, label: 'Rejected');
    }

    // Check if all approved
    final allApproved = approvers.every(
      (a) => a.status == ApprovalStatus.approved,
    );
    if (allApproved) {
      return _ApprovalStatusInfo(
        color: BaseColor.green[500]!,
        label: 'Approved',
      );
    }

    // Otherwise pending
    return _ApprovalStatusInfo(color: BaseColor.yellow[600]!, label: 'Pending');
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _approvalStatus;

    return Material(
      color: BaseColor.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: statusInfo.color, width: 4)),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.w12,
            vertical: BaseSize.h8,
          ),
          child: Row(
            children: [
              // Activity details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title and type in one row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activity.title,
                            style: BaseTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: BaseColor.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Gap.w8,
                        _ActivityTypeBadge(activityType: activity.activityType),
                      ],
                    ),
                    Gap.h4,
                    // Date, approval status, and financial type
                    Row(
                      children: [
                        Text(
                          activity.date.ddMmmmYyyy,
                          style: BaseTypography.labelSmall.copyWith(
                            color: BaseColor.textSecondary,
                          ),
                        ),
                        Gap.w8,
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: BaseColor.neutral[300],
                            shape: BoxShape.circle,
                          ),
                        ),
                        Gap.w8,
                        Text(
                          statusInfo.label,
                          style: BaseTypography.labelSmall.copyWith(
                            color: statusInfo.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (activity.financeType != null) ...[
                          Gap.w8,
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: BaseColor.neutral[300],
                              shape: BoxShape.circle,
                            ),
                          ),
                          Gap.w8,
                          _FinanceTypeBadge(financeType: activity.financeType!),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Gap.w4,
              // Chevron icon
              Icon(
                Icons.chevron_right,
                size: BaseSize.w16,
                color: BaseColor.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper class to hold approval status info
class _ApprovalStatusInfo {
  const _ApprovalStatusInfo({required this.color, required this.label});

  final Color color;
  final String label;
}

/// Compact badge displaying the activity type
class _ActivityTypeBadge extends StatelessWidget {
  const _ActivityTypeBadge({required this.activityType});

  final ActivityType activityType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w6,
        vertical: BaseSize.h4,
      ),
      decoration: BoxDecoration(
        color: _getBadgeColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        activityType.displayName,
        style: BaseTypography.labelSmall.copyWith(
          color: _getBadgeColor(),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getBadgeColor() {
    switch (activityType) {
      case ActivityType.service:
        return BaseColor.primary[700]!;
      case ActivityType.event:
        return BaseColor.blue[700]!;
      case ActivityType.announcement:
        return BaseColor.yellow[700]!;
    }
  }
}

/// Compact badge displaying the financial type
class _FinanceTypeBadge extends StatelessWidget {
  const _FinanceTypeBadge({required this.financeType});

  final FinanceType financeType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w6,
        vertical: BaseSize.h4,
      ),
      decoration: BoxDecoration(
        color: financeType.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(financeType.icon, size: 10, color: financeType.color),
          Gap.w4,
          Text(
            financeType.displayName,
            style: BaseTypography.labelSmall.copyWith(
              color: financeType.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
