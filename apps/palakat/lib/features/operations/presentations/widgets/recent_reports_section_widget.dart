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
    this.downloadedReportIds = const <int>{},
    this.downloadingReportIds = const <int>{},
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

  final Set<int> downloadedReportIds;

  final Set<int> downloadingReportIds;

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
      children: [Gap.h8, _SectionHeader(), Gap.h6, _buildContent(context)],
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
        if (pendingJobs.isNotEmpty && reports.isNotEmpty) Gap.h6,
        // Completed reports
        if (reports.isNotEmpty)
          _ReportsList(
            reports: reports,
            onDownloadTap: onDownloadTap,
            onViewTap: onViewTap,
            downloadedReportIds: downloadedReportIds,
            downloadingReportIds: downloadingReportIds,
          ),
      ],
    );
  }

  Widget _buildShimmerPlaceholder() {
    return PalakatShimmerPlaceholders.listSection();
  }
}

/// Section header with title
class _SectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.card_reportHistory_title,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.onSurfaceVariant,
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
    required this.downloadedReportIds,
    required this.downloadingReportIds,
  });

  final List<Report> reports;
  final ValueChanged<Report> onDownloadTap;
  final ValueChanged<Report>? onViewTap;
  final Set<int> downloadedReportIds;
  final Set<int> downloadingReportIds;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: reports
          .map(
            (report) => Padding(
              padding: EdgeInsets.only(bottom: 6.0),
              child: RecentReportItem(
                report: report,
                onDownloadTap: () => onDownloadTap(report),
                onViewTap: onViewTap != null ? () => onViewTap!(report) : null,
                isDownloaded: downloadedReportIds.contains(report.id),
                isDownloading: downloadingReportIds.contains(report.id),
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
    this.isDownloaded = false,
    this.isDownloading = false,
  });

  final Report report;
  final VoidCallback onDownloadTap;
  final VoidCallback? onViewTap;
  final bool isDownloaded;
  final bool isDownloading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final createdAt = report.createdAt;
    final dateText = createdAt != null
        ? createdAt.EddMMMyyyy
        : l10n.msg_noGenerationDate;

    return Material(
      color: AppColors.surfaceContainerLowest,
      elevation: 0,
      shadowColor: AppColors.onSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: AppColors.ghostBorder(0.08), width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shouldStack =
              constraints.maxWidth < 360 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.1;

          final actions = Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              // if (report.format == ReportFormat.pdf && onViewTap != null)
              //   IconButton(
              //     onPressed: onViewTap,
              //     icon: Icon(AppIcons.openExternal),
              //     iconSize: 14.0,
              //     color: AppColors.surface,
              //     style: IconButton.styleFrom(
              //       backgroundColor: AppColors.primary,
              //       padding: EdgeInsets.all(10.0),
              //       minimumSize: Size(44.0, 44.0),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(8.0),
              //       ),
              //     ),
              //   ),
              IconButton(
                onPressed: isDownloading ? null : onDownloadTap,
                icon: isDownloading
                    ? CompactLoadingWidget(
                        size: 14.0,
                        baseColor: AppColors.primary.withValues(alpha: 0.24),
                        highlightColor: AppColors.surface,
                      )
                    : Icon(
                        isDownloaded ? AppIcons.checkCircle : AppIcons.download,
                      ),
                iconSize: 14.0,
                color: AppColors.primary,
                tooltip: isDownloading
                    ? l10n.loading_please_wait
                    : isDownloaded
                    ? l10n.msg_openingReport(report.name)
                    : l10n.tooltip_downloadReport,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.14),
                  ),
                  padding: EdgeInsets.all(10.0),
                  minimumSize: Size(44.0, 44.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          );

          final reportIcon = Container(
            width: 36.0,
            height: 36.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _getFormatColor(report.format).withValues(alpha: 0.12),
              border: Border.all(
                color: _getFormatColor(report.format).withValues(alpha: 0.24),
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              _getFormatIcon(report.format),
              color: _getFormatColor(report.format),
              size: 16.0,
            ),
          );

          final reportDetails = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                report.name,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
                maxLines: shouldStack ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                dateText,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
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
        return AppColors.error;
      case ReportFormat.xlsx:
        return AppColors.success;
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
              padding: EdgeInsets.only(bottom: 6.0),
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
    final jobError = job.errorMessage?.trim();
    final failedMessage =
        job.status == ReportJobStatus.failed &&
            jobError != null &&
            jobError.isNotEmpty
        ? jobError
        : null;

    final statusInfo = _getStatusInfo(context, job.status);

    return Material(
      color: statusInfo.backgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: statusInfo.borderColor, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shouldStackMeta =
              constraints.maxWidth < 320 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.1;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status icon
                Container(
                  width: 32.0,
                  height: 32.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: statusInfo.iconBackgroundColor,
                    border: Border.all(color: statusInfo.borderColor),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: statusInfo.isAnimated
                      ? CompactLoadingWidget(
                          size: 16.0,
                          baseColor: statusInfo.iconColor.withValues(
                            alpha: 0.24,
                          ),
                          highlightColor: AppColors.surface,
                        )
                      : Icon(
                          statusInfo.icon,
                          color: statusInfo.iconColor,
                          size: 16.0,
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
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                        maxLines: shouldStackMeta ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap.h4,
                      if (failedMessage != null) ...[
                        Text(
                          failedMessage,
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: shouldStackMeta ? 3 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Gap.h4,
                      ],
                      if (shouldStackMeta) ...[
                        Text(
                          statusInfo.statusText,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                color: statusInfo.iconColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Gap.h4,
                        Text(
                          dateText,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: AppColors.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else
                        Wrap(
                          spacing: 4.0,
                          runSpacing: 4.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              statusInfo.statusText,
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(
                                    color: statusInfo.iconColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              '• $dateText',
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(color: AppColors.onSurfaceVariant),
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
    switch (job.type) {
      case ReportGenerateType.document:
        return _documentReportLabel(context, job.params);
      case ReportGenerateType.congregation:
        return context.l10n.reportType_congregation;
      case ReportGenerateType.services:
        return context.l10n.reportType_services;
      case ReportGenerateType.activity:
        return context.l10n.reportType_activity;
      case ReportGenerateType.financial:
        return context.l10n.reportType_financial;
    }
  }

  String _documentReportLabel(
    BuildContext context,
    Map<String, dynamic>? params,
  ) {
    final input = params?['input']?.toString().toUpperCase();
    return input == 'OUTCOME'
        ? context.l10n.reportType_outcomingDocument
        : context.l10n.reportType_incomingDocument;
  }

  _StatusInfo _getStatusInfo(BuildContext context, ReportJobStatus status) {
    final l10n = context.l10n;
    switch (status) {
      case ReportJobStatus.pending:
        return _StatusInfo(
          icon: AppIcons.pending,
          iconColor: AppColors.warning,
          iconBackgroundColor: AppColors.warning.withValues(alpha: 0.12),
          backgroundColor: AppColors.warning.shade50.withValues(alpha: 0.6),
          borderColor: AppColors.warning.shade100,
          statusText: l10n.jobStatus_pending,
          isAnimated: false,
        );
      case ReportJobStatus.processing:
        return _StatusInfo(
          icon: AppIcons.pending,
          iconColor: AppColors.primary,
          iconBackgroundColor: AppColors.primary.withValues(alpha: 0.12),
          backgroundColor: AppColors.primary.shade50.withValues(alpha: 0.55),
          borderColor: AppColors.primary.shade100,
          statusText: l10n.jobStatus_processing,
          isAnimated: true,
        );
      case ReportJobStatus.completed:
        return _StatusInfo(
          icon: AppIcons.checkCircle,
          iconColor: AppColors.success,
          iconBackgroundColor: AppColors.success.withValues(alpha: 0.12),
          backgroundColor: AppColors.success.shade50.withValues(alpha: 0.6),
          borderColor: AppColors.success.shade100,
          statusText: l10n.jobStatus_completed,
          isAnimated: false,
        );
      case ReportJobStatus.failed:
        return _StatusInfo(
          icon: AppIcons.error,
          iconColor: AppColors.error,
          iconBackgroundColor: AppColors.error.withValues(alpha: 0.12),
          backgroundColor: AppColors.error.shade50.withValues(alpha: 0.6),
          borderColor: AppColors.error.shade100,
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
