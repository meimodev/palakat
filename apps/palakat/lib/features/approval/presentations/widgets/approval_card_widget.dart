import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';
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
        return BaseColor.green.shade50;
      case ApprovalStatus.rejected:
        return BaseColor.red.shade50;
      case ApprovalStatus.unconfirmed:
        return BaseColor.yellow.shade50;
    }
  }

  /// Returns the border color based on overall approval status
  Color _getStatusBorderColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.approved:
        return BaseColor.green.shade200;
      case ApprovalStatus.rejected:
        return BaseColor.red.shade200;
      case ApprovalStatus.unconfirmed:
        return BaseColor.yellow.shade200;
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
      shadowColor: Colors.black.withValues(alpha: 0.08),
      surfaceTintColor: BaseColor.teal[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _getStatusBorderColor(overall), width: 1.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Activity type and financial badges row
              Row(
                children: [
                  _ActivityTypeBadge(activityType: approval.activityType),
                  if (hasFinancial) ...[
                    Gap.w8,
                    _FinancialIndicatorBadge(isRevenue: isRevenue),
                  ],
                  const Spacer(),
                  FaIcon(
                    AppIcons.forward,
                    size: BaseSize.w24,
                    color: BaseColor.secondaryText,
                  ),
                ],
              ),
              Gap.h8,
              // Title row
              Text(
                approval.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: BaseTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: BaseColor.black,
                ),
              ),
              Gap.h12,
              // Supervisor and date info
              Row(
                children: [
                  Container(
                    width: BaseSize.w32,
                    height: BaseSize.w32,
                    decoration: BoxDecoration(
                      color: BaseColor.blue[100],
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: FaIcon(
                      AppIcons.person,
                      size: BaseSize.w16,
                      color: BaseColor.blue[700],
                    ),
                  ),
                  Gap.w8,
                  Expanded(
                    child: Text(
                      approval.supervisor.account?.name ??
                          context.l10n.lbl_unknown,
                      style: BaseTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Gap.w12,
                  FaIcon(
                    AppIcons.time,
                    size: BaseSize.w16,
                    color: BaseColor.secondaryText,
                  ),
                  Gap.w4,
                  Text(
                    "${approval.createdAt.slashDate} ${approval.createdAt.HHmm}",
                    style: BaseTypography.bodySmall.copyWith(
                      color: BaseColor.secondaryText,
                    ),
                  ),
                ],
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
                      padding: EdgeInsets.only(bottom: BaseSize.h6),
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
                      child: SizedBox(
                        width: BaseSize.w24,
                        height: BaseSize.w24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: BaseColor.teal.shade500,
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _ActionIconButton(
                            icon: AppIcons.close,
                            color: BaseColor.red.shade500,
                            onTap: onReject,
                          ),
                        ),
                        Gap.w12,
                        Expanded(
                          child: _ActionIconButton(
                            icon: AppIcons.approve,
                            color: BaseColor.green.shade600,
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
        backgroundColor = BaseColor.blue.shade100;
        textColor = BaseColor.blue.shade700;
        icon = AppIcons.church;
        label = l10n.activityType_service;
        break;
      case ActivityType.event:
        backgroundColor = BaseColor.teal.shade100;
        textColor = BaseColor.teal.shade700;
        icon = AppIcons.event;
        label = l10n.activityType_event;
        break;
      case ActivityType.announcement:
        backgroundColor = BaseColor.yellow.shade100;
        textColor = BaseColor.yellow.shade700;
        icon = AppIcons.announcement;
        label = l10n.activityType_announcement;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w8,
        vertical: BaseSize.h4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: BaseSize.w14, color: textColor),
          Gap.w4,
          Text(
            label,
            style: BaseTypography.labelSmall.copyWith(
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
        ? BaseColor.green.shade100
        : BaseColor.red.shade100;
    final textColor = isRevenue
        ? BaseColor.green.shade700
        : BaseColor.red.shade700;
    final icon = isRevenue ? AppIcons.revenue : AppIcons.expense;
    final label = isRevenue ? l10n.admin_revenue_title : l10n.operationsItem_add_expense_title;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w8,
        vertical: BaseSize.h4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: BaseSize.w14, color: textColor),
          Gap.w4,
          Text(
            label,
            style: BaseTypography.labelSmall.copyWith(
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
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        onTap: onTap,
        overlayColor: WidgetStateProperty.all(color.withValues(alpha: 0.12)),
        child: Container(
          padding: EdgeInsets.all(BaseSize.w8),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          ),
          child: Center(
            child: FaIcon(icon, size: BaseSize.w20, color: color),
          ),
        ),
      ),
    );
  }
}
