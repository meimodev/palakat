import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/approval/presentations/approval_motion_widget.dart';
import 'package:palakat/features/approval/presentations/widgets/approval_confirmation_bottom_sheet.dart';
import 'package:palakat/features/approval/presentations/widgets/approval_status_pill.dart';
import 'package:palakat/features/approval/presentations/widgets/approver_chip.dart';
import 'package:palakat/features/approval/presentations/approval_detail_controller.dart';
import 'package:palakat/features/finance/presentations/finance_create/widgets/currency_input_widget.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

/// Approval Detail Screen - Redesigned layout per Requirements 4.1-4.4
///
/// Section order:
/// 1. Header section with activity title and type badge (Req 4.1)
/// 2. Approval section with approvers and status badges (Req 4.2)
/// 3. Activity summary section - supervisor, date, description (Req 4.3)
/// 4. Financial section - when hasRevenue or hasExpense is true (Req 4.4)
/// 5. Location section (conditional)
/// 6. Notes section (conditional)
/// 7. Action bar for pending approvers
class ApprovalDetailScreen extends ConsumerWidget {
  const ApprovalDetailScreen({
    super.key,
    required this.activityId,
    this.currentMembershipId,
  });

  final int activityId;
  final int? currentMembershipId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(
      approvalDetailControllerProvider(activityId: activityId).notifier,
    );
    final detailState = ref.watch(
      approvalDetailControllerProvider(activityId: activityId),
    );
    final activity = detailState.activity;
    final isActionLoading = detailState.isActionLoading;

    final overall = activity != null
        ? _getOverallStatus(activity.approvers)
        : null;

    // Find the pending approver for the current user (Req 5.1, 5.2)
    final pendingApprover = activity?.approvers.firstWhere(
      (ap) =>
          ap.status == ApprovalStatus.unconfirmed &&
          ap.membership?.id == currentMembershipId,
      orElse: () => const Approver(
        id: -1,
        status: ApprovalStatus.approved,
        createdAt: null,
        updatedAt: null,
      ),
    );

    final bool isMinePending =
        pendingApprover != null &&
        pendingApprover.id != null &&
        pendingApprover.id != -1;

    // Build action buttons only for pending approvers (Req 5.1, 5.2)
    Widget? actionButtons;
    if (overall == ApprovalStatus.unconfirmed && isMinePending) {
      actionButtons = _buildActionButtons(
        context,
        ref,
        pendingApprover.id!, // Safe to use ! since we checked id != null above
        isActionLoading,
        activity!.title,
      );
    }

    return ScaffoldWidget(
      persistBottomWidget: actionButtons,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ApprovalReveal(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: FaIcon(
                    AppIcons.back,
                    size: 24.0,
                    color: AppColors.primary,
                  ),
                ),
                Gap.w8,
                Expanded(
                  child: Text(
                    l10n.approvalDetail_title,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Gap.h16,
          LoadingWrapper(
            loading: detailState.loadingScreen,
            hasError:
                detailState.errorMessage != null &&
                detailState.loadingScreen == false,
            errorMessage: detailState.errorMessage,
            onRetry: () => controller.fetch(activityId),
            shimmerPlaceholder: Column(
              children: [
                PalakatShimmerPlaceholders.infoCard(),
                Gap.h12,
                PalakatShimmerPlaceholders.infoCard(),
                Gap.h12,
                PalakatShimmerPlaceholders.approvalCard(),
              ],
            ),
            child: activity == null
                ? ApprovalAnimatedPresence(
                    visible: true,
                    child: InfoBoxWidget(message: l10n.approvalDetail_notFound),
                  )
                : _buildActivityDetails(context, ref, activity),
          ),
        ],
      ),
    );
  }

  /// Builds the activity details with reorganized sections per Requirements 4.1-4.4
  Widget _buildActivityDetails(
    BuildContext context,
    WidgetRef ref,
    Activity activity,
  ) {
    final l10n = context.l10n;
    final overall = _getOverallStatus(activity.approvers);
    final bool isMinePending = activity.approvers.any(
      (ap) =>
          ap.status == ApprovalStatus.unconfirmed &&
          ap.membership?.id == currentMembershipId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ApprovalReveal(
          delay: const Duration(milliseconds: 40),
          child: _buildHeaderSection(context, activity),
        ),
        Gap.h12,
        ApprovalReveal(
          delay: const Duration(milliseconds: 80),
          child: _buildApproversCard(context, activity),
        ),
        Gap.h12,
        ApprovalReveal(
          delay: const Duration(milliseconds: 120),
          child: _buildActivitySummaryCard(context, activity),
        ),
        if (activity.hasRevenue == true || activity.hasExpense == true) ...[
          Gap.h12,
          ApprovalReveal(
            delay: const Duration(milliseconds: 160),
            child: _buildFinancialCard(context, activity),
          ),
        ],
        if (activity.location != null) ...[
          Gap.h12,
          ApprovalReveal(
            delay: const Duration(milliseconds: 200),
            child: _buildLocationCard(context, activity),
          ),
        ],
        if (activity.note?.trim().isNotEmpty ?? false) ...[
          Gap.h12,
          ApprovalReveal(
            delay: const Duration(milliseconds: 240),
            child: _buildNoteCard(context, activity),
          ),
        ],
        if (overall == ApprovalStatus.unconfirmed &&
            activity.approvers.any(
              (ap) =>
                  ap.status == ApprovalStatus.approved &&
                  ap.membership?.id == currentMembershipId,
            )) ...[
          Gap.h12,
          ApprovalReveal(
            delay: const Duration(milliseconds: 280),
            child: InfoBoxWidget(message: l10n.approvalDetail_waitingOthers),
          ),
        ],
        Gap.h12,
        if (overall == ApprovalStatus.unconfirmed) ...[
          if (!isMinePending)
            ApprovalReveal(
              delay: const Duration(milliseconds: 300),
              child: ApprovalStatusPill(status: overall),
            ),
          if (!isMinePending) Gap.h8,
        ] else ...[
          ApprovalReveal(
            delay: const Duration(milliseconds: 300),
            child: ApprovalStatusPill(status: overall),
          ),
        ],
        Gap.h16,
        ApprovalReveal(
          delay: const Duration(milliseconds: 340),
          child: _buildViewActivityDetailsButton(context, activity),
        ),
      ],
    );
  }

  ApprovalStatus _getOverallStatus(List<Approver> items) {
    final hasRejected = items.any((e) => e.status == ApprovalStatus.rejected);
    if (hasRejected) return ApprovalStatus.rejected;
    final hasUnconfirmed = items.any(
      (e) => e.status == ApprovalStatus.unconfirmed,
    );
    if (hasUnconfirmed) return ApprovalStatus.unconfirmed;
    return ApprovalStatus.approved;
  }

  /// Builds the action buttons for approve/reject
  /// Requirements: 5.1, 5.2, 5.3, 5.4, 5.5
  /// - Show buttons only for pending approvers (Req 5.1)
  /// - Hide buttons when user is not a pending approver (Req 5.2)
  /// - Navigate back after action (Req 5.3, 5.4)
  /// - Show loading state with disabled buttons (Req 5.5)
  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    int approverId,
    bool isLoading,
    String activityTitle,
  ) {
    final l10n = context.l10n;
    final controller = ref.read(
      approvalDetailControllerProvider(activityId: activityId).notifier,
    );

    return Material(
      key: const Key('action_buttons_container'),
      color: AppColors.surfaceContainerLowest,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shouldStack =
              constraints.maxWidth < 420 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.1;

          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.neutral, width: 1),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            child: SafeArea(
              top: false,
              child: shouldStack
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildActionButton(
                          context: context,
                          key: const Key('reject_button'),
                          text: l10n.btn_reject,
                          icon: AppIcons.close,
                          color: AppColors.error.shade500,
                          isLoading: isLoading,
                          onTap: () async {
                            final confirmed =
                                await showApprovalConfirmationBottomSheet(
                                  context: context,
                                  isApprove: false,
                                  activityTitle: activityTitle,
                                );
                            if (confirmed != true || !context.mounted) return;

                            final success = await controller.rejectActivity(
                              approverId,
                            );
                            if (success && context.mounted) {
                              context.pop(true);
                            }
                          },
                        ),
                        Gap.h12,
                        _buildActionButton(
                          context: context,
                          key: const Key('approve_button'),
                          text: l10n.btn_approve,
                          icon: AppIcons.approve,
                          color: AppColors.success.shade600,
                          isLoading: isLoading,
                          onTap: () async {
                            final confirmed =
                                await showApprovalConfirmationBottomSheet(
                                  context: context,
                                  isApprove: true,
                                  activityTitle: activityTitle,
                                );
                            if (confirmed != true || !context.mounted) return;

                            final success = await controller.approveActivity(
                              approverId,
                            );
                            if (success && context.mounted) {
                              context.pop(true);
                            }
                          },
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            key: const Key('reject_button'),
                            text: l10n.btn_reject,
                            icon: AppIcons.close,
                            color: AppColors.error.shade500,
                            isLoading: isLoading,
                            onTap: () async {
                              final confirmed =
                                  await showApprovalConfirmationBottomSheet(
                                    context: context,
                                    isApprove: false,
                                    activityTitle: activityTitle,
                                  );
                              if (confirmed != true || !context.mounted) return;

                              final success = await controller.rejectActivity(
                                approverId,
                              );
                              if (success && context.mounted) {
                                context.pop(true);
                              }
                            },
                          ),
                        ),
                        Gap.w12,
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            key: const Key('approve_button'),
                            text: l10n.btn_approve,
                            icon: AppIcons.approve,
                            color: AppColors.success.shade600,
                            isLoading: isLoading,
                            onTap: () async {
                              final confirmed =
                                  await showApprovalConfirmationBottomSheet(
                                    context: context,
                                    isApprove: true,
                                    activityTitle: activityTitle,
                                  );
                              if (confirmed != true || !context.mounted) return;

                              final success = await controller.approveActivity(
                                approverId,
                              );
                              if (success && context.mounted) {
                                context.pop(true);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required Widget leading,
    required Widget title,
    Widget? trailing,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldStack =
            constraints.maxWidth < 380 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.1;

        if (shouldStack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  leading,
                  Gap.w12,
                  Expanded(child: title),
                ],
              ),
              if (trailing != null) ...[
                Gap.h12,
                Align(alignment: Alignment.centerLeft, child: trailing),
              ],
            ],
          );
        }

        return Row(
          children: [
            leading,
            Gap.w12,
            Expanded(child: title),
            if (trailing != null) trailing,
          ],
        );
      },
    );
  }

  /// Helper method to build action buttons with Font Awesome icons
  Widget _buildActionButton({
    required BuildContext context,
    required Key key,
    required String text,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Material(
      key: key,
      borderRadius: BorderRadius.circular(8.0),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: isLoading ? null : onTap,
        overlayColor: WidgetStateProperty.all(color.withValues(alpha: 0.12)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
          ),
          child: isLoading
              ? Center(
                  child: CompactLoadingWidget(
                    size: 18.0,
                    baseColor: color.withValues(alpha: 0.24),
                    highlightColor: AppColors.surface,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(icon, size: 18.0, color: color),
                    Gap.w8,
                    Text(
                      text,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Builds the header section with activity title and type badge
  /// Requirements: 4.1
  Widget _buildHeaderSection(BuildContext context, Activity activity) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: AppColors.surfaceContainerLowest,
      elevation: 2,
      shadowColor: AppColors.onSurface,
      surfaceTintColor: AppColors.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(
              context: context,
              leading: Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.onSecondaryContainer.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  AppIcons.event,
                  size: 24.0,
                  color: AppColors.onSecondaryContainer,
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap.h4,
                  Text(
                    '${context.l10n.lbl_activityId}: #${activity.id}',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Gap.h12,
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildActivityTypeBadge(context, activity.activityType),
                if (activity.bipra != null)
                  _buildBipraBadge(context, activity.bipra!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the approvers card with prominent status badges
  /// Requirements: 4.2
  Widget _buildApproversCard(BuildContext context, Activity activity) {
    final l10n = context.l10n;
    return Material(
      clipBehavior: Clip.hardEdge,
      color: AppColors.surfaceContainerLowest,
      elevation: 2,
      shadowColor: AppColors.onSurface,
      surfaceTintColor: AppColors.success,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(
              context: context,
              leading: Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: AppColors.success.shade100,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.16),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  AppIcons.approval,
                  size: 20.0,
                  color: AppColors.success.shade700,
                ),
              ),
              title: Text(
                l10n.tbl_approvers,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: AppColors.success.shade100,
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: AppColors.success.shade200, width: 1),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 6),
                ),
                child: Text(
                  activity.approvers.length.toString(),
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: AppColors.success.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Gap.h16,
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: activity.approvers.map((ap) {
                final name = ap.membership?.account?.name ?? l10n.lbl_unknown;
                // Check if this approver is the current user by membershipId
                final approverMembershipId =
                    ap.membershipId ?? ap.membership?.id;
                final isCurrentUser =
                    currentMembershipId != null &&
                    approverMembershipId != null &&
                    approverMembershipId == currentMembershipId;
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
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
        ),
      ),
    );
  }

  /// Builds the activity summary card with supervisor, date, and description
  /// Requirements: 4.3
  Widget _buildActivitySummaryCard(BuildContext context, Activity activity) {
    final l10n = context.l10n;
    return Material(
      clipBehavior: Clip.hardEdge,
      color: AppColors.surfaceContainerLowest,
      elevation: 1,
      shadowColor: AppColors.onSurface,
      surfaceTintColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(
              context: context,
              leading: Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  AppIcons.info,
                  size: 20.0,
                  color: AppColors.onPrimary,
                ),
              ),
              title: Text(
                l10n.approvalDetail_activitySummary_title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Gap.h16,
            // Supervisor info
            _buildInfoRow(
              icon: AppIcons.person,
              iconColor: AppColors.primary.shade600,
              label: l10n.tbl_supervisor,
              value: activity.supervisor.account?.name ?? l10n.lbl_unknown,
            ),
            Gap.h12,
            // Date info
            _buildInfoRow(
              icon: AppIcons.time,
              iconColor: AppColors.warning.shade600,
              label: l10n.lbl_date,
              value: (() {
                final dt = activity.date;
                return "${dt.EEEEddMMMyyyy} ${dt.HHmm}";
              })(),
            ),
            Gap.h12,
            // Created at
            _buildInfoRow(
              icon: AppIcons.createdAt,
              iconColor: AppColors.onSurfaceVariant,
              label: l10n.lbl_createdAt,
              value: (() {
                final dt = activity.createdAt;
                return "${dt.EEEEddMMMyyyy} ${dt.HHmm} • ${dt.toFromNow}";
              })(),
            ),
            if (activity.description?.isNotEmpty ?? false) ...[
              Gap.h12,
              _buildInfoRow(
                icon: AppIcons.description,
                iconColor: AppColors.primary,
                label: l10n.lbl_description,
                value: activity.description!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the financial data card showing revenue/expense details
  /// Requirements: 4.4
  /// **Feature: approval-card-detail-redesign, Property 3: Financial section visibility matches financial data presence**
  Widget _buildFinancialCard(BuildContext context, Activity activity) {
    final l10n = context.l10n;
    final isRevenue = activity.hasRevenue == true;
    final financeData = isRevenue ? activity.revenue : activity.expense;
    final financeType = isRevenue
        ? l10n.financeType_revenue
        : l10n.financeType_expense;
    final baseColor = isRevenue ? AppColors.success : AppColors.error;

    return Material(
      key: const Key('financial_section'),
      clipBehavior: Clip.hardEdge,
      color: AppColors.surfaceContainerLowest,
      elevation: 1,
      shadowColor: AppColors.onSurface,
      surfaceTintColor: baseColor[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(
              context: context,
              leading: Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: baseColor[100],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: baseColor[200]!.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  isRevenue ? AppIcons.revenue : AppIcons.expense,
                  size: 20.0,
                  color: baseColor[700],
                ),
              ),
              title: Text(
                l10n.approvalDetail_financialData_title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: baseColor[50],
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: baseColor[200]!, width: 1),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 6),
                ),
                child: Text(
                  financeType,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: baseColor[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Gap.h16,
            // Amount
            _buildInfoRow(
              icon: AppIcons.money,
              iconColor: baseColor.shade600,
              label: l10n.lbl_amount,
              value: financeData?.amount != null
                  ? formatRupiah(financeData!.amount!)
                  : '-',
            ),
            Gap.h12,
            // Account Number
            _buildInfoRow(
              icon: AppIcons.bankAccount,
              iconColor: AppColors.primary.shade600,
              label: l10n.lbl_accountNumber,
              value:
                  financeData?.financialAccountNumber?.accountNumber ??
                  financeData?.accountNumber ??
                  '-',
            ),
            if (financeData?.financialAccountNumber?.description != null) ...[
              Gap.h12,
              _buildInfoRow(
                icon: AppIcons.description,
                iconColor: AppColors.tertiary,
                label: l10n.approvalDetail_accountDescription_label,
                value: financeData!.financialAccountNumber!.description!,
              ),
            ],
            Gap.h12,
            // Payment Method
            _buildInfoRow(
              icon: AppIcons.payment,
              iconColor: AppColors.primary,
              label: l10n.tbl_paymentMethod,
              value: (() {
                final method = financeData?.paymentMethod;
                if (method == null || method.isEmpty) return '-';
                switch (method) {
                  case 'CASH':
                    return l10n.paymentMethod_cash;
                  case 'CASHLESS':
                    return l10n.paymentMethod_cashless;
                  default:
                    return method.toCamelCase;
                }
              })(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, Activity activity) {
    final l10n = context.l10n;
    final location = activity.location;
    final hasCoordinates =
        location?.latitude != null && location?.longitude != null;
    final displayName = (location?.name.trim().isNotEmpty ?? false)
        ? location!.name
        : hasCoordinates
        ? "${location!.latitude!.toStringAsFixed(5)}, ${location.longitude!.toStringAsFixed(5)}"
        : '-';

    return Material(
      clipBehavior: Clip.hardEdge,
      color: AppColors.surfaceContainerLowest,
      elevation: 1,
      shadowColor: AppColors.onSurface,
      surfaceTintColor: AppColors.error,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(
              context: context,
              leading: Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  AppIcons.mapPin,
                  size: 20.0,
                  color: AppColors.error,
                ),
              ),
              title: Text(
                l10n.card_location_title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              trailing: location != null
                  ? IconButton(
                      tooltip: l10n.approvalDetail_viewOnMapTooltip,
                      onPressed: () {
                        context.pushNamed(
                          AppRoute.publishingMap,
                          extra: RouteParam(
                            params: {
                              RouteParamKey.mapOperationType:
                                  MapOperationType.read,
                              RouteParamKey.location: location.toJson(),
                            },
                          ),
                        );
                      },
                      icon: FaIcon(
                        AppIcons.map,
                        size: 20.0,
                        color: AppColors.primary,
                      ),
                      style: ButtonStyle(
                        overlayColor: WidgetStateProperty.all(
                          AppColors.primary.withValues(alpha: 0.12),
                        ),
                      ),
                    )
                  : null,
            ),
            Gap.h16,
            _buildInfoRow(
              icon: AppIcons.location,
              iconColor: AppColors.error.shade500,
              label: l10n.lbl_address,
              value: displayName,
            ),
            if (hasCoordinates) ...[
              Gap.h12,
              _buildInfoRow(
                icon: AppIcons.coordinates,
                iconColor: AppColors.primary.shade500,
                label: l10n.lbl_coordinates,
                value:
                    "${location!.latitude!.toStringAsFixed(5)}, ${location.longitude!.toStringAsFixed(5)}",
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Activity activity) {
    final l10n = context.l10n;
    return Material(
      clipBehavior: Clip.hardEdge,
      color: AppColors.surfaceContainerLowest,
      elevation: 1,
      shadowColor: AppColors.onSurface,
      surfaceTintColor: AppColors.warning,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: AppColors.warning.shade100,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.warning.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    AppIcons.notes,
                    size: 20.0,
                    color: AppColors.warning.shade700,
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    l10n.lbl_note,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            Gap.h16,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  AppIcons.notes,
                  size: 20.0,
                  color: AppColors.warning.shade600,
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    activity.note ?? "-",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldStack =
            constraints.maxWidth < 340 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.1;

        if (shouldStack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FaIcon(icon, size: 20.0, color: iconColor),
                  Gap.w12,
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Gap.h8,
              Padding(
                padding: EdgeInsets.only(left: 32.0),
                child: Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: AppColors.onSurface),
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FaIcon(icon, size: 20.0, color: iconColor),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap.h4,
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActivityTypeBadge(BuildContext context, ActivityType type) {
    final Color baseColor = type == ActivityType.announcement
        ? AppColors.warning.shade600
        : (type == ActivityType.event
              ? AppColors.success.shade600
              : AppColors.primary.shade600);

    final IconData iconData = type == ActivityType.announcement
        ? AppIcons.announcement
        : (type == ActivityType.event ? AppIcons.event : AppIcons.info);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1),
        border: Border.all(color: baseColor.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(iconData, size: 14.0, color: baseColor),
          Gap.w6,
          Text(
            type.displayName,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: baseColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBipraBadge(BuildContext context, Bipra bipra) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 6),
      ),
      child: Text(
        bipra.name,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Builds the "View Activity Details" button
  /// Requirements: 6.1, 6.2
  /// - Display a link/button to view full activity details (Req 6.1)
  /// - Navigate to activity detail screen with read-only context (Req 6.2)
  Widget _buildViewActivityDetailsButton(
    BuildContext context,
    Activity activity,
  ) {
    final l10n = context.l10n;
    return Material(
      key: const Key('view_activity_details_button'),
      clipBehavior: Clip.hardEdge,
      color: AppColors.surfaceContainerLowest,
      elevation: 1,
      shadowColor: AppColors.onSurface,
      surfaceTintColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        onTap: () {
          // Navigate to activity detail with read-only context flag (Req 6.2)
          context.pushNamed(
            AppRoute.activityDetail,
            pathParameters: {'activityId': activity.id.toString()},
            extra: RouteParam(
              params: {RouteParamKey.isFromApprovalContext: true},
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  AppIcons.openExternal,
                  size: 20.0,
                  color: AppColors.onPrimary,
                ),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.approvalDetail_viewActivityDetails_title,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      l10n.approvalDetail_viewActivityDetails_subtitle,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FaIcon(AppIcons.forward, size: 24.0, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
