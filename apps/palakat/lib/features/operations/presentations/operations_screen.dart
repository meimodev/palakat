import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/data/operation_models.dart';
import 'package:palakat/features/operations/presentations/operations_controller.dart';
import 'package:palakat/features/operations/presentations/operations_motion_widget.dart';
import 'package:palakat/features/operations/presentations/widgets/widgets.dart';
import 'package:palakat/features/report/presentations/report_generate/report_generate_controller.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/core/models/report_job.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:url_launcher/url_launcher.dart';

/// Operations screen displaying user's positions and available operations.
/// Uses category-based organization with progressive disclosure.
///
/// Requirements: 2.1, 2.2, 2.3, 2.5, 3.4
class OperationsScreen extends ConsumerStatefulWidget {
  const OperationsScreen({super.key});

  @override
  ConsumerState<OperationsScreen> createState() => _OperationsScreenState();
}

class _OperationsScreenState extends ConsumerState<OperationsScreen> {
  final Set<int> _cachedReportIds = <int>{};
  final Set<int> _downloadingReportIds = <int>{};
  String _cachedReportsSignature = '';
  bool _isSyncingCachedReports = false;

  @override
  void initState() {
    super.initState();
    // Listen for report generation state changes to refresh report data
    Future.microtask(() {
      ref.listen<ReportGenerateState>(reportGenerateControllerProvider, (
        previous,
        next,
      ) {
        // Refresh report data when a report job was just queued
        // (isGenerating changed from true to false and no error)
        if (previous?.isGenerating == true &&
            next.isGenerating == false &&
            next.errorMessage == null) {
          ref.read(operationsControllerProvider.notifier).refreshReportData();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.read(operationsControllerProvider.notifier);
    final state = ref.watch(operationsControllerProvider);

    _scheduleCachedReportSync(state.recentReports);

    return ScaffoldWidget(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OperationsReveal(
              child: ScreenTitleWidget.titleOnly(title: l10n.operations_title),
            ),
            Gap.h16,
            LoadingWrapper(
              loading: state.loadingScreen,
              hasError:
                  state.errorMessage != null && state.loadingScreen == false,
              errorMessage: state.errorMessage,
              onRetry: () => controller.fetchData(),
              shimmerPlaceholder:
                  PalakatShimmerPlaceholders.operationsOverview(),
              child: _buildContent(context, ref, state, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    dynamic state,
    OperationsController controller,
  ) {
    final l10n = context.l10n;
    final hasEnabledOperations = (state.categories as List<OperationCategory>)
        .any(
          (category) =>
              category.operations.any((operation) => operation.isEnabled),
        );

    // Empty state when no operations available (Requirement 2.5)
    if (state.membership == null || !hasEnabledOperations) {
      return OperationsAnimatedPresence(
        visible: true,
        child: _EmptyStateWidget(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OperationsReveal(
          delay: const Duration(milliseconds: 40),
          child: PositionSummaryCard(
            membership: state.membership!,
            accountName: state.accountName ?? l10n.admin_member_title,
            onTap: () => _handleMembershipTap(context, state.membership!),
          ),
        ),
        Gap.h4,
        if (state.supervisedActivities.isNotEmpty ||
            state.loadingSupervisedActivities ||
            state.supervisedActivitiesError != null) ...[
          Gap.h4,
          OperationsReveal(
            delay: Duration(
              milliseconds: 80 + (((state.categories as List).length) * 40),
            ),
            child: SupervisedActivitiesSection(
              activities: state.supervisedActivities,
              isLoading: state.loadingSupervisedActivities,
              error: state.supervisedActivitiesError,
              onSeeAllTap: () => _handleSeeAllSupervisedActivities(context),
              onActivityTap: (activity) =>
                  _handleActivityTap(context, activity),
              onRetry: () => controller.fetchSupervisedActivities(),
            ),
          ),
        ],
        Gap.h16,
        _OperationCategoryList(
          categories: state.categories,
          onExpansionChanged: (categoryId, isExpanded) {
            controller.toggleCategoryExpansion(categoryId);
          },
          onOperationTap: (operation) {
            _handleOperationTap(context, operation);
          },
          recentReports: state.recentReports,
          isLoadingRecentReports: state.loadingRecentReports,
          recentReportsError: state.recentReportsError,
          onReportDownloadTap: (report) =>
              _handleReportDownload(context, ref, report),
          onReportViewTap: (report) => _handleReportView(context, ref, report),
          onRecentReportsRetry: () => controller.fetchReportData(),
          pendingReportJobs: state.pendingReportJobs,
          isLoadingPendingReportJobs: state.loadingPendingReportJobs,
          downloadedReportIds: _cachedReportIds,
          downloadingReportIds: _downloadingReportIds,
        ),
      ],
    );
  }

  String _reportCacheSignature(List<Report> reports) {
    return reports
        .map((report) => '${report.id ?? 'null'}:${report.fileId}')
        .join('|');
  }

  void _scheduleCachedReportSync(List<Report> reports) {
    final signature = _reportCacheSignature(reports);
    if (_isSyncingCachedReports || signature == _cachedReportsSignature) {
      return;
    }

    _isSyncingCachedReports = true;
    Future.microtask(() => _syncCachedReportIds(reports, signature));
  }

  Future<void> _syncCachedReportIds(
    List<Report> reports,
    String signature,
  ) async {
    final reportRepository = ref.read(reportRepositoryProvider);
    final cachedIds = <int>{};

    for (final report in reports) {
      final reportId = report.id;
      if (reportId == null) {
        continue;
      }

      final result = await reportRepository.isReportCached(report: report);
      bool isCached = false;
      result.when(onSuccess: (value) => isCached = value, onFailure: (_) {});
      if (isCached) {
        cachedIds.add(reportId);
      }
    }

    if (!mounted) {
      _isSyncingCachedReports = false;
      return;
    }

    setState(() {
      _cachedReportIds
        ..clear()
        ..addAll(cachedIds);
      _cachedReportsSignature = signature;
    });
    _isSyncingCachedReports = false;
  }

  void _setReportDownloading(int reportId, bool isDownloading) {
    if (!context.mounted) {
      return;
    }

    setState(() {
      if (isDownloading) {
        _downloadingReportIds.add(reportId);
      } else {
        _downloadingReportIds.remove(reportId);
      }
    });
  }

  void _markReportCached(int reportId) {
    if (!context.mounted) {
      return;
    }

    setState(() {
      _cachedReportIds.add(reportId);
    });
  }

  void _showReportError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<ReportFileHandle?> _resolveReportHandle(
    BuildContext context,
    WidgetRef ref,
    Report report, {
    bool forceRedownload = false,
  }) async {
    final reportRepository = ref.read(reportRepositoryProvider);
    final result = await reportRepository.resolveReportFile(
      report: report,
      forceRedownload: forceRedownload,
    );

    ReportFileHandle? fileHandle;
    result.when(
      onSuccess: (value) => fileHandle = value,
      onFailure: (failure) => _showReportError(context, failure.message),
    );
    return fileHandle;
  }

  Future<bool> _openReportHandle(
    ReportFileHandle fileHandle, {
    required LaunchMode mode,
  }) async {
    final uri = Uri.tryParse(fileHandle.uri);
    if (uri == null) {
      return false;
    }

    try {
      if (uri.scheme == 'file') {
        final result = await OpenFilex.open(uri.toFilePath());
        return result.type == ResultType.done;
      }
      if (!await canLaunchUrl(uri)) {
        return false;
      }
      return await launchUrl(uri, mode: mode);
    } catch (_) {
      return false;
    }
  }

  void _handleOperationTap(BuildContext context, OperationItem operation) {
    if (!operation.isEnabled) return;

    // Navigate to the operation's route
    if (operation.routeParams != null && operation.routeParams!.isNotEmpty) {
      context.pushNamed(
        operation.routeName,
        extra: RouteParam(params: operation.routeParams!),
      );
    } else {
      context.pushNamed(operation.routeName);
    }
  }

  /// Navigates to the activity detail screen
  /// Requirement 1.4
  void _handleActivityTap(BuildContext context, Activity activity) {
    context.pushNamed(
      AppRoute.activityDetail,
      pathParameters: {'activityId': activity.id.toString()},
    );
  }

  /// Navigates to the supervised activities list screen
  /// Requirement 2.2
  void _handleSeeAllSupervisedActivities(BuildContext context) {
    context.pushNamed(AppRoute.supervisedActivitiesList);
  }

  /// Navigates to the membership screen with membership data
  void _handleMembershipTap(BuildContext context, Membership membership) {
    context.pushNamed(
      AppRoute.membership,
      extra: RouteParam(params: {'membershipId': membership.id}),
    );
  }

  /// Handles report download by fetching download URL and opening it
  Future<void> _handleReportDownload(
    BuildContext context,
    WidgetRef ref,
    Report report,
  ) async {
    final l10n = context.l10n;
    final reportId = report.id;

    if (reportId == null) {
      _showReportError(context, l10n.err_somethingWentWrong);
      return;
    }

    if (_downloadingReportIds.contains(reportId)) {
      return;
    }

    _setReportDownloading(reportId, true);
    try {
      final fileHandle = await _resolveReportHandle(context, ref, report);
      if (fileHandle == null) {
        return;
      }

      var opened = await _openReportHandle(
        fileHandle,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && fileHandle.fromCache) {
        if (!context.mounted) {
          return;
        }
        final refreshedHandle = await _resolveReportHandle(
          context,
          ref,
          report,
          forceRedownload: true,
        );
        if (refreshedHandle != null) {
          opened = await _openReportHandle(
            refreshedHandle,
            mode: LaunchMode.externalApplication,
          );
        }
      }

      if (!context.mounted) {
        return;
      }

      if (!opened) {
        _showReportError(context, l10n.err_somethingWentWrong);
        return;
      }

      _markReportCached(reportId);
    } finally {
      _setReportDownloading(reportId, false);
    }
  }

  Future<void> _handleReportView(
    BuildContext context,
    WidgetRef ref,
    Report report,
  ) async {
    final l10n = context.l10n;

    if (report.format != ReportFormat.pdf) return;
    final reportId = report.id;
    if (reportId == null || _downloadingReportIds.contains(reportId)) return;

    final fileHandle = await _resolveReportHandle(context, ref, report);
    if (fileHandle == null) {
      return;
    }

    var opened = await _openReportHandle(
      fileHandle,
      mode: LaunchMode.platformDefault,
    );

    if (!opened && fileHandle.fromCache) {
      if (!context.mounted) {
        return;
      }
      final refreshedHandle = await _resolveReportHandle(
        context,
        ref,
        report,
        forceRedownload: true,
      );
      if (refreshedHandle != null) {
        opened = await _openReportHandle(
          refreshedHandle,
          mode: LaunchMode.platformDefault,
        );
      }
    }

    if (!context.mounted) {
      return;
    }

    if (!opened) {
      _showReportError(context, l10n.err_somethingWentWrong);
      return;
    }

    _markReportCached(reportId);
  }
}

/// Empty state widget when no operations are available
/// Requirement 2.5
class _EmptyStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      color: AppColors.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: AppColors.neutral, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.0,
              height: 56.0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16.0),
              ),
              alignment: Alignment.center,
              child: Icon(
                AppIcons.workOff,
                size: 24.0,
                color: AppColors.onPrimary,
              ),
            ),
            Gap.h12,
            Text(
              l10n.noData_positions,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap.h4,
            Text(
              l10n.operations_noPositionsSubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List of operation categories with collapsible sections
/// Requirements: 2.2, 2.3
class _OperationCategoryList extends StatelessWidget {
  const _OperationCategoryList({
    required this.categories,
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
    this.downloadedReportIds = const <int>{},
    this.downloadingReportIds = const <int>{},
  });

  final List<OperationCategory> categories;
  final void Function(String categoryId, bool isExpanded) onExpansionChanged;
  final ValueChanged<OperationItem> onOperationTap;
  final List<Report>? recentReports;
  final bool isLoadingRecentReports;
  final String? recentReportsError;
  final ValueChanged<Report>? onReportDownloadTap;
  final ValueChanged<Report>? onReportViewTap;
  final VoidCallback? onRecentReportsRetry;
  final List<ReportJob>? pendingReportJobs;
  final bool isLoadingPendingReportJobs;
  final Set<int> downloadedReportIds;
  final Set<int> downloadingReportIds;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      // 8px grid spacing (Requirement 3.4)
      separatorBuilder: (context, index) => Gap.h8,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isReportsCategory = category.id == 'reports';
        return OperationsReveal(
          key: ValueKey('operations-category-${category.id}'),
          delay: Duration(milliseconds: 70 + (index * 40)),
          child: OperationCategoryCard(
            category: category,
            onExpansionChanged: (isExpanded) {
              onExpansionChanged(category.id, isExpanded);
            },
            onOperationTap: onOperationTap,
            recentReports: isReportsCategory ? recentReports : null,
            isLoadingRecentReports: isReportsCategory
                ? isLoadingRecentReports
                : false,
            recentReportsError: isReportsCategory ? recentReportsError : null,
            onReportDownloadTap: isReportsCategory ? onReportDownloadTap : null,
            onReportViewTap: isReportsCategory ? onReportViewTap : null,
            onRecentReportsRetry: isReportsCategory
                ? onRecentReportsRetry
                : null,
            pendingReportJobs: isReportsCategory ? pendingReportJobs : null,
            isLoadingPendingReportJobs: isReportsCategory
                ? isLoadingPendingReportJobs
                : false,
            downloadedReportIds: isReportsCategory
                ? downloadedReportIds
                : const <int>{},
            downloadingReportIds: isReportsCategory
                ? downloadingReportIds
                : const <int>{},
          ),
        );
      },
    );
  }
}
