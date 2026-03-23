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
      color: AppColors.surfaceContainerLowest,
      elevation: 1,
      shadowColor: AppColors.onSurface.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.0),
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
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Gap.h4,
                        Text(
                          activity.date.ddMmmmYyyy,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Gap.w8,
                  Icon(
                    AppIcons.forward,
                    size: 20.0,
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
              Gap.h12,
              // Bottom row: Activity type badge, Finance badge, and Approval status
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  _ActivityTypeBadge(activityType: activity.activityType),
                  if (activity.financeType != null)
                    _FinanceBadge(financeType: activity.financeType!),
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
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: _getAccentColor().withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(color: _getAccentColor().withValues(alpha: 0.24)),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
      ),
      alignment: Alignment.center,
      child: Icon(_getIcon(), size: 22.0, color: _getAccentColor()),
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

  Color _getAccentColor() {
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

/// Activity type badge
class _ActivityTypeBadge extends StatelessWidget {
  const _ActivityTypeBadge({required this.activityType});

  final ActivityType activityType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: _getBadgeColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _getBadgeColor().withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 6),
      ),
      child: Text(
        activityType.displayName,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
          color: _getBadgeColor(),
          fontWeight: FontWeight.w600,
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

/// Finance type badge (revenue/expense)
class _FinanceBadge extends StatelessWidget {
  const _FinanceBadge({required this.financeType});

  final FinanceType financeType;

  @override
  Widget build(BuildContext context) {
    final isRevenue = financeType == FinanceType.revenue;
    final color = isRevenue ? AppColors.success : AppColors.error;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(financeType.icon, size: 14.0, color: color),
          Gap.w6,
          Text(
            financeType.displayName,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
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
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: statusInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: statusInfo.color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusInfo.icon, size: 14.0, color: statusInfo.color),
          Gap.w6,
          Text(
            statusInfo.label,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
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
          color: AppColors.success,
          icon: AppIcons.success,
        );
      case ApprovalStatus.rejected:
        return _StatusInfo(
          label: context.l10n.status_rejected,
          color: AppColors.error,
          icon: AppIcons.cancel,
        );
      case ApprovalStatus.unconfirmed:
        return _StatusInfo(
          label: context.l10n.status_pending,
          color: AppColors.warning,
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
