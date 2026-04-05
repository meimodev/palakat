import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/approval/presentations/approval_state.dart';
import 'package:palakat_shared/extensions.dart';

/// A horizontal row of filter chips for filtering approvals by status.
/// Options: All, Pending My Action, Pending Others, Approved, Rejected
class StatusFilterChips extends StatelessWidget {
  const StatusFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.pendingMyActionCount = 0,
    this.pendingOthersCount = 0,
    this.approvedCount = 0,
    this.rejectedCount = 0,
  });

  final ApprovalFilterStatus selectedFilter;
  final ValueChanged<ApprovalFilterStatus> onFilterChanged;
  final int pendingMyActionCount;
  final int pendingOthersCount;
  final int approvedCount;
  final int rejectedCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: l10n.approval_filterAll,
            isSelected: selectedFilter == ApprovalFilterStatus.all,
            onTap: () => onFilterChanged(ApprovalFilterStatus.all),
          ),
          Gap.w8,
          _FilterChip(
            label: l10n.approval_filterMyAction,
            count: pendingMyActionCount,
            isSelected: selectedFilter == ApprovalFilterStatus.pendingMyAction,
            onTap: () => onFilterChanged(ApprovalFilterStatus.pendingMyAction),
            highlightColor: AppColors.primary,
            emphasize:
                pendingMyActionCount > 0 &&
                selectedFilter != ApprovalFilterStatus.pendingMyAction,
          ),
          Gap.w8,
          _FilterChip(
            label: l10n.approval_filterPendingOthers,
            count: pendingOthersCount,
            isSelected: selectedFilter == ApprovalFilterStatus.pendingOthers,
            onTap: () => onFilterChanged(ApprovalFilterStatus.pendingOthers),
            highlightColor: AppColors.warning,
          ),
          Gap.w8,
          _FilterChip(
            label: l10n.status_approved,
            count: approvedCount,
            isSelected: selectedFilter == ApprovalFilterStatus.approved,
            onTap: () => onFilterChanged(ApprovalFilterStatus.approved),
            highlightColor: AppColors.success,
          ),
          Gap.w8,
          _FilterChip(
            label: l10n.status_rejected,
            count: rejectedCount,
            isSelected: selectedFilter == ApprovalFilterStatus.rejected,
            onTap: () => onFilterChanged(ApprovalFilterStatus.rejected),
            highlightColor: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
    this.emphasize = false,
    this.highlightColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;
  final bool emphasize;
  final MaterialColor? highlightColor;

  @override
  Widget build(BuildContext context) {
    final color = highlightColor ?? AppColors.primary;
    final shouldEmphasize = emphasize && !isSelected;

    return AnimatedScale(
      scale: shouldEmphasize ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: Material(
        color: isSelected
            ? color
            : shouldEmphasize
            ? color.withValues(alpha: 0.08)
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? color
                    : shouldEmphasize
                    ? color.withValues(alpha: 0.7)
                    : AppColors.tertiary,
                width: shouldEmphasize ? 1.5 : 1,
              ),
              boxShadow: SanctuaryDepth.ambient(
                opacity: shouldEmphasize ? 0.03 : 0.02,
                blur: shouldEmphasize ? 10 : 8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.surfaceContainerLowest
                        : AppColors.onSurface,
                  ),
                ),
                if (count != null && count! > 0) ...[
                  Gap.w6,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.surfaceContainerLowest
                            : color.withValues(alpha: 0.18),
                      ),
                      boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 6),
                    ),
                    child: Text(
                      count.toString(),
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppColors.surfaceContainerLowest
                            : color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
