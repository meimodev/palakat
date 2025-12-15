import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
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
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: FaIcon(
                  AppIcons.back,
                  size: BaseSize.w24,
                  color: BaseColor.primary3,
                ),
              ),
              Gap.w8,
              Expanded(
                child: Text(
                  l10n.approvalDetail_title,
                  style: BaseTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: BaseColor.primaryText,
                  ),
                ),
              ),
            ],
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
                ? InfoBoxWidget(message: l10n.approvalDetail_notFound)
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
        // Section 1: Header with activity title and type badge (Req 4.1)
        _buildHeaderSection(context, activity),
        Gap.h12,
        // Section 2: Approval section with approvers and status badges (Req 4.2)
        _buildApproversCard(context, activity),
        Gap.h12,
        // Section 3: Activity summary - supervisor, date, description (Req 4.3)
        _buildActivitySummaryCard(context, activity),
        // Section 4: Financial section when hasRevenue or hasExpense is true (Req 4.4)
        // **Feature: approval-card-detail-redesign, Property 3: Financial section visibility matches financial data presence**
        if (activity.hasRevenue == true || activity.hasExpense == true) ...[
          Gap.h12,
          _buildFinancialCard(context, activity),
        ],
        if (activity.location != null) ...[
          Gap.h12,
          _buildLocationCard(context, activity),
        ],
        if (activity.note?.trim().isNotEmpty ?? false) ...[
          Gap.h12,
          _buildNoteCard(context, activity),
        ],
        if (overall == ApprovalStatus.unconfirmed &&
            activity.approvers.any(
              (ap) =>
                  ap.status == ApprovalStatus.approved &&
                  ap.membership?.id == currentMembershipId,
            )) ...[
          Gap.h12,
          InfoBoxWidget(message: l10n.approvalDetail_waitingOthers),
        ],
        Gap.h12,
        if (overall == ApprovalStatus.unconfirmed) ...[
          if (!isMinePending) ApprovalStatusPill(status: overall),
          if (!isMinePending) Gap.h8,
        ] else ...[
          ApprovalStatusPill(status: overall),
        ],
        // Section 8: View Activity Details button (Req 6.1, 6.2)
        Gap.h16,
        _buildViewActivityDetailsButton(context, activity),
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

    return Container(
      key: const Key('action_buttons_container'),
      decoration: BoxDecoration(
        color: BaseColor.white,
        border: Border(
          top: BorderSide(
            color: BaseColor.teal.shade600.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: BaseSize.h12,
        horizontal: BaseSize.w12,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _buildActionButton(
                key: const Key('reject_button'),
                text: l10n.btn_reject,
                icon: AppIcons.close,
                color: BaseColor.red.shade500,
                isLoading: isLoading,
                onTap: () async {
                  // Show confirmation bottom sheet
                  final confirmed = await showApprovalConfirmationBottomSheet(
                    context: context,
                    isApprove: false,
                    activityTitle: activityTitle,
                  );
                  if (confirmed != true || !context.mounted) return;

                  final success = await controller.rejectActivity(approverId);
                  if (success && context.mounted) {
                    context.pop(true); // Return true to indicate action taken
                  }
                },
              ),
            ),
            Gap.w12,
            Expanded(
              child: _buildActionButton(
                key: const Key('approve_button'),
                text: l10n.btn_approve,
                icon: AppIcons.approve,
                color: BaseColor.green.shade600,
                isLoading: isLoading,
                onTap: () async {
                  // Show confirmation bottom sheet
                  final confirmed = await showApprovalConfirmationBottomSheet(
                    context: context,
                    isApprove: true,
                    activityTitle: activityTitle,
                  );
                  if (confirmed != true || !context.mounted) return;

                  final success = await controller.approveActivity(approverId);
                  if (success && context.mounted) {
                    context.pop(true); // Return true to indicate action taken
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build action buttons with Font Awesome icons
  Widget _buildActionButton({
    required Key key,
    required String text,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Material(
      key: key,
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        onTap: isLoading ? null : onTap,
        overlayColor: WidgetStateProperty.all(color.withValues(alpha: 0.12)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.w24,
            vertical: BaseSize.h8,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          ),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    height: BaseSize.h18,
                    width: BaseSize.h18,
                    child: CircularProgressIndicator(color: color),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(icon, size: BaseSize.w18, color: color),
                    Gap.w8,
                    Text(
                      text,
                      style: BaseTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
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
      color: BaseColor.cardBackground1,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      surfaceTintColor: BaseColor.teal[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w48,
                  height: BaseSize.w48,
                  decoration: BoxDecoration(
                    color: BaseColor.teal[100],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: BaseColor.teal[200]!.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    AppIcons.event,
                    size: BaseSize.w24,
                    color: BaseColor.teal[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: BaseTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: BaseColor.black,
                        ),
                      ),
                      Gap.h4,
                      Text(
                        '${context.l10n.lbl_activityId}: #${activity.id}',
                        style: BaseTypography.bodySmall.copyWith(
                          color: BaseColor.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap.h12,
            Row(
              children: [
                _buildActivityTypeBadge(activity.activityType),
                Gap.w8,
                if (activity.bipra != null) _buildBipraBadge(activity.bipra!),
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
      color: BaseColor.cardBackground1,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      surfaceTintColor: BaseColor.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: BoxDecoration(
                    color: BaseColor.green[100],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: BaseColor.green[200]!.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    AppIcons.approval,
                    size: BaseSize.w20,
                    color: BaseColor.green[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    l10n.tbl_approvers,
                    style: BaseTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.black,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: BaseSize.w10,
                    vertical: BaseSize.h4,
                  ),
                  decoration: BoxDecoration(
                    color: BaseColor.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BaseColor.green[200]!, width: 1),
                  ),
                  child: Text(
                    activity.approvers.length.toString(),
                    style: BaseTypography.labelMedium.copyWith(
                      color: BaseColor.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
                  padding: EdgeInsets.only(bottom: BaseSize.h8),
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
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: BoxDecoration(
                    color: BaseColor.blue[100],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: BaseColor.blue[200]!.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    AppIcons.info,
                    size: BaseSize.w20,
                    color: BaseColor.blue[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    l10n.approvalDetail_activitySummary_title,
                    style: BaseTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.black,
                    ),
                  ),
                ),
              ],
            ),
            Gap.h16,
            // Supervisor info
            _buildInfoRow(
              icon: AppIcons.person,
              iconColor: BaseColor.blue.shade600,
              label: l10n.tbl_supervisor,
              value: activity.supervisor.account?.name ?? l10n.lbl_unknown,
            ),
            Gap.h12,
            // Date info
            _buildInfoRow(
              icon: AppIcons.time,
              iconColor: BaseColor.yellow.shade600,
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
              iconColor: BaseColor.neutral60,
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
                iconColor: BaseColor.teal.shade600,
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
    final baseColor = isRevenue ? BaseColor.green : BaseColor.red;

    return Material(
      key: const Key('financial_section'),
      clipBehavior: Clip.hardEdge,
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: baseColor[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
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
                    size: BaseSize.w20,
                    color: baseColor[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    l10n.approvalDetail_financialData_title,
                    style: BaseTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.black,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: BaseSize.w10,
                    vertical: BaseSize.h6,
                  ),
                  decoration: BoxDecoration(
                    color: baseColor[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: baseColor[200]!, width: 1),
                  ),
                  child: Text(
                    financeType,
                    style: BaseTypography.labelMedium.copyWith(
                      color: baseColor[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
              iconColor: BaseColor.blue.shade600,
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
                iconColor: BaseColor.neutral60,
                label: l10n.approvalDetail_accountDescription_label,
                value: financeData!.financialAccountNumber!.description!,
              ),
            ],
            Gap.h12,
            // Payment Method
            _buildInfoRow(
              icon: AppIcons.payment,
              iconColor: BaseColor.teal.shade600,
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
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.red[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: BoxDecoration(
                    color: BaseColor.red[100],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: BaseColor.red[200]!.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    AppIcons.mapPin,
                    size: BaseSize.w20,
                    color: BaseColor.red[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    l10n.card_location_title,
                    style: BaseTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.black,
                    ),
                  ),
                ),
                if (location != null)
                  IconButton(
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
                      size: BaseSize.w20,
                      color: BaseColor.primary3,
                    ),
                    style: ButtonStyle(
                      overlayColor: WidgetStateProperty.all(
                        BaseColor.primary2.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
              ],
            ),
            Gap.h16,
            _buildInfoRow(
              icon: AppIcons.location,
              iconColor: BaseColor.red.shade500,
              label: l10n.lbl_address,
              value: displayName,
            ),
            if (hasCoordinates) ...[
              Gap.h12,
              _buildInfoRow(
                icon: AppIcons.coordinates,
                iconColor: BaseColor.blue.shade500,
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
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.yellow[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: BoxDecoration(
                    color: BaseColor.yellow[100],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: BaseColor.yellow[200]!.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    AppIcons.notes,
                    size: BaseSize.w20,
                    color: BaseColor.yellow[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    l10n.lbl_note,
                    style: BaseTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.black,
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
                  size: BaseSize.w20,
                  color: BaseColor.yellow.shade600,
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    activity.note ?? "-",
                    style: BaseTypography.bodyMedium.copyWith(
                      color: BaseColor.black,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FaIcon(icon, size: BaseSize.w20, color: iconColor),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: BaseTypography.labelMedium.copyWith(
                  color: BaseColor.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap.h4,
              Text(
                value,
                style: BaseTypography.bodyMedium.copyWith(
                  color: BaseColor.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTypeBadge(ActivityType type) {
    final Color baseColor = type == ActivityType.announcement
        ? BaseColor.yellow.shade600
        : (type == ActivityType.event
              ? BaseColor.green.shade600
              : BaseColor.blue.shade600);

    final IconData iconData = type == ActivityType.announcement
        ? AppIcons.announcement
        : (type == ActivityType.event ? AppIcons.event : AppIcons.info);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w10,
        vertical: BaseSize.h6,
      ),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1),
        border: Border.all(color: baseColor.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(iconData, size: BaseSize.w14, color: baseColor),
          Gap.w6,
          Text(
            type.displayName,
            style: BaseTypography.labelMedium.copyWith(
              color: baseColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBipraBadge(Bipra bipra) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w10,
        vertical: BaseSize.h6,
      ),
      decoration: BoxDecoration(
        color: BaseColor.teal.shade50,
        border: Border.all(color: BaseColor.teal.shade200, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        bipra.name,
        style: BaseTypography.labelMedium.copyWith(
          color: BaseColor.teal.shade700,
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
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          padding: EdgeInsets.all(BaseSize.w16),
          child: Row(
            children: [
              Container(
                width: BaseSize.w40,
                height: BaseSize.w40,
                decoration: BoxDecoration(
                  color: BaseColor.blue[100],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: BaseColor.blue[200]!.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  AppIcons.openExternal,
                  size: BaseSize.w20,
                  color: BaseColor.blue[700],
                ),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.approvalDetail_viewActivityDetails_title,
                      style: BaseTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: BaseColor.blue[700],
                      ),
                    ),
                    Gap.h4,
                    Text(
                      l10n.approvalDetail_viewActivityDetails_subtitle,
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              FaIcon(
                AppIcons.forward,
                size: BaseSize.w24,
                color: BaseColor.blue[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
