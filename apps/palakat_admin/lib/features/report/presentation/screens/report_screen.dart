import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_admin/features/report/report.dart';
import 'package:palakat_admin/core/utils/download_url.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/report_job.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  String _congregationSubtypeToApi(CongregationReportSubtype subtype) {
    switch (subtype) {
      case CongregationReportSubtype.wartaJemaat:
        return 'WARTA_JEMAAT';
      case CongregationReportSubtype.hutJemaat:
        return 'HUT_JEMAAT';
      case CongregationReportSubtype.keanggotaan:
        return 'KEANGGOTAAN';
    }
  }

  String _financialReportSubtypeToApi(FinancialReportSubtype subtype) {
    switch (subtype) {
      case FinancialReportSubtype.revenue:
        return 'REVENUE';
      case FinancialReportSubtype.expense:
        return 'EXPENSE';
      case FinancialReportSubtype.mutation:
        return 'MUTATION';
    }
  }

  /// Shows report generation drawer
  void _showGenerateDrawer(String reportType) {
    DrawerUtils.showDrawer(
      context: context,
      drawer: ReportGenerateDrawer(
        reportType: reportType,
        onClose: () => DrawerUtils.closeDrawer(context),
        onGenerate:
            (
              range,
              format,
              input,
              congregationSubtype,
              columnId,
              activityType,
              financialSubtype,
            ) async {
              if (!mounted) return;
              final l10n = context.l10n;
              final controller = ref.read(reportControllerProvider.notifier);
              try {
                final success = await controller.queueReport({
                  'type': reportType,
                  'format': format.name.toUpperCase(),
                  if (input != null) 'input': input.name.toUpperCase(),
                  if (congregationSubtype != null)
                    'congregationSubtype': _congregationSubtypeToApi(
                      congregationSubtype,
                    ),
                  if (activityType != null)
                    'activityType': activityType.name.toUpperCase(),
                  if (financialSubtype != null)
                    'financialSubtype': _financialReportSubtypeToApi(
                      financialSubtype,
                    ),
                  if (columnId != null) 'columnId': columnId,
                  if (range != null) 'startDate': range.start.toIso8601String(),
                  if (range != null) 'endDate': range.end.toIso8601String(),
                });

                if (!mounted) return;
                if (success) {
                  DrawerUtils.closeDrawer(context);
                  AppSnackbars.showSuccess(
                    context,
                    title: l10n.msg_reportQueuedShort,
                    message: l10n.msg_reportQueued,
                  );
                }
              } catch (e) {
                if (!mounted) return;
                AppSnackbars.showError(
                  context,
                  title: l10n.msg_reportFailed,
                  message: e.toString(),
                );
              }
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final ReportScreenState state = ref.watch(reportControllerProvider);
    final ReportController controller = ref.watch(
      reportControllerProvider.notifier,
    );

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.card_reportList_title,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.card_reportList_subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Generate Report Cards
            SurfaceCard(
              title: l10n.drawer_generateReport_title,
              // subtitle: 'Create custom report for different modules.',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _GenerateCard(
                    title: l10n.reportType_incomingDocument,
                    icon: Icons.mail_outline,
                    color: Colors.blue,
                    onGenerate: () => _showGenerateDrawer('INCOMING_DOCUMENT'),
                  ),
                  _GenerateCard(
                    title: l10n.reportType_congregation,
                    icon: Icons.groups_outlined,
                    color: Colors.purple,
                    onGenerate: () => _showGenerateDrawer('CONGREGATION'),
                  ),
                  _GenerateCard(
                    title: l10n.reportType_activity,
                    icon: Icons.local_activity_outlined,
                    color: Colors.orange,
                    onGenerate: () => _showGenerateDrawer('ACTIVITY'),
                  ),
                  _GenerateCard(
                    title: l10n.reportType_financial,
                    icon: Icons.account_balance_wallet_outlined,
                    color: Colors.teal,
                    onGenerate: () => _showGenerateDrawer('FINANCIAL'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Pending Report Jobs Section
            if (state.pendingReportJobs.isNotEmpty ||
                state.loadingPendingReportJobs)
              _PendingJobsSection(
                jobs: state.pendingReportJobs,
                isLoading: state.loadingPendingReportJobs,
                error: state.pendingReportJobsError,
                onRetry: () => controller.refresh(),
              ),

            if (state.pendingReportJobs.isNotEmpty ||
                state.loadingPendingReportJobs)
              const SizedBox(height: 24),

            // Report History
            SurfaceCard(
              title: l10n.card_reportHistory_title,
              // subtitle: 'View and manage previously generated reports.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTable<Report>(
                    loading: state.reports.isLoading,
                    data: state.reports.value?.data ?? [],
                    errorText: state.reports.hasError
                        ? state.reports.error.toString()
                        : null,
                    onRetry: () => controller.refresh(),
                    pagination: () {
                      final pageSize =
                          state.reports.value?.pagination.pageSize ?? 10;
                      final page = state.reports.value?.pagination.page ?? 1;
                      final total = state.reports.value?.pagination.total ?? 0;

                      final hasPrev =
                          state.reports.value?.pagination.hasPrev ?? false;
                      final hasNext =
                          state.reports.value?.pagination.hasNext ?? false;

                      return AppTablePaginationConfig(
                        total: total,
                        pageSize: pageSize,
                        page: page,
                        onPageSizeChanged: controller.onChangedPageSize,
                        onPageChanged: controller.onChangedPage,
                        onPrev: hasPrev ? controller.onPressedPrevPage : null,
                        onNext: hasNext ? controller.onPressedNextPage : null,
                      );
                    }.call(),
                    filtersConfig: AppTableFiltersConfig(
                      searchHint: l10n.hint_searchByReportName,
                      onSearchChanged: controller.onChangedSearch,
                      dateRangePreset: state.dateRangePreset,
                      customDateRange: state.customDateRange,
                      onDateRangePresetChanged:
                          controller.onChangedDateRangePreset,
                      onCustomDateRangeSelected:
                          controller.onCustomDateRangeSelected,
                      dropdownLabel: l10n.tbl_by,
                      dropdownOptions: {
                        'manual': l10n.opt_manual,
                        'system': l10n.opt_system,
                      },
                      dropdownValue: state.generatedByFilter?.name,
                      onDropdownChanged: (value) {
                        final generatedBy = value == null
                            ? null
                            : GeneratedBy.values.firstWhere(
                                (e) => e.name == value,
                              );
                        controller.onChangedGeneratedBy(generatedBy);
                      },
                    ),
                    columns: _buildTableColumns(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the table column configuration for the report table
  List<AppTableColumn<Report>> _buildTableColumns(BuildContext context) {
    final l10n = context.l10n;
    return [
      AppTableColumn<Report>(
        title: l10n.tbl_reportName,
        flex: 3,
        cellBuilder: (ctx, report) {
          final theme = Theme.of(ctx);
          return Text(
            report.name,
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          );
        },
      ),
      AppTableColumn<Report>(
        title: l10n.tbl_by,
        flex: 1,
        cellBuilder: (ctx, report) {
          final theme = Theme.of(ctx);
          final l10n = ctx.l10n;
          final isManual = report.generatedBy == GeneratedBy.manual;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isManual
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isManual ? l10n.opt_manual : l10n.opt_system,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isManual
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
      AppTableColumn<Report>(
        title: l10n.tbl_on,
        flex: 2,
        cellBuilder: (ctx, report) {
          final theme = Theme.of(ctx);
          if (report.createdAt == null) {
            return Text(ctx.l10n.lbl_na, style: theme.textTheme.bodyMedium);
          }
          final date = report.createdAt!.toCustomFormat("EEEE, dd MMMM yyyy");
          return Text(date, style: theme.textTheme.bodyMedium);
        },
      ),
      AppTableColumn<Report>(
        title: l10n.tbl_file,
        flex: 2,
        cellBuilder: (ctx, report) {
          final theme = Theme.of(ctx);
          final fileName =
              report.file.originalName ??
              (report.file.path != null
                  ? report.file.path!.split('/').last
                  : ctx.l10n.lbl_na);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                fileName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (report.file.sizeInKB > 0) ...[
                const SizedBox(height: 2),
                Text(
                  ctx.l10n.lbl_fileSizeMb(
                    (report.file.sizeInKB / 1024).toStringAsFixed(2),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          );
        },
      ),
      AppTableColumn<Report>(
        title: 'Format',
        flex: 1,
        cellBuilder: (ctx, report) {
          final theme = Theme.of(ctx);
          return Text(
            report.format.name.toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<Report>(
        title: '',
        flex: 1,
        cellBuilder: (ctx, report) {
          final theme = Theme.of(ctx);
          final l10n = ctx.l10n;
          final fileName = report.file.originalName;

          Future<void> openReport({required LaunchMode mode}) async {
            if (report.id == null) return;
            final controller = ref.read(reportControllerProvider.notifier);
            final resolved = await controller.downloadReport(report.id!);
            if (!ctx.mounted) return;
            final url = resolved != null ? Uri.tryParse(resolved) : null;
            if (url == null) {
              AppSnackbars.showError(
                ctx,
                title: l10n.msg_invalidUrl,
                message: l10n.msg_cannotOpenReportFile,
              );
              return;
            }
            AppSnackbars.showSuccess(
              ctx,
              title: l10n.msg_opening,
              message: l10n.msg_openingReport(report.name),
            );
            try {
              await launchUrl(url, mode: mode);
            } catch (_) {
              // Swallow errors; optionally log if a logger is available
            }
          }

          Future<void> downloadReport() async {
            if (report.id == null) return;
            final controller = ref.read(reportControllerProvider.notifier);
            final resolved = await controller.downloadReport(report.id!);
            if (!ctx.mounted) return;
            final url = resolved != null ? Uri.tryParse(resolved) : null;
            if (url == null) {
              AppSnackbars.showError(
                ctx,
                title: l10n.msg_invalidUrl,
                message: l10n.msg_cannotOpenReportFile,
              );
              return;
            }
            AppSnackbars.showSuccess(
              ctx,
              title: l10n.msg_opening,
              message: l10n.msg_openingReport(report.name),
            );
            try {
              await triggerBrowserDownload(url, filename: fileName);
            } catch (_) {
              // Swallow errors; optionally log if a logger is available
            }
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (report.format == ReportFormat.pdf)
                IconButton(
                  onPressed: () => openReport(mode: LaunchMode.platformDefault),
                  icon: const Icon(Icons.open_in_new),
                  color: theme.colorScheme.primary,
                  visualDensity: VisualDensity.compact,
                ),
              IconButton(
                onPressed: downloadReport,
                icon: const Icon(Icons.download),
                color: theme.colorScheme.primary,
                tooltip: l10n.tooltip_downloadReport,
                visualDensity: VisualDensity.compact,
              ),
            ],
          );
        },
      ),
    ];
  }
}

class _GenerateCard extends StatelessWidget {
  const _GenerateCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onGenerate,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onGenerate,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(title, style: theme.textTheme.bodySmall?.copyWith()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Section widget displaying pending/processing report jobs
class _PendingJobsSection extends StatelessWidget {
  const _PendingJobsSection({
    required this.jobs,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final List<ReportJob> jobs;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SurfaceCard(
      title: l10n.card_pendingJobs_title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLoading && jobs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (error != null && jobs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    error!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: onRetry, child: Text(l10n.btn_retry)),
                ],
              ),
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: jobs.map((job) => _PendingJobCard(job: job)).toList(),
            ),
        ],
      ),
    );
  }
}

/// Individual pending job card with status indicator
class _PendingJobCard extends StatelessWidget {
  const _PendingJobCard({required this.job});

  final ReportJob job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final statusInfo = _getStatusInfo(context, job.status);

    final createdAt = job.createdAt;
    final dateText = createdAt != null
        ? createdAt.toCustomFormat("dd MMM yyyy, HH:mm")
        : l10n.lbl_na;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusInfo.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusInfo.borderColor),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: statusInfo.iconBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: statusInfo.isAnimated
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: statusInfo.iconColor,
                    ),
                  )
                : Icon(statusInfo.icon, color: statusInfo.iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          // Job details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getJobName(context, job),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusInfo.iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusInfo.statusText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusInfo.iconColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dateText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
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
    final theme = Theme.of(context);
    switch (status) {
      case ReportJobStatus.pending:
        return _StatusInfo(
          icon: Icons.hourglass_empty,
          iconColor: Colors.orange,
          iconBackgroundColor: Colors.orange.withValues(alpha: 0.12),
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade200,
          statusText: l10n.jobStatus_pending,
          isAnimated: false,
        );
      case ReportJobStatus.processing:
        return _StatusInfo(
          icon: Icons.sync,
          iconColor: theme.colorScheme.primary,
          iconBackgroundColor: theme.colorScheme.primary.withValues(
            alpha: 0.12,
          ),
          backgroundColor: theme.colorScheme.primaryContainer.withValues(
            alpha: 0.3,
          ),
          borderColor: theme.colorScheme.primary.withValues(alpha: 0.3),
          statusText: l10n.jobStatus_processing,
          isAnimated: true,
        );
      case ReportJobStatus.completed:
        return _StatusInfo(
          icon: Icons.check_circle,
          iconColor: Colors.green,
          iconBackgroundColor: Colors.green.withValues(alpha: 0.12),
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade200,
          statusText: l10n.jobStatus_completed,
          isAnimated: false,
        );
      case ReportJobStatus.failed:
        return _StatusInfo(
          icon: Icons.error,
          iconColor: theme.colorScheme.error,
          iconBackgroundColor: theme.colorScheme.error.withValues(alpha: 0.12),
          backgroundColor: theme.colorScheme.errorContainer.withValues(
            alpha: 0.3,
          ),
          borderColor: theme.colorScheme.error.withValues(alpha: 0.3),
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
