import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_admin/features/report/report.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  /// Shows report generation drawer
  void _showGenerateDrawer(String reportTitle, String description) {
    DrawerUtils.showDrawer(
      context: context,
      drawer: ReportGenerateDrawer(
        reportTitle: reportTitle,
        description: description,
        onClose: () => DrawerUtils.closeDrawer(context),
        onGenerate: (range) async {
          if (context.mounted) {
            // DrawerUtils.closeDrawer(context);
            // TODO: Call controller.generateReport() with proper data
            // AppSnackbars.showSuccess(
            //   context,
            //   title: 'Report Generated',
            //   message: 'Your report is being generated.',
            // );
            // ref.read(reportControllerProvider.notifier).refresh();
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
                    onGenerate: () => _showGenerateDrawer(
                      l10n.reportTitle_incomingDocument,
                      l10n.reportDesc_incomingDocument,
                    ),
                  ),
                  _GenerateCard(
                    title: l10n.reportType_congregation,
                    icon: Icons.groups_outlined,
                    color: Colors.purple,
                    onGenerate: () => _showGenerateDrawer(
                      l10n.reportTitle_congregation,
                      l10n.reportDesc_congregation,
                    ),
                  ),
                  _GenerateCard(
                    title: l10n.reportType_services,
                    icon: Icons.church_outlined,
                    color: Colors.green,
                    onGenerate: () => _showGenerateDrawer(
                      l10n.reportTitle_services,
                      l10n.reportDesc_services,
                    ),
                  ),
                  _GenerateCard(
                    title: l10n.reportType_activity,
                    icon: Icons.local_activity_outlined,
                    color: Colors.orange,
                    onGenerate: () => _showGenerateDrawer(
                      l10n.reportTitle_activity,
                      l10n.reportDesc_activity,
                    ),
                  ),
                ],
              ),
            ),

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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                report.file.url.split('/').last,
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
        title: '',
        flex: 1,
        cellBuilder: (ctx, report) {
          final theme = Theme.of(ctx);
          final l10n = ctx.l10n;
          return IconButton(
            onPressed: () async {
              if (report.id != null) {
                final url = Uri.tryParse(report.file.url);
                if (url == null) {
                  // ignore: use_build_context_synchronously
                  AppSnackbars.showError(
                    ctx,
                    title: l10n.msg_invalidUrl,
                    message: l10n.msg_cannotOpenReportFile,
                  );
                  return;
                }
                // ignore: use_build_context_synchronously
                AppSnackbars.showSuccess(
                  ctx,
                  title: l10n.msg_opening,
                  message: l10n.msg_openingReport(report.name),
                );
                try {
                  await launchUrl(url);
                } catch (_) {
                  // Swallow errors; optionally log if a logger is available
                }
              }
            },
            icon: const Icon(Icons.download),
            color: theme.colorScheme.primary,
            tooltip: l10n.tooltip_downloadReport,
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
