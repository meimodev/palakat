import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/data/operation_models.dart';
import 'package:palakat/features/operations/presentations/operations_controller.dart';
import 'package:palakat/features/operations/presentations/widgets/widgets.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

/// Operations screen displaying user's positions and available operations.
/// Uses category-based organization with progressive disclosure.
///
/// Requirements: 2.1, 2.2, 2.3, 2.5, 3.4
class OperationsScreen extends ConsumerWidget {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(operationsControllerProvider.notifier);
    final state = ref.watch(operationsControllerProvider);

    return ScaffoldWidget(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ScreenTitleWidget.titleOnly(title: "Operations"),
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
          accountName: state.accountName ?? 'Member',
          onTap: () => _handleMembershipTap(context, state.membership!),
        ),
        Gap.h16,
        SupervisedActivitiesSection(
          activities: state.supervisedActivities,
          isLoading: state.loadingSupervisedActivities,
          error: state.supervisedActivitiesError,
          onSeeAllTap: () => _handleSeeAllSupervisedActivities(context),
          onActivityTap: (activity) => _handleActivityTap(context, activity),
          onRetry: () => controller.fetchSupervisedActivities(),
        ),
        // Add spacing only if section is visible
        if (state.supervisedActivities.isNotEmpty ||
            state.loadingSupervisedActivities ||
            state.supervisedActivitiesError != null)
          Gap.h16,
        // Category-based operation list (Requirement 2.2)
        _OperationCategoryList(
          categories: state.categories,
          onExpansionChanged: (categoryId, isExpanded) {
            controller.toggleCategoryExpansion(categoryId);
          },
          onOperationTap: (operation) {
            _handleOperationTap(context, operation);
          },
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
}

/// Empty state widget when no operations are available
/// Requirement 2.5
class _EmptyStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            Icons.work_off_outlined,
            size: BaseSize.w48,
            color: BaseColor.textSecondary,
          ),
          Gap.h12,
          Text(
            "No positions available",
            textAlign: TextAlign.center,
            style: BaseTypography.titleMedium.copyWith(
              color: BaseColor.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap.h4,
          Text(
            "You don't have any operational positions yet",
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
  });

  final List<OperationCategory> categories;
  final void Function(String categoryId, bool isExpanded) onExpansionChanged;
  final ValueChanged<OperationItem> onOperationTap;

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
        return OperationCategoryCard(
          category: category,
          onExpansionChanged: (isExpanded) {
            onExpansionChanged(category.id, isExpanded);
          },
          onOperationTap: onOperationTap,
        );
      },
    );
  }
}
