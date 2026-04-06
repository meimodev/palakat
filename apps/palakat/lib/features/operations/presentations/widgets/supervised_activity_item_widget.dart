import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/activity.dart';
import 'package:palakat_shared/core/models/finance_type.dart';
import 'package:palakat_shared/core/extension/extension.dart';
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
  _ApprovalStatusInfo _approvalStatus(BuildContext context) {
    final approvers = activity.approvers;

    if (approvers.isEmpty) {
      return _ApprovalStatusInfo(
        color: AppColors.outline,
        label: context.l10n.msg_noApproversAssigned,
      );
    }

    // Check if any approver rejected
    final hasRejected = approvers.any(
      (a) => a.status == ApprovalStatus.rejected,
    );
    if (hasRejected) {
      return _ApprovalStatusInfo(
        color: AppColors.error,
        label: context.l10n.status_rejected,
      );
    }

    // Check if all approved
    final allApproved = approvers.every(
      (a) => a.status == ApprovalStatus.approved,
    );
    if (allApproved) {
      return _ApprovalStatusInfo(
        color: AppColors.success,
        label: context.l10n.status_approved,
      );
    }

    // Otherwise pending
    return _ApprovalStatusInfo(
      color: AppColors.warning,
      label: context.l10n.status_pending,
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _approvalStatus(context);

    return Material(
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.ghostBorder(0.08)),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: statusInfo.color, width: 4)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              // Activity details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      activity.title,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Row(
                      children: [
                        Text(
                          activity.date.ddMmmmYyyy,
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        Gap.w8,
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Gap.w8,
                        _StatusInfoBadge(
                          statusInfoColor: statusInfo.color,
                          statusInfo: statusInfo.label,
                        ),

                        Gap.w8,
                        _ActivityTypeBadge(activityType: activity.activityType),
                        Gap.w8,
                        if (activity.financeType != null)
                          _FinanceTypeBadge(financeType: activity.financeType!),
                      ],
                    ),
                  ],
                ),
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

class _ActivityTypeBadge extends StatelessWidget {
  const _ActivityTypeBadge({required this.activityType});

  final ActivityType activityType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: _getBadgeColor().withValues(alpha: 0.1),
        border: Border.all(color: _getBadgeColor().withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        activityType.displayName,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
          color: _getBadgeColor(),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getBadgeColor() {
    switch (activityType) {
      case ActivityType.service:
        return AppColors.primary;
      case ActivityType.event:
        return AppColors.primary;
      case ActivityType.announcement:
        return AppColors.warning;
    }
  }
}

class _FinanceTypeBadge extends StatelessWidget {
  const _FinanceTypeBadge({required this.financeType});

  final FinanceType financeType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: financeType.color.withValues(alpha: 0.1),
        border: Border.all(color: financeType.color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(80),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(financeType.icon, size: 12, color: financeType.color)],
      ),
    );
  }
}

class _StatusInfoBadge extends StatelessWidget {
  const _StatusInfoBadge({
    required this.statusInfo,
    required this.statusInfoColor,
  });

  final String statusInfo;
  final Color statusInfoColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: statusInfoColor.withValues(alpha: 0.075),
        border: Border.all(color: statusInfoColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        statusInfo,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
          color: statusInfoColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
