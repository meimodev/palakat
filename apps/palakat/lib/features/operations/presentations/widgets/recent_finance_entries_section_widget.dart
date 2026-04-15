import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/approver.dart';
import 'package:palakat_shared/core/models/finance_entry.dart';

/// Section widget displaying recent standalone finance entries
/// (entries without an activity attachment).
/// Mirrors the RecentReportsSection pattern from the Reports category.
class RecentFinanceEntriesSection extends StatelessWidget {
  const RecentFinanceEntriesSection({
    super.key,
    required this.entries,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    this.currentMembershipId,
    required this.onEntryTap,
    this.pendingFinanceActionIds = const <int>{},
    required this.onApprovalAction,
  });

  /// List of recent standalone finance entries to display (max 10)
  final List<FinanceEntry> entries;

  /// Whether the section is currently loading
  final bool isLoading;

  /// Error message if fetch failed, null if no error
  final String? error;

  /// Callback when retry button is tapped after error
  final VoidCallback onRetry;

  /// Current user's membership ID to determine if user is an approver
  final int? currentMembershipId;

  /// Callback when a finance entry item is tapped
  final ValueChanged<FinanceEntry> onEntryTap;

  /// Set of finance entry IDs with an approval action currently in-flight
  final Set<int> pendingFinanceActionIds;

  /// Callback when approve/reject is tapped inline
  final void Function(FinanceEntry entry, int approverId, ApprovalStatus status)
  onApprovalAction;

  @override
  Widget build(BuildContext context) {
    final hasContent = entries.isNotEmpty;

    // Hide section when not loading, no error, and no content
    if (!isLoading && error == null && !hasContent) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [Gap.h8, _SectionHeader(), Gap.h6, _buildContent(context)],
    );
  }

  Widget _buildContent(BuildContext context) {
    // Priority 1: Show error state with retry button
    if (error != null && !isLoading) {
      return ErrorDisplayWidget(
        message: error!,
        onRetry: onRetry,
        padding: EdgeInsets.zero,
      );
    }

    // Priority 2: Show loading shimmer
    if (isLoading && entries.isEmpty) {
      return LoadingShimmer(
        isLoading: true,
        child: ShimmerPlaceholders.listSection(),
      );
    }

    // Priority 3: Show entries list
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: entries
          .map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: 6.0),
              child: _FinanceEntryListItem(
                entry: entry,
                currentMembershipId: currentMembershipId,
                isActionPending:
                    entry.id != null &&
                    pendingFinanceActionIds.contains(entry.id),
                onTap: () => onEntryTap(entry),
                onApprovalAction: onApprovalAction,
              ),
            ),
          )
          .toList(),
    );
  }
}

/// Section header with title
class _SectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.operationsCategory_financial_recentEntries,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

/// Individual finance entry list item
class _FinanceEntryListItem extends StatelessWidget {
  const _FinanceEntryListItem({
    required this.entry,
    required this.currentMembershipId,
    required this.isActionPending,
    required this.onTap,
    required this.onApprovalAction,
  });

  final FinanceEntry entry;
  final int? currentMembershipId;

  /// Whether an approval action is currently in-flight for this entry.
  /// Both approve and reject buttons are disabled when true.
  final bool isActionPending;

  final VoidCallback onTap;
  final void Function(FinanceEntry entry, int approverId, ApprovalStatus status)
  onApprovalAction;

  @override
  Widget build(BuildContext context) {
    final isRevenue = entry.type == FinanceEntryType.revenue;
    final typeColor = isRevenue ? AppColors.success : AppColors.error;
    final typeIcon = isRevenue ? AppIcons.revenue : AppIcons.expense;
    final effectiveStatus = entry.effectiveStatus;

    final createdAt = entry.createdAt;
    final dateText = createdAt != null ? createdAt.EddMMMyyyy : '';

    // Find the current user's unconfirmed approver entry (if any)
    final Approver? myApprover = _findMyUnconfirmedApprover();

    return Material(
      color: AppColors.surfaceContainerLowest,
      elevation: 0,
      shadowColor: AppColors.onSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: AppColors.ghostBorder(0.08), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final shouldStack =
                constraints.maxWidth < 360 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.1;

            final entryIcon = Container(
              width: 36.0,
              height: 36.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                border: Border.all(color: typeColor.withValues(alpha: 0.24)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(typeIcon, color: typeColor, size: 16.0),
            );

            final title = entry.accountNumber.isNotEmpty
                ? entry.accountNumber
                : (isRevenue
                      ? context.l10n.lbl_revenue
                      : context.l10n.lbl_expense);

            final amountText = _formatRupiah(entry.amount);

            final titleRow = shouldStack
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap.h4,
                      Text(
                        amountText,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: typeColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Gap.w8,
                      Text(
                        amountText,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: typeColor,
                        ),
                      ),
                    ],
                  );

            final approvedCount = entry.approvers
                .where((a) => a.status == ApprovalStatus.approved)
                .length;
            final totalApprovers = entry.approvers.length;

            final subtitleParts = <Widget>[
              if (dateText.isNotEmpty)
                Text(
                  dateText,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (dateText.isNotEmpty && totalApprovers > 0)
                Text(
                  ' • ',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              if (totalApprovers > 0)
                _ApprovalStatusDots(
                  approvers: entry.approvers,
                  effectiveStatus: effectiveStatus,
                  approvedCount: approvedCount,
                  totalApprovers: totalApprovers,
                ),
            ];

            final subtitle = Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 0,
              runSpacing: 4.0,
              children: subtitleParts,
            );

            final actionButtons = myApprover != null
                ? Padding(
                    padding: EdgeInsets.only(top: 6.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ActionIconButton(
                          icon: AppIcons.reject,
                          color: AppColors.error,
                          tooltip: context.l10n.btn_reject,
                          isDisabled: isActionPending,
                          onTap: isActionPending
                              ? null
                              : () => onApprovalAction(
                                  entry,
                                  myApprover.id!,
                                  ApprovalStatus.rejected,
                                ),
                        ),
                        Gap.w8,
                        _ActionIconButton(
                          icon: AppIcons.approve,
                          color: AppColors.success,
                          tooltip: context.l10n.btn_approve,
                          isDisabled: isActionPending,
                          onTap: isActionPending
                              ? null
                              : () => onApprovalAction(
                                  entry,
                                  myApprover.id!,
                                  ApprovalStatus.approved,
                                ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink();

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  entryIcon,
                  Gap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [titleRow, Gap.h4, subtitle, actionButtons],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Approver? _findMyUnconfirmedApprover() {
    if (currentMembershipId == null) return null;
    try {
      return entry.approvers.firstWhere(
        (a) =>
            a.membershipId == currentMembershipId &&
            a.status == ApprovalStatus.unconfirmed &&
            a.id != null,
      );
    } catch (_) {
      return null;
    }
  }

  String _formatRupiah(int amount) {
    final buffer = StringBuffer();
    final str = amount.abs().toString();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return 'Rp $buffer';
  }
}

/// Small action button for approve/reject inline actions
class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
    this.isDisabled = false,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDisabled ? color.withValues(alpha: 0.38) : color;
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Material(
          color: effectiveColor.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
            side: BorderSide(color: effectiveColor.withValues(alpha: 0.16)),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6.0),
            splashColor: isDisabled
                ? Colors.transparent
                : color.withValues(alpha: 0.12),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(icon, size: 14.0, color: effectiveColor),
            ),
          ),
        ),
      ),
    );
  }
}

/// Approval status dots showing each approver's status
class _ApprovalStatusDots extends StatelessWidget {
  const _ApprovalStatusDots({
    required this.approvers,
    required this.effectiveStatus,
    required this.approvedCount,
    required this.totalApprovers,
  });

  final List<Approver> approvers;
  final ApprovalStatus effectiveStatus;
  final int approvedCount;
  final int totalApprovers;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...approvers.map((a) {
          final dotColor = switch (a.status) {
            ApprovalStatus.approved => AppColors.success,
            ApprovalStatus.rejected => AppColors.error,
            _ => AppColors.onSurfaceVariant.withValues(alpha: 0.38),
          };
          return Padding(
            padding: EdgeInsets.only(right: 3.0),
            child: Container(
              width: 7.0,
              height: 7.0,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
        Gap.w4,
        Text(
          '$approvedCount/$totalApprovers',
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
