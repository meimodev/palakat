import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/approval/presentations/approval_state.dart';

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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selectedFilter == ApprovalFilterStatus.all,
            onTap: () => onFilterChanged(ApprovalFilterStatus.all),
          ),
          Gap.w8,
          _FilterChip(
            label: 'My Action',
            count: pendingMyActionCount,
            isSelected: selectedFilter == ApprovalFilterStatus.pendingMyAction,
            onTap: () => onFilterChanged(ApprovalFilterStatus.pendingMyAction),
            highlightColor: BaseColor.teal,
          ),
          Gap.w8,
          _FilterChip(
            label: 'Pending Others',
            count: pendingOthersCount,
            isSelected: selectedFilter == ApprovalFilterStatus.pendingOthers,
            onTap: () => onFilterChanged(ApprovalFilterStatus.pendingOthers),
            highlightColor: BaseColor.yellow,
          ),
          Gap.w8,
          _FilterChip(
            label: 'Approved',
            count: approvedCount,
            isSelected: selectedFilter == ApprovalFilterStatus.approved,
            onTap: () => onFilterChanged(ApprovalFilterStatus.approved),
            highlightColor: BaseColor.green,
          ),
          Gap.w8,
          _FilterChip(
            label: 'Rejected',
            count: rejectedCount,
            isSelected: selectedFilter == ApprovalFilterStatus.rejected,
            onTap: () => onFilterChanged(ApprovalFilterStatus.rejected),
            highlightColor: BaseColor.red,
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
    this.highlightColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;
  final MaterialColor? highlightColor;

  @override
  Widget build(BuildContext context) {
    final color = highlightColor ?? BaseColor.teal;

    return Material(
      color: isSelected ? color.shade500 : BaseColor.cardBackground1,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.w12,
            vertical: BaseSize.h8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color.shade500 : BaseColor.neutral20,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: BaseTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : BaseColor.primaryText,
                ),
              ),
              if (count != null && count! > 0) ...[
                Gap.w6,
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: BaseSize.w6,
                    vertical: BaseSize.h4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : color.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: BaseTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : color.shade700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
