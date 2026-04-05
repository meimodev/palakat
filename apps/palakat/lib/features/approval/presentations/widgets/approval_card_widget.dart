import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/extensions.dart';
import 'package:palakat_shared/models.dart' hide Column;
import 'package:palakat/features/approval/presentations/widgets/approval_status_pill.dart';

class ApprovalCardWidget extends StatelessWidget {
  const ApprovalCardWidget({
    super.key,
    required this.approval,
    this.currentMembershipId,
    required this.onTap,
    required this.onApprove,
    required this.onReject,
    this.isLoading = false,
  });

  final Activity approval;
  final int? currentMembershipId;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool isLoading;

  /// Returns the background color based on overall approval status
  Color _getStatusBackgroundColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.approved:
        return AppColors.success.shade50;
      case ApprovalStatus.rejected:
        return AppColors.error.shade50;
      case ApprovalStatus.unconfirmed:
        return AppColors.warning.shade50;
    }
  }

  /// Returns the border color based on overall approval status
  Color _getStatusBorderColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.approved:
        return AppColors.success.shade200;
      case ApprovalStatus.rejected:
        return AppColors.error.shade200;
      case ApprovalStatus.unconfirmed:
        return AppColors.warning.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    ApprovalStatus overallStatus(List<Approver> items) {
      // Priority: any rejected -> rejected; else any unconfirmed -> unconfirmed; else approved
      final hasRejected = items.any((e) => e.status == ApprovalStatus.rejected);
      if (hasRejected) return ApprovalStatus.rejected;
      final hasUnconfirmed = items.any(
        (e) => e.status == ApprovalStatus.unconfirmed,
      );
      if (hasUnconfirmed) return ApprovalStatus.unconfirmed;
      return ApprovalStatus.approved;
    }

    final overall = overallStatus(approval.approvers);
    final bool isMinePending = approval.approvers.any(
      (ap) =>
          ap.status == ApprovalStatus.unconfirmed &&
          ap.membership!.id == currentMembershipId,
    );

    Widget statusPill(ApprovalStatus s) => ApprovalStatusPill(status: s);

    // Check for financial data
    final hasFinancial =
        approval.hasRevenue == true || approval.hasExpense == true;
    final isRevenue = approval.hasRevenue == true;

    return Material(
      color: _getStatusBackgroundColor(overall),
      elevation: 1,
      shadowColor: AppColors.onSurface.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: _getStatusBorderColor(overall), width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  FaIcon(
                    _getActivityTypeIcon(approval.activityType),
                    size: 14.0,
                    color: _getActivityTypeColor(approval.activityType),
                  ),
                  Gap.w6,
                  Text(
                    approval.activityType.displayName,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _getActivityTypeColor(approval.activityType),
                    ),
                  ),
                  if (hasFinancial) ...[
                    Gap.w6,
                    Container(
                      width: 4.0,
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: AppColors.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Gap.w6,
                    Text(
                      isRevenue
                          ? context.l10n.admin_revenue_title
                          : context.l10n.operationsItem_add_expense_title,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              Gap.h6,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      approval.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  Gap.w8,
                  FaIcon(
                    AppIcons.forward,
                    size: 18.0,
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
              Gap.h6,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      approval.supervisor.account?.name ??
                          context.l10n.lbl_unknown,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Gap.w6,
                  Text(
                    '•',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Gap.w6,
                  Text(
                    "${approval.date.slashDate} ${approval.date.HHmm}",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Gap.h6,
              _buildApproverSummary(context, approval),
              Gap.h8,
              // Conditional actions / status
              if (overall == ApprovalStatus.unconfirmed) ...[
                // Show unconfirmed status pill above actions when the pending approver is not me
                if (!isMinePending) statusPill(ApprovalStatus.unconfirmed),
                if (isMinePending) ...[
                  if (isLoading)
                    Center(
                      child: CompactLoadingWidget(
                        size: 18.0,
                        baseColor: AppColors.primary.withValues(alpha: 0.24),
                        highlightColor: AppColors.surface,
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _ActionIconButton(
                            icon: AppIcons.close,
                            color: AppColors.error.shade500,
                            onTap: onReject,
                          ),
                        ),
                        Gap.w8,
                        Expanded(
                          child: _ActionIconButton(
                            icon: AppIcons.approve,
                            color: AppColors.success.shade600,
                            onTap: onApprove,
                          ),
                        ),
                      ],
                    ),
                ],
              ] else ...[
                statusPill(overall),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApproverSummary(BuildContext context, Activity approval) {
    final approvedCount = approval.approvers
        .where((approver) => approver.status == ApprovalStatus.approved)
        .length;
    final totalCount = approval.approvers.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          spacing: 4.0,
          runSpacing: 4.0,
          children: approval.approvers
              .map((approver) => _buildApproverStatusDot(approver.status))
              .toList(),
        ),
        Gap.w8,
        Expanded(
          child: Text(
            '$approvedCount/$totalCount ${context.l10n.status_approved}',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildApproverStatusDot(ApprovalStatus status) {
    final color = switch (status) {
      ApprovalStatus.approved => AppColors.success,
      ApprovalStatus.rejected => AppColors.error,
      ApprovalStatus.unconfirmed => AppColors.warning,
    };

    return Container(
      width: 16.0,
      height: 16.0,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.28), width: 1),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 6.0,
        height: 6.0,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  IconData _getActivityTypeIcon(ActivityType type) {
    return switch (type) {
      ActivityType.service => AppIcons.church,
      ActivityType.event => AppIcons.event,
      ActivityType.announcement => AppIcons.announcement,
    };
  }

  Color _getActivityTypeColor(ActivityType type) {
    return switch (type) {
      ActivityType.service => AppColors.primary.shade700,
      ActivityType.event => AppColors.primary.shade700,
      ActivityType.announcement => AppColors.warning.shade700,
    };
  }
}

/// Helper widget for action icon buttons with Font Awesome icons
class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8.0),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: onTap,
        overlayColor: WidgetStateProperty.all(color.withValues(alpha: 0.12)),
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
          ),
          child: Center(child: FaIcon(icon, size: 18.0, color: color)),
        ),
      ),
    );
  }
}
