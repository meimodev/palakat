import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/data/operation_models.dart';
import 'package:palakat/features/operations/presentations/operations_controller.dart';
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

    return ScaffoldWidget(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTitleWidget.titleOnly(title: l10n.operations_title),
            Gap.h16,
            LoadingWrapper(
              loading: state.loadingScreen,
              hasError:
                  state.errorMessage != null && state.loadingScreen == false,
              errorMessage: state.errorMessage,
              onRetry: () => controller.fetchData(),
              shimmerPlaceholder: Column(
                children: [
                  PalakatShimmerPlaceholders.membershipCard(),
                  Gap.h16,
                  PalakatShimmerPlaceholders.listItemCard(),
                  Gap.h16,
                  PalakatShimmerPlaceholders.listItemCard(),
                ],
              ),
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

    // Empty state when no operations available (Requirement 2.5)
    if (state.membership == null ||
        state.membership!.membershipPositions.isEmpty) {
      return _EmptyStateWidget();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PositionSummaryCard(
          membership: state.membership!,
          accountName: state.accountName ?? l10n.admin_member_title,
          onTap: () => _handleMembershipTap(context, state.membership!),
        ),
        Gap.h16,
        SupervisedActivitiesSection(
          activities: state.supervisedActivities,
          isLoading: state.loadingSupervisedActivities,
          error: state.supervisedActivitiesError,
          isExpanded: state.supervisedActivitiesExpanded,
          onExpansionChanged: () =>
              controller.toggleSupervisedActivitiesExpansion(),
          onSeeAllTap: () => _handleSeeAllSupervisedActivities(context),
          onActivityTap: (activity) => _handleActivityTap(context, activity),
          onRetry: () => controller.fetchSupervisedActivities(),
        ),
        // Add spacing only if section is visible
        if (state.supervisedActivities.isNotEmpty ||
            state.loadingSupervisedActivities ||
            state.supervisedActivitiesError != null) ...[
          Gap.h8,
          Divider(),
          Gap.h8,
        ],

        // Category-based operation list (Requirement 2.2)
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
        ),
      ],
    );
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
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show loading indicator
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(l10n.err_loadFailed),
        duration: const Duration(seconds: 1),
      ),
    );

    final reportRepository = ref.read(reportRepositoryProvider);
    final result = await reportRepository.downloadReport(reportId: report.id!);

    result.when(
      onSuccess: (url) async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(l10n.err_somethingWentWrong),
              backgroundColor: BaseColor.error,
            ),
          );
        }
      },
      onFailure: (failure) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: BaseColor.error,
          ),
        );
      },
    );
  }

  Future<void> _handleReportView(
    BuildContext context,
    WidgetRef ref,
    Report report,
  ) async {
    final l10n = context.l10n;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (report.format != ReportFormat.pdf) return;
    if (report.id == null) return;

    final reportRepository = ref.read(reportRepositoryProvider);
    final result = await reportRepository.downloadReport(reportId: report.id!);

    result.when(
      onSuccess: (url) async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(l10n.err_somethingWentWrong),
              backgroundColor: BaseColor.error,
            ),
          );
        }
      },
      onFailure: (failure) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: BaseColor.error,
          ),
        );
      },
    );
  }
}

/// Empty state widget when no operations are available
/// Requirement 2.5
class _EmptyStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      // 8px grid spacing - 24px = 3 * 8px (Requirement 3.4)
      padding: EdgeInsets.all(BaseSize.w24),
      decoration: BoxDecoration(
        color: BaseColor.surfaceMedium,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BaseColor.neutral[200]!, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.workOff,
            size: BaseSize.w48,
            color: BaseColor.textSecondary,
          ),
          Gap.h12,
          Text(
            l10n.noData_positions,
            textAlign: TextAlign.center,
            style: BaseTypography.titleMedium.copyWith(
              color: BaseColor.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap.h4,
          Text(
            l10n.operations_noPositionsSubtitle,
            textAlign: TextAlign.center,
            style: BaseTypography.bodyMedium.copyWith(
              color: BaseColor.textSecondary,
            ),
          ),
        ],
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
        return OperationCategoryCard(
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
          onRecentReportsRetry: isReportsCategory ? onRecentReportsRetry : null,
          pendingReportJobs: isReportsCategory ? pendingReportJobs : null,
          isLoadingPendingReportJobs: isReportsCategory
              ? isLoadingPendingReportJobs
              : false,
        );
      },
    );
  }
}
