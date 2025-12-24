import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/operations/data/operation_models.dart';
import 'package:palakat/features/operations/presentations/widgets/operation_item_card_widget.dart';
import 'package:palakat/features/operations/presentations/widgets/recent_reports_section_widget.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/report.dart';

/// Collapsible category card that groups related operations.
/// Uses ExpansionTile pattern with custom styling.
///
/// Requirements: 2.3, 2.4, 3.1, 3.2
class OperationCategoryCard extends StatelessWidget {
  const OperationCategoryCard({
    super.key,
    required this.category,
    required this.onExpansionChanged,
    required this.onOperationTap,
    this.recentReports,
    this.isLoadingRecentReports = false,
    this.recentReportsError,
    this.onReportDownloadTap,
    this.onRecentReportsRetry,
  });

  /// The category data to display
  final OperationCategory category;

  /// Callback when the category expansion state changes
  final ValueChanged<bool> onExpansionChanged;

  /// Callback when an operation item is tapped
  final ValueChanged<OperationItem> onOperationTap;

  /// Recent reports for the Reports category (optional)
  final List<Report>? recentReports;

  /// Loading state for recent reports
  final bool isLoadingRecentReports;

  /// Error message for recent reports
  final String? recentReportsError;

  /// Callback when download button is tapped for a report
  final ValueChanged<Report>? onReportDownloadTap;

  /// Callback when retry button is tapped for recent reports
  final VoidCallback? onRecentReportsRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BaseColor.surfaceMedium,
        borderRadius: BorderRadius.circular(BaseSize.w16),
        boxShadow: [
          BoxShadow(
            color: BaseColor.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category header with expand/collapse functionality
          _CategoryHeader(
            category: category,
            onTap: () => onExpansionChanged(!category.isExpanded),
          ),

          // Operation items - only visible when expanded
          AnimatedCrossFade(
            firstChild: _buildOperationsList(context, category.operations),
            secondChild: const SizedBox.shrink(),
            crossFadeState: category.isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsList(
    BuildContext context,
    List<OperationItem> operations,
  ) {
    final l10n = context.l10n;

    if (category.id == 'reports') {
      if (operations.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Text(
            l10n.operations_noOperationsAvailable,
            style: BaseTypography.bodyMedium.copyWith(
              color: BaseColor.textSecondary,
            ),
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.only(
          left: BaseSize.w8,
          right: BaseSize.w8,
          bottom: BaseSize.w12,
          top: BaseSize.w8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: BaseSize.w8,
              mainAxisSpacing: BaseSize.w8,
              childAspectRatio: 3.0,
              children: operations
                  .map(
                    (operation) => _ReportTypeTile(
                      title: operation.title,
                      icon: operation.icon,
                      onTap: () => onOperationTap(operation),
                    ),
                  )
                  .toList(),
            ),
            // Recent reports section
            if (recentReports != null ||
                isLoadingRecentReports ||
                recentReportsError != null)
              Padding(
                padding: EdgeInsets.only(top: BaseSize.w8),
                child: RecentReportsSection(
                  reports: recentReports ?? [],
                  isLoading: isLoadingRecentReports,
                  error: recentReportsError,
                  onDownloadTap: (report) => onReportDownloadTap?.call(report),
                  onRetry: () => onRecentReportsRetry?.call(),
                ),
              ),
          ],
        ),
      );
    }

    if (operations.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Text(
          l10n.operations_noOperationsAvailable,
          style: BaseTypography.bodyMedium.copyWith(
            color: BaseColor.textSecondary,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: BaseSize.w8,
        right: BaseSize.w8,
        bottom: BaseSize.w8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: operations
            .map(
              (operation) => Padding(
                padding: EdgeInsets.only(bottom: BaseSize.w8),
                child: OperationItemCard(
                  operation: operation,
                  onTap: () => onOperationTap(operation),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ReportTypeTile extends StatelessWidget {
  const _ReportTypeTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BaseColor.surfaceLight,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.w12),
        side: BorderSide(color: BaseColor.neutral[200]!, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: BaseColor.primary.withValues(alpha: 0.08),
        highlightColor: BaseColor.primary.withValues(alpha: 0.05),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.w12,
            vertical: BaseSize.h8,
          ),
          child: Row(
            children: [
              Container(
                width: BaseSize.w28,
                height: BaseSize.w28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: BaseColor.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BaseSize.w8),
                ),
                child: Icon(icon, color: BaseColor.primary, size: BaseSize.w14),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: BaseSize.w8),
                  child: Text(
                    title,
                    style: BaseTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: BaseColor.textPrimary,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _categoryTitle(BuildContext context, OperationCategory category) {
  final l10n = context.l10n;
  switch (category.id) {
    case 'publishing':
      return l10n.operationsCategory_publishing;
    case 'financial':
      return l10n.operationsCategory_financial;
    case 'reports':
      return l10n.operationsCategory_reports;
    default:
      return category.title;
  }
}

/// Category header with icon, title, and expand/collapse indicator
class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category, required this.onTap});

  final OperationCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BaseColor.primary[50],
      child: InkWell(
        onTap: onTap, // Always tappable for expand/collapse
        splashColor: BaseColor.primary.withValues(alpha: 0.1),
        highlightColor: BaseColor.primary.withValues(alpha: 0.05),
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Row(
            children: [
              // Category icon
              Container(
                width: BaseSize.w40,
                height: BaseSize.w40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: BaseColor.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(BaseSize.w12),
                ),
                child: Icon(
                  category.icon,
                  color: BaseColor.primary,
                  size: BaseSize.w24,
                ),
              ),
              Gap.w12,
              // Category title
              Expanded(
                child: Text(
                  _categoryTitle(context, category),
                  style: BaseTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: BaseColor.textPrimary,
                  ),
                ),
              ),
              // Operation count badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSize.w8,
                  vertical: BaseSize.w4,
                ),
                decoration: BoxDecoration(
                  color: BaseColor.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(BaseSize.w12),
                ),
                child: Text(
                  '${category.operations.length}',
                  style: BaseTypography.labelSmall.copyWith(
                    color: BaseColor.primary[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Expand/collapse icon with animation (always visible)
              Gap.w8,
              AnimatedRotation(
                turns: category.isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  AppIcons.keyboardArrowDown,
                  color: BaseColor.primary,
                  size: BaseSize.w24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
