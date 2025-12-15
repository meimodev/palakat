import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/activity.dart';
import 'package:palakat_shared/core/models/finance_type.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/extensions.dart';

/// Widget displaying a single activity item in the supervised activities list.
/// Shows activity title, date, type, and approval status.
///
/// Requirements: 2.4
class SupervisedActivityListItemWidget extends StatelessWidget {
  const SupervisedActivityListItemWidget({
    super.key,
    required this.activity,
    required this.onTap,
  });

  final Activity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BaseColor.white,
      elevation: 1,
      shadowColor: BaseColor.shadow.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Icon, Title, and Chevron
              Row(
                children: [
                  _ActivityIcon(activityType: activity.activityType),
                  Gap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: BaseTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: BaseColor.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Gap.h4,
                        Text(
                          activity.date.ddMmmmYyyy,
                          style: BaseTypography.bodySmall.copyWith(
                            color: BaseColor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap.w8,
                  Icon(
                    AppIcons.forward,
                    size: BaseSize.w20,
                    color: BaseColor.textSecondary,
                  ),
                ],
              ),
              Gap.h12,
              // Bottom row: Activity type badge, Finance badge, and Approval status
              Row(
                children: [
                  _ActivityTypeBadge(activityType: activity.activityType),
                  Gap.w8,
                  if (activity.financeType != null) ...[
                    _FinanceBadge(financeType: activity.financeType!),
                    Gap.w8,
                  ],
                  _ApprovalStatusBadge(activity: activity),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Activity icon based on type
class _ActivityIcon extends StatelessWidget {
  const _ActivityIcon({required this.activityType});

  final ActivityType activityType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: BaseSize.w40,
      height: BaseSize.w40,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(_getIcon(), size: BaseSize.w22, color: _getIconColor()),
    );
  }

  IconData _getIcon() {
    switch (activityType) {
      case ActivityType.service:
        return AppIcons.church;
      case ActivityType.event:
        return AppIcons.event;
      case ActivityType.announcement:
        return AppIcons.announcement;
    }
  }

  Color _getBackgroundColor() {
    switch (activityType) {
      case ActivityType.service:
        return BaseColor.primary[50]!;
      case ActivityType.event:
        return BaseColor.blue[50]!;
      case ActivityType.announcement:
        return BaseColor.yellow[50]!;
    }
  }

  Color _getIconColor() {
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

/// Activity type badge
class _ActivityTypeBadge extends StatelessWidget {
  const _ActivityTypeBadge({required this.activityType});

  final ActivityType activityType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w8,
        vertical: BaseSize.h4,
      ),
      decoration: BoxDecoration(
        color: _getBadgeColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _getBadgeColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        activityType.displayName,
        style: BaseTypography.labelMedium.copyWith(
          color: _getBadgeColor(),
          fontWeight: FontWeight.w600,
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

/// Finance type badge (revenue/expense)
class _FinanceBadge extends StatelessWidget {
  const _FinanceBadge({required this.financeType});

  final FinanceType financeType;

  @override
  Widget build(BuildContext context) {
    final isRevenue = financeType == FinanceType.revenue;
    final color = isRevenue ? BaseColor.green[700]! : BaseColor.red[700]!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w8,
        vertical: BaseSize.h4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(financeType.icon, size: BaseSize.w12, color: color),
          Gap.w4,
          Text(
            financeType.displayName,
            style: BaseTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Approval status badge showing the overall approval state
class _ApprovalStatusBadge extends StatelessWidget {
  const _ApprovalStatusBadge({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final status = _getOverallStatus();
    final statusInfo = _getStatusInfo(context, status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w8,
        vertical: BaseSize.h4,
      ),
      decoration: BoxDecoration(
        color: statusInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: statusInfo.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusInfo.icon, size: BaseSize.w12, color: statusInfo.color),
          Gap.w4,
          Text(
            statusInfo.label,
            style: BaseTypography.labelMedium.copyWith(
              color: statusInfo.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Determines the overall approval status based on all approvers
  ApprovalStatus _getOverallStatus() {
    if (activity.approvers.isEmpty) {
      return ApprovalStatus.unconfirmed;
    }

    // If any approver rejected, the activity is rejected
    final hasRejected = activity.approvers.any(
      (a) => a.status == ApprovalStatus.rejected,
    );
    if (hasRejected) {
      return ApprovalStatus.rejected;
    }

    // If all approvers approved, the activity is approved
    final allApproved = activity.approvers.every(
      (a) => a.status == ApprovalStatus.approved,
    );
    if (allApproved) {
      return ApprovalStatus.approved;
    }

    // Otherwise, it's still pending (unconfirmed)
    return ApprovalStatus.unconfirmed;
  }

  _StatusInfo _getStatusInfo(BuildContext context, ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.approved:
        return _StatusInfo(
          label: context.l10n.status_approved,
          color: BaseColor.green[700]!,
          icon: AppIcons.success,
        );
      case ApprovalStatus.rejected:
        return _StatusInfo(
          label: context.l10n.status_rejected,
          color: BaseColor.red[700]!,
          icon: AppIcons.cancel,
        );
      case ApprovalStatus.unconfirmed:
        return _StatusInfo(
          label: context.l10n.status_pending,
          color: BaseColor.yellow[700]!,
          icon: AppIcons.schedule,
        );
    }
  }
}

class _StatusInfo {
  const _StatusInfo({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}
