import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/operations/data/operation_models.dart';
import 'package:palakat/features/operations/presentations/widgets/operation_item_card_widget.dart';
import 'package:palakat/features/operations/presentations/widgets/recent_reports_section_widget.dart';
import 'package:palakat/features/operations/presentations/widgets/responsive_operation_grid_widget.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/report.dart';
import 'package:palakat_shared/core/models/report_job.dart';

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
    this.onReportViewTap,
    this.onRecentReportsRetry,
    this.pendingReportJobs,
    this.isLoadingPendingReportJobs = false,
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

  /// Callback when view button is tapped for a report
  final ValueChanged<Report>? onReportViewTap;

  /// Callback when retry button is tapped for recent reports
  final VoidCallback? onRecentReportsRetry;

  /// Pending/processing report jobs for the Reports category (optional)
  final List<ReportJob>? pendingReportJobs;

  /// Loading state for pending report jobs
  final bool isLoadingPendingReportJobs;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: AppColors.neutral, width: 1),
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
    if (operations.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          l10n.operations_noOperationsAvailable,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: AppColors.onSurfaceVariant),
        ),
      );
    }
    if (category.id == 'reports') {
      return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = _reportGridColumnCount(constraints.maxWidth);
          final childAspectRatio = crossAxisCount == 1 ? 3.4 : 3.0;

          return Padding(
            padding: EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 12.0,
              top: 8.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: operations.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    final operation = operations[index];
                    return _ReportTypeTile(
                      title: operation.title,
                      icon: operation.icon,
                      isEnabled: operation.isEnabled,
                      onTap: () => onOperationTap(operation),
                    );
                  },
                ),
                if (recentReports != null ||
                    isLoadingRecentReports ||
                    recentReportsError != null ||
                    (pendingReportJobs != null &&
                        pendingReportJobs!.isNotEmpty) ||
                    isLoadingPendingReportJobs)
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: RecentReportsSection(
                      reports: recentReports ?? [],
                      isLoading: isLoadingRecentReports,
                      error: recentReportsError,
                      onDownloadTap: (report) =>
                          onReportDownloadTap?.call(report),
                      onViewTap: onReportViewTap,
                      onRetry: () => onRecentReportsRetry?.call(),
                      pendingJobs: pendingReportJobs ?? [],
                      isLoadingPendingJobs: isLoadingPendingReportJobs,
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      child: ResponsiveOperationGrid(
        operations: operations,
        onOperationTap: onOperationTap,
      ),
    );
  }
}

int _reportGridColumnCount(double width) {
  if (width >= 760) return 3;
  if (width >= 150) return 2;
  return 1;
}

class _ReportTypeTile extends StatelessWidget {
  const _ReportTypeTile({
    required this.title,
    required this.icon,
    required this.isEnabled,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : OperationItemCard.disabledOpacity,
      child: Material(
        color: AppColors.surfaceContainerLowest,
        elevation: 1,
        shadowColor: AppColors.onSurface,
        surfaceTintColor: AppColors.primary,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: AppColors.neutral, width: 1),
        ),
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final shouldStack =
                  constraints.maxWidth < 100 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.1;

              final tileIcon = Container(
                width: shouldStack ? 32.0 : 28.0,
                height: shouldStack ? 32.0 : 28.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isEnabled ? AppColors.primary : AppColors.neutral,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Icon(
                  icon,
                  color: isEnabled
                      ? AppColors.neutral
                      : AppColors.onSurface.withValues(alpha: 0.38),
                  size: shouldStack ? 16.0 : 14.0,
                ),
              );

              final titleText = Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isEnabled
                      ? AppColors.onSurface
                      : AppColors.onSurface.withValues(alpha: 0.38),
                  height: 1.1,
                ),
                maxLines: shouldStack ? 3 : 2,
                overflow: TextOverflow.ellipsis,
              );

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: shouldStack
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          tileIcon,
                          Gap.h8,
                          Expanded(child: titleText),
                        ],
                      )
                    : Row(
                        children: [
                          tileIcon,
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: titleText,
                            ),
                          ),
                        ],
                      ),
              );
            },
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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final shouldStack =
                  constraints.maxWidth < 360 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.1;

              final icon = Container(
                width: 40.0,
                height: 40.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
                ),
                child: Icon(
                  category.icon,
                  color: AppColors.primary,
                  size: 24.0,
                ),
              );

              final title = Text(
                _categoryTitle(context, category),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
                maxLines: shouldStack ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              );

              final countBadge = Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 6),
                ),
                child: Text(
                  '${category.operations.length}',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );

              final expandIcon = AnimatedRotation(
                turns: category.isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  AppIcons.keyboardArrowDown,
                  color: AppColors.primary,
                  size: 24.0,
                ),
              );

              return Row(
                children: [
                  icon,
                  Gap.w12,
                  Expanded(child: title),
                  countBadge,
                  Gap.w8,
                  expandIcon,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
