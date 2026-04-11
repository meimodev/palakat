import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/approval/presentations/approval_item.dart';
import 'package:palakat/features/approval/presentations/widgets/approval_status_pill.dart';
import 'package:palakat_shared/extensions.dart';
import 'package:palakat_shared/models.dart' hide Column;

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

  final ApprovalItem approval;
  final int? currentMembershipId;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool isLoading;

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

  ApprovalStatus _overallStatus(List<Approver> items) {
    final hasRejected = items.any((e) => e.status == ApprovalStatus.rejected);
    if (hasRejected) return ApprovalStatus.rejected;
    final hasUnconfirmed = items.any(
      (e) => e.status == ApprovalStatus.unconfirmed,
    );
    if (hasUnconfirmed) return ApprovalStatus.unconfirmed;
    return ApprovalStatus.approved;
  }

  IconData _leadingIcon() {
    if (approval.isRevenue) {
      return AppIcons.revenue;
    }
    if (approval.isExpense) {
      return AppIcons.expense;
    }

    return switch (approval.activityType ?? ActivityType.service) {
      ActivityType.service => AppIcons.church,
      ActivityType.event => AppIcons.event,
      ActivityType.announcement => AppIcons.announcement,
    };
  }

  Color _leadingColor() {
    if (approval.isRevenue) {
      return AppColors.success.shade700;
    }
    if (approval.isExpense) {
      return AppColors.error.shade700;
    }

    return switch (approval.activityType ?? ActivityType.service) {
      ActivityType.service => AppColors.primary.shade700,
      ActivityType.event => AppColors.primary.shade700,
      ActivityType.announcement => AppColors.warning.shade700,
    };
  }

  String _primaryLabel(BuildContext context) {
    if (approval.isRevenue) {
      return context.l10n.admin_revenue_title;
    }
    if (approval.isExpense) {
      return context.l10n.operationsItem_add_expense_title;
    }
    return (approval.activityType ?? ActivityType.service).displayName;
  }

  String _timestampText(BuildContext context) {
    final displayDate = approval.displayDate;
    if (displayDate == null) {
      return context.l10n.lbl_unknown;
    }
    return '${displayDate.slashDate} ${displayDate.HHmm}';
  }

  Widget _buildFinancePresenceBadge(
    BuildContext context, {
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 10.0, color: color),
          Gap.w4,
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActivityFinanceBadges(BuildContext context) {
    final badges = <Widget>[];

    if (approval.hasRevenueAttachments) {
      final count = approval.revenueCount;
      badges.add(
        _buildFinancePresenceBadge(
          context,
          label: count > 0
              ? '${context.l10n.admin_revenue_title} ($count)'
              : context.l10n.admin_revenue_title,
          color: AppColors.success.shade700,
          icon: AppIcons.revenue,
        ),
      );
    }

    if (approval.hasExpenseAttachments) {
      final count = approval.expenseCount;
      badges.add(
        _buildFinancePresenceBadge(
          context,
          label: count > 0
              ? '${context.l10n.operationsItem_add_expense_title} ($count)'
              : context.l10n.operationsItem_add_expense_title,
          color: AppColors.error.shade700,
          icon: AppIcons.expense,
        ),
      );
    }

    return badges;
  }

  @override
  Widget build(BuildContext context) {
    final overall = _overallStatus(approval.approvers);
    final bool isMinePending = approval.approvers.any(
      (ap) =>
          ap.status == ApprovalStatus.unconfirmed &&
          ap.membership?.id == currentMembershipId,
    );

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
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  FaIcon(_leadingIcon(), size: 14.0, color: _leadingColor()),
                  Gap.w6,
                  Text(
                    _primaryLabel(context),
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _leadingColor(),
                    ),
                  ),
                ],
              ),
              if (approval.isActivity &&
                  (approval.hasRevenueAttachments ||
                      approval.hasExpenseAttachments)) ...[
                Gap.h8,
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: _buildActivityFinanceBadges(context),
                ),
              ],
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
                      approval.subtitle ?? context.l10n.lbl_unknown,
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
                    _timestampText(context),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Gap.h6,
              _buildApproverSummary(context),
              Gap.h8,
              if (overall == ApprovalStatus.unconfirmed) ...[
                if (!isMinePending)
                  ApprovalStatusPill(status: ApprovalStatus.unconfirmed),
                if (isMinePending) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _ActionIconButton(
                          icon: AppIcons.close,
                          color: AppColors.error.shade500,
                          onTap: onReject,
                          isLoading: isLoading,
                        ),
                      ),
                      Gap.w8,
                      Expanded(
                        child: _ActionIconButton(
                          icon: AppIcons.approve,
                          color: AppColors.success.shade600,
                          onTap: onApprove,
                          isLoading: isLoading,
                        ),
                      ),
                    ],
                  ),
                ],
              ] else ...[
                ApprovalStatusPill(status: overall),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApproverSummary(BuildContext context) {
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
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = isLoading
        ? color.withValues(alpha: 0.42)
        : color;
    final effectiveOverlayColor = isLoading
        ? Colors.transparent
        : color.withValues(alpha: 0.12);
    final effectiveBackgroundColor = isLoading
        ? AppColors.surfaceContainerLowest.withValues(alpha: 0.72)
        : AppColors.surfaceContainerLowest;

    return Material(
      borderRadius: BorderRadius.circular(8.0),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: isLoading ? null : onTap,
        overlayColor: WidgetStateProperty.all(effectiveOverlayColor),
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            border: Border.all(color: effectiveBorderColor),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
          ),
          child: Center(
            child: LoadingActionContent(
              isLoading: isLoading,
              loaderSize: 14.0,
              loaderBaseColor: color.withValues(alpha: 0.28),
              loaderHighlightColor: color,
              loaderBackgroundColor: AppColors.surface,
              loaderBorderColor: color.withValues(alpha: 0.16),
              child: FaIcon(icon, size: 18.0, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
