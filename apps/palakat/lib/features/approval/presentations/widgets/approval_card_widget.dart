import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/extensions.dart';
import 'package:palakat_shared/models.dart' hide Column;
import 'package:palakat/features/approval/presentations/widgets/approval_status_pill.dart';
import 'package:palakat/features/approval/presentations/widgets/approver_chip.dart';

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
      elevation: 2,
      shadowColor: AppColors.onSurface,
      surfaceTintColor: AppColors.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: _getStatusBorderColor(overall), width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Activity type and financial badges row
              LayoutBuilder(
                builder: (context, constraints) {
                  final shouldStackHeader =
                      constraints.maxWidth < 360 ||
                      MediaQuery.textScalerOf(context).scale(1) > 1.1;
                  final badgeGroup = Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      _ActivityTypeBadge(activityType: approval.activityType),
                      if (hasFinancial)
                        _FinancialIndicatorBadge(isRevenue: isRevenue),
                    ],
                  );

                  if (shouldStackHeader) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        badgeGroup,
                        Gap.h8,
                        Align(
                          alignment: Alignment.centerRight,
                          child: FaIcon(
                            AppIcons.forward,
                            size: 24.0,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: badgeGroup),
                      Gap.w8,
                      FaIcon(
                        AppIcons.forward,
                        size: 24.0,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ],
                  );
                },
              ),
              Gap.h8,
              // Title row
              Text(
                approval.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              Gap.h12,
              // Supervisor and date info
              LayoutBuilder(
                builder: (context, constraints) {
                  final shouldStackInfo =
                      constraints.maxWidth < 380 ||
                      MediaQuery.textScalerOf(context).scale(1) > 1.1;
                  final supervisorInfo = Row(
                    children: [
                      Container(
                        width: 32.0,
                        height: 32.0,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: FaIcon(
                          AppIcons.person,
                          size: 16.0,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      Gap.w8,
                      Expanded(
                        child: Text(
                          approval.supervisor.account?.name ??
                              context.l10n.lbl_unknown,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                          maxLines: shouldStackInfo ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                  final dateInfo = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        AppIcons.time,
                        size: 18.0,
                        color: AppColors.onSurfaceVariant,
                      ),
                      Gap.w6,
                      Flexible(
                        child: Text(
                          "${approval.createdAt.slashDate} ${approval.createdAt.HHmm}",
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: AppColors.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );

                  if (shouldStackInfo) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        supervisorInfo,
                        Gap.h8,
                        Padding(
                          padding: EdgeInsets.only(left: 40.0),
                          child: dateInfo,
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: supervisorInfo),
                      Gap.w12,
                      Flexible(child: dateInfo),
                    ],
                  );
                },
              ),
              // Approvers list
              if (approval.approvers.isNotEmpty) ...[
                Gap.h12,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: approval.approvers.map((ap) {
                    final name = ap.membership?.account?.name ?? '-';
                    // Check if this approver is the current user by membershipId
                    final approverMembershipId =
                        ap.membershipId ?? ap.membership?.id;
                    final isCurrentUser =
                        currentMembershipId != null &&
                        approverMembershipId != null &&
                        approverMembershipId == currentMembershipId;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 6.0),
                      child: ApproverChip(
                        name: name,
                        status: ap.status,
                        updatedAt: ap.updatedAt,
                        isCurrentUser: isCurrentUser,
                      ),
                    );
                  }).toList(),
                ),
              ],
              Gap.h12,
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
                        Gap.w12,
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
}

/// Badge widget for displaying activity type
class _ActivityTypeBadge extends StatelessWidget {
  const _ActivityTypeBadge({required this.activityType});

  final ActivityType activityType;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String label;

    switch (activityType) {
      case ActivityType.service:
        backgroundColor = AppColors.primary.shade100;
        textColor = AppColors.primary.shade700;
        icon = AppIcons.church;
        label = l10n.activityType_service;
        break;
      case ActivityType.event:
        backgroundColor = AppColors.primary.shade100;
        textColor = AppColors.primary.shade700;
        icon = AppIcons.event;
        label = l10n.activityType_event;
        break;
      case ActivityType.announcement:
        backgroundColor = AppColors.warning.shade100;
        textColor = AppColors.warning.shade700;
        icon = AppIcons.announcement;
        label = l10n.activityType_announcement;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: textColor.withValues(alpha: 0.18)),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 18.0, color: textColor),
          Gap.w6,
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge widget for displaying financial indicator (revenue/expense)
class _FinancialIndicatorBadge extends StatelessWidget {
  const _FinancialIndicatorBadge({required this.isRevenue});

  final bool isRevenue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final backgroundColor = isRevenue
        ? AppColors.success.shade100
        : AppColors.error.shade100;
    final textColor = isRevenue
        ? AppColors.success.shade700
        : AppColors.error.shade700;
    final icon = isRevenue ? AppIcons.revenue : AppIcons.expense;
    final label = isRevenue
        ? l10n.admin_revenue_title
        : l10n.operationsItem_add_expense_title;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: textColor.withValues(alpha: 0.18)),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 18.0, color: textColor),
          Gap.w6,
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
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
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
          ),
          child: Center(child: FaIcon(icon, size: 22.0, color: color)),
        ),
      ),
    );
  }
}
