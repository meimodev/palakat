import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/report.dart';
import 'package:palakat_shared/core/models/report_job.dart';

/// Section widget displaying recent reports created by the current user.
/// Shows pending/processing jobs at the top, then completed reports with download buttons.
class RecentReportsSection extends StatelessWidget {
  const RecentReportsSection({
    super.key,
    required this.reports,
    required this.isLoading,
    required this.error,
    required this.onDownloadTap,
    this.onViewTap,
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

  /// Callback when view button is tapped for a report
  final ValueChanged<Report>? onViewTap;

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
          _ReportsList(
            reports: reports,
            onDownloadTap: onDownloadTap,
            onViewTap: onViewTap,
          ),
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
      context.l10n.card_reportHistory_title,
      style: BaseTypography.labelLarge.copyWith(
        fontWeight: FontWeight.w600,
        color: BaseColor.textSecondary,
      ),
    );
  }
}

/// List of report items
class _ReportsList extends StatelessWidget {
  const _ReportsList({
    required this.reports,
    required this.onDownloadTap,
    required this.onViewTap,
  });

  final List<Report> reports;
  final ValueChanged<Report> onDownloadTap;
  final ValueChanged<Report>? onViewTap;

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
                onViewTap: onViewTap != null ? () => onViewTap!(report) : null,
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
    return ErrorDisplayWidget(
      message: message,
      onRetry: onRetry,
      padding: EdgeInsets.zero,
    );
  }
}

/// Individual report item with download button
class RecentReportItem extends StatelessWidget {
  const RecentReportItem({
    super.key,
    required this.report,
    required this.onDownloadTap,
    this.onViewTap,
  });

  final Report report;
  final VoidCallback onDownloadTap;
  final VoidCallback? onViewTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final createdAt = report.createdAt;
    final dateText = createdAt != null
        ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
        : l10n.msg_noGenerationDate;

    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.primary[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        side: BorderSide(color: BaseColor.neutral[200]!, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shouldStack =
              constraints.maxWidth < 360 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.1;

          final actions = Wrap(
            spacing: BaseSize.w8,
            runSpacing: BaseSize.h8,
            children: [
              if (report.format == ReportFormat.pdf && onViewTap != null)
                IconButton(
                  onPressed: onViewTap,
                  icon: Icon(AppIcons.openExternal),
                  iconSize: BaseSize.w20,
                  color: BaseColor.primary,
                  style: IconButton.styleFrom(
                    backgroundColor: BaseColor.primary[50],
                    padding: EdgeInsets.all(BaseSize.w10),
                    minimumSize: Size(BaseSize.w44, BaseSize.w44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    ),
                  ),
                ),
              IconButton(
                onPressed: onDownloadTap,
                icon: Icon(AppIcons.download),
                iconSize: BaseSize.w20,
                color: BaseColor.primary,
                tooltip: l10n.tooltip_downloadReport,
                style: IconButton.styleFrom(
                  backgroundColor: BaseColor.primary[50],
                  padding: EdgeInsets.all(BaseSize.w10),
                  minimumSize: Size(BaseSize.w44, BaseSize.w44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                  ),
                ),
              ),
            ],
          );

          final reportIcon = Container(
            width: BaseSize.w40,
            height: BaseSize.w40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _getFormatColor(report.format).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
            ),
            child: Icon(
              _getFormatIcon(report.format),
              color: _getFormatColor(report.format),
              size: BaseSize.w18,
            ),
          );

          final reportDetails = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                report.name,
                style: BaseTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: BaseColor.textPrimary,
                ),
                maxLines: shouldStack ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
              Gap.h6,
              Text(
                dateText,
                style: BaseTypography.bodyMedium.copyWith(
                  color: BaseColor.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: BaseSize.w12,
              vertical: BaseSize.h8,
            ),
            child: shouldStack
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          reportIcon,
                          Gap.w12,
                          Expanded(child: reportDetails),
                        ],
                      ),
                      Gap.h12,
                      Align(alignment: Alignment.centerLeft, child: actions),
                    ],
                  )
                : Row(
                    children: [
                      reportIcon,
                      Gap.w12,
                      Expanded(child: reportDetails),
                      Gap.w8,
                      actions,
                    ],
                  ),
          );
        },
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

    return Material(
      color: statusInfo.backgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        side: BorderSide(color: statusInfo.borderColor, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shouldStackMeta =
              constraints.maxWidth < 320 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.1;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: BaseSize.w12,
              vertical: BaseSize.h8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status icon
                Container(
                  width: BaseSize.w36,
                  height: BaseSize.w36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: statusInfo.iconBackgroundColor,
                    borderRadius: BorderRadius.circular(BaseSize.radiusMd),
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
                          fontWeight: FontWeight.w700,
                          color: BaseColor.textPrimary,
                        ),
                        maxLines: shouldStackMeta ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap.h4,
                      if (shouldStackMeta) ...[
                        Text(
                          statusInfo.statusText,
                          style: BaseTypography.bodyMedium.copyWith(
                            color: statusInfo.iconColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap.h4,
                        Text(
                          dateText,
                          style: BaseTypography.bodyMedium.copyWith(
                            color: BaseColor.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else
                        Wrap(
                          spacing: BaseSize.w4,
                          runSpacing: BaseSize.h4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              statusInfo.statusText,
                              style: BaseTypography.bodyMedium.copyWith(
                                color: statusInfo.iconColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '• $dateText',
                              style: BaseTypography.bodyMedium.copyWith(
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
        },
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
