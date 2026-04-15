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
import 'package:palakat/features/finance/presentations/finance_create/widgets/currency_input_widget.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:palakat_shared/extensions.dart';
import 'package:palakat_shared/models.dart' hide Column;

class FinanceApprovalDetailScreen extends ConsumerStatefulWidget {
  const FinanceApprovalDetailScreen({
    super.key,
    required this.financeId,
    required this.financeType,
    this.currentMembershipId,
    this.useGeneralFetch = false,
  });

  final int financeId;
  final FinanceEntryType financeType;
  final int? currentMembershipId;

  /// When true, fetches via finance.get (accessible to all ops users).
  /// When false (default), fetches via finance.approval.get (membership-restricted).
  final bool useGeneralFetch;

  @override
  ConsumerState<FinanceApprovalDetailScreen> createState() =>
      _FinanceApprovalDetailScreenState();
}

class _FinanceApprovalDetailScreenState
    extends ConsumerState<FinanceApprovalDetailScreen> {
  FinanceEntry? _entry;
  bool _loadingScreen = true;
  bool _isActionLoading = false;
  String? _errorMessage;

  FinanceRepository get _financeRepository =>
      ref.read(financeRepositoryProvider);

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetch);
  }

  Future<void> _fetch() async {
    setState(() {
      _loadingScreen = true;
      _errorMessage = null;
    });

    final result = widget.useGeneralFetch
        ? await _financeRepository.fetchFinanceEntry(
            financeId: widget.financeId,
            type: widget.financeType,
          )
        : await _financeRepository.fetchApprovalFinanceEntry(
            financeId: widget.financeId,
            type: widget.financeType,
          );

    result.when(
      onSuccess: (entry) {
        if (!mounted) return;
        setState(() {
          _entry = entry;
          _loadingScreen = false;
        });
      },
      onFailure: (failure) {
        if (!mounted) return;
        setState(() {
          _loadingScreen = false;
          _errorMessage = failure.message;
        });
      },
    );
  }

  Future<bool> _updateApprover(ApprovalStatus status, int approverId) async {
    setState(() {
      _isActionLoading = true;
      _errorMessage = null;
    });

    final result = await _financeRepository.updateFinanceApprover(
      approverId: approverId,
      type: widget.financeType,
      status: status,
    );

    var success = false;
    result.when(
      onSuccess: (_) {
        success = true;
      },
      onFailure: (failure) {
        _errorMessage = failure.message;
      },
    );

    if (mounted) {
      setState(() {
        _isActionLoading = false;
      });
    }

    if (success) {
      await _fetch();
    }

    return success;
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

  String _paymentMethodLabel(BuildContext context, PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return context.l10n.paymentMethod_cash;
      case PaymentMethod.cashless:
        return context.l10n.paymentMethod_cashless;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entry = _entry;
    final overall = entry == null ? null : _overallStatus(entry.approvers);
    final pendingApprover = entry?.approvers.firstWhere(
      (ap) =>
          ap.status == ApprovalStatus.unconfirmed &&
          ap.membership?.id == widget.currentMembershipId,
      orElse: () => const Approver(
        id: -1,
        status: ApprovalStatus.approved,
        createdAt: null,
        updatedAt: null,
      ),
    );
    final isMinePending =
        pendingApprover != null &&
        pendingApprover.id != null &&
        pendingApprover.id != -1;

    Widget? actionButtons;
    if (overall == ApprovalStatus.unconfirmed && isMinePending) {
      actionButtons = _buildActionButtons(
        context,
        pendingApprover.id!,
        _isActionLoading,
        entry == null
            ? (widget.financeType == FinanceEntryType.revenue
                  ? l10n.admin_revenue_title
                  : l10n.operationsItem_add_expense_title)
            : _resolveTitle(entry),
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
            loading: _loadingScreen,
            hasError: _errorMessage != null && _loadingScreen == false,
            errorMessage: _errorMessage,
            onRetry: _fetch,
            shimmerPlaceholder: ShimmerPlaceholders.approvalDetailLayout(),
            child: entry == null
                ? ApprovalAnimatedPresence(
                    visible: true,
                    child: InfoBoxWidget(message: l10n.approvalDetail_notFound),
                  )
                : _buildContent(context, entry),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, FinanceEntry entry) {
    final overall = _overallStatus(entry.approvers);
    final linkedActivity = entry.activity;
    final isMinePending = entry.approvers.any(
      (ap) =>
          ap.status == ApprovalStatus.unconfirmed &&
          ap.membership?.id == widget.currentMembershipId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ApprovalReveal(
          delay: const Duration(milliseconds: 40),
          child: _buildFinanceInfoCard(context, entry),
        ),
        Gap.h8,
        ApprovalReveal(
          delay: const Duration(milliseconds: 80),
          child: _buildApproversCard(context, entry.approvers),
        ),
        if (linkedActivity != null) ...[
          Gap.h8,
          ApprovalReveal(
            delay: const Duration(milliseconds: 120),
            child: _buildLinkedActivityCard(context, linkedActivity),
          ),
        ],
        if (overall == ApprovalStatus.unconfirmed &&
            entry.approvers.any(
              (ap) =>
                  ap.status == ApprovalStatus.approved &&
                  ap.membership?.id == widget.currentMembershipId,
            )) ...[
          Gap.h8,
          ApprovalReveal(
            delay: const Duration(milliseconds: 160),
            child: InfoBoxWidget(
              message: context.l10n.approvalDetail_waitingOthers,
            ),
          ),
        ],
        Gap.h8,
        if (overall == ApprovalStatus.unconfirmed) ...[
          if (!isMinePending)
            ApprovalReveal(
              delay: const Duration(milliseconds: 200),
              child: ApprovalStatusPill(status: overall),
            ),
        ] else ...[
          ApprovalReveal(
            delay: const Duration(milliseconds: 200),
            child: ApprovalStatusPill(status: overall),
          ),
        ],
        if (linkedActivity != null) ...[
          Gap.h12,
          ApprovalReveal(
            delay: const Duration(milliseconds: 240),
            child: _buildViewActivityDetailsButton(context, linkedActivity),
          ),
        ],
      ],
    );
  }

  String _resolveTitle(FinanceEntry entry) {
    final linkedTitle = entry.activity?.title.trim();
    if (linkedTitle != null && linkedTitle.isNotEmpty) {
      return linkedTitle;
    }
    if (entry.accountNumber.trim().isNotEmpty) {
      return entry.accountNumber;
    }
    return entry.type == FinanceEntryType.revenue
        ? context.l10n.admin_revenue_title
        : context.l10n.operationsItem_add_expense_title;
  }

  Widget _buildActionButtons(
    BuildContext context,
    int approverId,
    bool isLoading,
    String title,
  ) {
    final l10n = context.l10n;

    return Material(
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
                          text: l10n.btn_reject,
                          icon: AppIcons.close,
                          color: AppColors.error.shade500,
                          isLoading: isLoading,
                          onTap: () async {
                            final confirmed =
                                await showApprovalConfirmationBottomSheet(
                                  context: context,
                                  isApprove: false,
                                  activityTitle: title,
                                );
                            if (confirmed != true || !context.mounted) return;

                            final success = await _updateApprover(
                              ApprovalStatus.rejected,
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
                          text: l10n.btn_approve,
                          icon: AppIcons.approve,
                          color: AppColors.success.shade600,
                          isLoading: isLoading,
                          onTap: () async {
                            final confirmed =
                                await showApprovalConfirmationBottomSheet(
                                  context: context,
                                  isApprove: true,
                                  activityTitle: title,
                                );
                            if (confirmed != true || !context.mounted) return;

                            final success = await _updateApprover(
                              ApprovalStatus.approved,
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
                            text: l10n.btn_reject,
                            icon: AppIcons.close,
                            color: AppColors.error.shade500,
                            isLoading: isLoading,
                            onTap: () async {
                              final confirmed =
                                  await showApprovalConfirmationBottomSheet(
                                    context: context,
                                    isApprove: false,
                                    activityTitle: title,
                                  );
                              if (confirmed != true || !context.mounted) return;

                              final success = await _updateApprover(
                                ApprovalStatus.rejected,
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
                            text: l10n.btn_approve,
                            icon: AppIcons.approve,
                            color: AppColors.success.shade600,
                            isLoading: isLoading,
                            onTap: () async {
                              final confirmed =
                                  await showApprovalConfirmationBottomSheet(
                                    context: context,
                                    isApprove: true,
                                    activityTitle: title,
                                  );
                              if (confirmed != true || !context.mounted) return;

                              final success = await _updateApprover(
                                ApprovalStatus.approved,
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

  Widget _buildActionButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Material(
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
          child: LoadingActionContent(
            isLoading: isLoading,
            loaderSize: 18.0,
            loaderBaseColor: color.withValues(alpha: 0.24),
            loaderHighlightColor: color,
            loaderBackgroundColor: AppColors.surface,
            loaderBorderColor: color.withValues(alpha: 0.16),
            child: Row(
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
      ),
    );
  }

  Widget _buildFinanceInfoCard(BuildContext context, FinanceEntry entry) {
    final isRevenue = entry.type == FinanceEntryType.revenue;
    final baseColor = isRevenue ? AppColors.success : AppColors.error;

    return _buildInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(
            context: context,
            icon: isRevenue ? AppIcons.revenue : AppIcons.expense,
            title: context.l10n.approvalDetail_financialData_title,
            iconColor: baseColor.shade700,
            trailing: Text(
              isRevenue
                  ? context.l10n.financeType_revenue
                  : context.l10n.financeType_expense,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: baseColor.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Gap.h12,
          Text(
            _resolveTitle(entry),
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          Gap.h4,
          Text(
            '${context.l10n.lbl_activityId}: #${entry.id ?? widget.financeId}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: AppColors.onSurfaceVariant),
          ),
          Gap.h12,
          Divider(color: AppColors.neutral, height: 1),
          Gap.h12,
          _buildInfoRow(
            icon: AppIcons.money,
            iconColor: baseColor.shade600,
            label: context.l10n.lbl_amount,
            value: formatRupiah(entry.amount),
          ),
          Gap.h12,
          _buildInfoRow(
            icon: AppIcons.bankAccount,
            iconColor: AppColors.primary.shade600,
            label: context.l10n.lbl_accountNumber,
            value: entry.accountNumber.isEmpty ? '-' : entry.accountNumber,
          ),
          Gap.h12,
          _buildInfoRow(
            icon: AppIcons.payment,
            iconColor: AppColors.primary,
            label: context.l10n.tbl_paymentMethod,
            value: _paymentMethodLabel(context, entry.paymentMethod),
          ),
          if (entry.createdAt != null) ...[
            Gap.h12,
            _buildInfoRow(
              icon: AppIcons.createdAt,
              iconColor: AppColors.onSurfaceVariant,
              label: context.l10n.lbl_createdAt,
              value:
                  '${entry.createdAt!.EEEEddMMMyyyy} ${entry.createdAt!.HHmm} • ${entry.createdAt!.toFromNow}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApproversCard(BuildContext context, List<Approver> approvers) {
    final l10n = context.l10n;
    return _buildInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(
            context: context,
            icon: AppIcons.approval,
            title: l10n.tbl_approvers,
            iconColor: AppColors.onSurface,
            trailing: Text(
              '(${approvers.length})',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Gap.h12,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: approvers.map((ap) {
              final name = ap.membership?.account?.name ?? l10n.lbl_unknown;
              final approverMembershipId = ap.membershipId ?? ap.membership?.id;
              final isCurrentUser =
                  widget.currentMembershipId != null &&
                  approverMembershipId != null &&
                  approverMembershipId == widget.currentMembershipId;
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
    );
  }

  Widget _buildLinkedActivityCard(BuildContext context, Activity activity) {
    return _buildInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(
            context: context,
            icon: AppIcons.event,
            title: context.l10n.tbl_activity,
            iconColor: AppColors.primary,
          ),
          Gap.h12,
          Text(
            activity.title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          Gap.h4,
          Text(
            '${context.l10n.lbl_activityId}: #${activity.id}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: AppColors.onSurfaceVariant),
          ),
          Gap.h12,
          _buildInfoRow(
            icon: AppIcons.person,
            iconColor: AppColors.primary.shade600,
            label: context.l10n.tbl_supervisor,
            value:
                activity.supervisor.account?.name ?? context.l10n.lbl_unknown,
          ),
          Gap.h12,
          _buildInfoRow(
            icon: AppIcons.time,
            iconColor: AppColors.warning.shade600,
            label: context.l10n.lbl_date,
            value: '${activity.date.EEEEddMMMyyyy} ${activity.date.HHmm}',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color iconColor,
    Widget? trailing,
  }) {
    return Row(
      children: [
        FaIcon(icon, size: 20.0, color: iconColor),
        Gap.w8,
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: AppColors.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: AppColors.neutral, width: 1),
      ),
      child: Padding(padding: EdgeInsets.all(12.0), child: child),
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

  Widget _buildViewActivityDetailsButton(
    BuildContext context,
    Activity activity,
  ) {
    final l10n = context.l10n;
    return Material(
      clipBehavior: Clip.hardEdge,
      color: AppColors.surfaceContainerLowest,
      elevation: 1,
      shadowColor: AppColors.onSurface,
      surfaceTintColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        onTap: () {
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
