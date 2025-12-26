import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/loading/shimmer_widgets.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/report.dart';
import 'package:palakat_shared/core/models/report_job.dart';
import 'package:palakat_shared/widgets.dart';

/// Section widget displaying recent reports created by the current user.
/// Shows pending/processing jobs at the top, then completed reports with download buttons.
class RecentReportsSection extends StatelessWidget {
  const RecentReportsSection({
    super.key,
    required this.reports,
    required this.isLoading,
    required this.error,
    required this.onDownloadTap,
    required this.onRetry,
    this.pendingJobs = const [],
    this.isLoadingPendingJobs = false,
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

  /// List of pending/processing report jobs
  final List<ReportJob> pendingJobs;

  /// Whether pending jobs are currently loading
  final bool isLoadingPendingJobs;

  @override
  Widget build(BuildContext context) {
    final hasContent = reports.isNotEmpty || pendingJobs.isNotEmpty;
    final isAnyLoading = isLoading || isLoadingPendingJobs;

    // Hide section when not loading, no error, and no content
    if (!isAnyLoading && error == null && !hasContent) {
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
    if (isLoading && reports.isEmpty && pendingJobs.isEmpty) {
      return LoadingShimmer(isLoading: true, child: _buildShimmerPlaceholder());
    }

    // Priority 3: Show pending jobs and reports list
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pending/Processing jobs first
        if (pendingJobs.isNotEmpty) _PendingJobsList(jobs: pendingJobs),
        // Completed reports
        if (reports.isNotEmpty)
          _ReportsList(reports: reports, onDownloadTap: onDownloadTap),
      ],
    );
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

/// List of pending/processing report jobs
class _PendingJobsList extends StatelessWidget {
  const _PendingJobsList({required this.jobs});

  final List<ReportJob> jobs;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: jobs
          .map(
            (job) => Padding(
              padding: EdgeInsets.only(bottom: BaseSize.w4),
              child: _PendingJobItem(job: job),
            ),
          )
          .toList(),
    );
  }
}

/// Individual pending/processing job item with status indicator
class _PendingJobItem extends StatelessWidget {
  const _PendingJobItem({required this.job});

  final ReportJob job;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final createdAt = job.createdAt;
    final dateText = createdAt != null
        ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
        : l10n.msg_noGenerationDate;

    final statusInfo = _getStatusInfo(context, job.status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w12,
        vertical: BaseSize.h8,
      ),
      decoration: BoxDecoration(
        color: statusInfo.backgroundColor,
        borderRadius: BorderRadius.circular(BaseSize.w8),
        border: Border.all(color: statusInfo.borderColor, width: 1),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: BaseSize.w32,
            height: BaseSize.w32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: statusInfo.iconBackgroundColor,
              borderRadius: BorderRadius.circular(BaseSize.w8),
            ),
            child: statusInfo.isAnimated
                ? SizedBox(
                    width: BaseSize.w16,
                    height: BaseSize.w16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: statusInfo.iconColor,
                    ),
                  )
                : Icon(
                    statusInfo.icon,
                    color: statusInfo.iconColor,
                    size: BaseSize.w16,
                  ),
          ),
          Gap.w12,
          // Job details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getJobName(context, job),
                  style: BaseTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: BaseColor.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      statusInfo.statusText,
                      style: BaseTypography.bodySmall.copyWith(
                        color: statusInfo.iconColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      ' • $dateText',
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getJobName(BuildContext context, ReportJob job) {
    final l10n = context.l10n;
    switch (job.type) {
      case ReportGenerateType.incomingDocument:
        return l10n.reportType_incomingDocument;
      case ReportGenerateType.outcomingDocument:
        return l10n.reportType_outcomingDocument;
      case ReportGenerateType.congregation:
        return l10n.reportType_congregation;
      case ReportGenerateType.services:
        return l10n.reportType_services;
      case ReportGenerateType.activity:
        return l10n.reportType_activity;
      case ReportGenerateType.financial:
        return l10n.reportType_financial;
    }
  }

  _StatusInfo _getStatusInfo(BuildContext context, ReportJobStatus status) {
    final l10n = context.l10n;
    switch (status) {
      case ReportJobStatus.pending:
        return _StatusInfo(
          icon: AppIcons.pending,
          iconColor: BaseColor.warning,
          iconBackgroundColor: BaseColor.warning.withValues(alpha: 0.12),
          backgroundColor: BaseColor.yellow.shade50,
          borderColor: BaseColor.yellow.shade200,
          statusText: l10n.jobStatus_pending,
          isAnimated: false,
        );
      case ReportJobStatus.processing:
        return _StatusInfo(
          icon: AppIcons.pending,
          iconColor: BaseColor.primary,
          iconBackgroundColor: BaseColor.primary.withValues(alpha: 0.12),
          backgroundColor: BaseColor.blue.shade50,
          borderColor: BaseColor.blue.shade200,
          statusText: l10n.jobStatus_processing,
          isAnimated: true,
        );
      case ReportJobStatus.completed:
        return _StatusInfo(
          icon: AppIcons.checkCircle,
          iconColor: BaseColor.success,
          iconBackgroundColor: BaseColor.success.withValues(alpha: 0.12),
          backgroundColor: BaseColor.green.shade50,
          borderColor: BaseColor.green.shade200,
          statusText: l10n.jobStatus_completed,
          isAnimated: false,
        );
      case ReportJobStatus.failed:
        return _StatusInfo(
          icon: AppIcons.error,
          iconColor: BaseColor.error,
          iconBackgroundColor: BaseColor.error.withValues(alpha: 0.12),
          backgroundColor: BaseColor.red.shade50,
          borderColor: BaseColor.red.shade200,
          statusText: l10n.jobStatus_failed,
          isAnimated: false,
        );
    }
  }
}

class _StatusInfo {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final String statusText;
  final bool isAnimated;

  const _StatusInfo({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.statusText,
    required this.isAnimated,
  });
}
