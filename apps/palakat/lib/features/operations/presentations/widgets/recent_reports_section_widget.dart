import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/loading/shimmer_widgets.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/report.dart';
import 'package:palakat_shared/widgets.dart';

/// Section widget displaying recent reports created by the current user.
/// Shows up to 5 reports with download buttons.
class RecentReportsSection extends StatelessWidget {
  const RecentReportsSection({
    super.key,
    required this.reports,
    required this.isLoading,
    required this.error,
    required this.onDownloadTap,
    required this.onRetry,
  });

  /// List of recent reports to display (max 5)
  final List<Report> reports;

  /// Whether the section is currently loading
  final bool isLoading;

  /// Error message if fetch failed, null if no error
  final String? error;

  /// Callback when download button is tapped for a report
  final ValueChanged<Report> onDownloadTap;

  /// Callback when retry button is tapped after error
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Hide section when not loading, no error, and reports list is empty
    if (!isLoading && error == null && reports.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(color: BaseColor.neutral[200], height: 1),
        Gap.h12,
        _SectionHeader(),
        Gap.h8,
        _buildContent(context),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    // Priority 1: Show error state with retry button
    if (error != null && !isLoading) {
      return _ErrorState(message: error!, onRetry: onRetry);
    }

    // Priority 2: Show loading shimmer
    if (isLoading) {
      return LoadingShimmer(isLoading: true, child: _buildShimmerPlaceholder());
    }

    // Priority 3: Show reports list
    return _ReportsList(reports: reports, onDownloadTap: onDownloadTap);
  }

  Widget _buildShimmerPlaceholder() {
    return Column(
      children: [
        PalakatShimmerPlaceholders.listItemCard(),
        Gap.h8,
        PalakatShimmerPlaceholders.listItemCard(),
        Gap.h8,
        PalakatShimmerPlaceholders.listItemCard(),
      ],
    );
  }
}

/// Section header with title
class _SectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.card_recentActivity_title,
      style: BaseTypography.labelLarge.copyWith(
        fontWeight: FontWeight.w600,
        color: BaseColor.textSecondary,
      ),
    );
  }
}

/// List of report items
class _ReportsList extends StatelessWidget {
  const _ReportsList({required this.reports, required this.onDownloadTap});

  final List<Report> reports;
  final ValueChanged<Report> onDownloadTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: reports
          .map(
            (report) => Padding(
              padding: EdgeInsets.only(bottom: BaseSize.w4),
              child: RecentReportItem(
                report: report,
                onDownloadTap: () => onDownloadTap(report),
              ),
            ),
          )
          .toList(),
    );
  }
}

/// Error state with retry button
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.all(BaseSize.w12),
      decoration: BoxDecoration(
        color: BaseColor.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(BaseSize.w8),
      ),
      child: Row(
        children: [
          Icon(AppIcons.error, color: BaseColor.error, size: BaseSize.w16),
          Gap.w8,
          Expanded(
            child: Text(
              message,
              style: BaseTypography.bodySmall.copyWith(color: BaseColor.error),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: BaseColor.error,
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(l10n.btn_retry),
          ),
        ],
      ),
    );
  }
}

/// Individual report item with download button
class RecentReportItem extends StatelessWidget {
  const RecentReportItem({
    super.key,
    required this.report,
    required this.onDownloadTap,
  });

  final Report report;
  final VoidCallback onDownloadTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final createdAt = report.createdAt;
    final dateText = createdAt != null
        ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
        : l10n.msg_noGenerationDate;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w12,
        vertical: BaseSize.h8,
      ),
      decoration: BoxDecoration(
        color: BaseColor.surfaceLight,
        borderRadius: BorderRadius.circular(BaseSize.w8),
        border: Border.all(color: BaseColor.neutral[200]!, width: 1),
      ),
      child: Row(
        children: [
          // Report icon based on format
          Container(
            width: BaseSize.w32,
            height: BaseSize.w32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _getFormatColor(report.format).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(BaseSize.w8),
            ),
            child: Icon(
              _getFormatIcon(report.format),
              color: _getFormatColor(report.format),
              size: BaseSize.w16,
            ),
          ),
          Gap.w12,
          // Report details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  report.name,
                  style: BaseTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: BaseColor.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  dateText,
                  style: BaseTypography.bodySmall.copyWith(
                    color: BaseColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Gap.w8,
          // Download button
          IconButton(
            onPressed: onDownloadTap,
            icon: Icon(AppIcons.download),
            iconSize: BaseSize.w20,
            color: BaseColor.primary,
            tooltip: l10n.tooltip_downloadReport,
            style: IconButton.styleFrom(
              backgroundColor: BaseColor.primary.withValues(alpha: 0.1),
              padding: EdgeInsets.all(BaseSize.w8),
              minimumSize: Size(BaseSize.w36, BaseSize.w36),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFormatIcon(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return AppIcons.document;
      case ReportFormat.xlsx:
        return AppIcons.barChart;
    }
  }

  Color _getFormatColor(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return BaseColor.error;
      case ReportFormat.xlsx:
        return BaseColor.success;
    }
  }
}
