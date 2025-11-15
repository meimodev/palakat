import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/operations_controller.dart';
import 'package:palakat/features/operations/presentations/widgets/widgets.dart';
import 'package:palakat/features/publishing/presentations/widgets/card_publishing_operation_widget.dart';

class OperationsScreen extends ConsumerWidget {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(operationsControllerProvider.notifier);
    final state = ref.watch(operationsControllerProvider);
    return ScaffoldWidget(
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
            child:
                (state.membership == null ||
                    state.membership!.membershipPositions.isEmpty)
                ? Container(
                    padding: EdgeInsets.all(BaseSize.w24),
                    decoration: BoxDecoration(
                      color: BaseColor.cardBackground1,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: BaseColor.neutral20, width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.work_off_outlined,
                          size: BaseSize.w48,
                          color: BaseColor.secondaryText,
                        ),
                        Gap.h12,
                        Text(
                          "No positions available",
                          textAlign: TextAlign.center,
                          style: BaseTypography.titleMedium.copyWith(
                            color: BaseColor.secondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap.h4,
                        Text(
                          "You don't have any operational positions yet",
                          textAlign: TextAlign.center,
                          style: BaseTypography.bodyMedium.copyWith(
                            color: BaseColor.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MembershipPositionsCardWidget(
                        membership: state.membership!,
                      ),
                      Gap.h16,
                      // Publishing Operations Section
                      Row(
                        children: [
                          Container(
                            width: BaseSize.w32,
                            height: BaseSize.w32,
                            decoration: BoxDecoration(
                              color: BaseColor.blue[100],
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.publish,
                              size: BaseSize.w16,
                              color: BaseColor.blue[700],
                            ),
                          ),
                          Gap.w12,
                          Expanded(
                            child: Text(
                              "Publishing",
                              style: BaseTypography.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: BaseColor.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap.h12,
                      CardPublishingOperationWidget(
                        title: "Publish Service",
                        description:
                            "Publish church services like youth service or general service",
                        onPressedCard: () {
                          context.pushNamed(
                            AppRoute.activityPublish,
                            extra: const RouteParam(
                              params: {
                                RouteParamKey.activityType:
                                    ActivityType.service,
                              },
                            ),
                          );
                        },
                      ),
                      Gap.h12,
                      CardPublishingOperationWidget(
                        title: "Publish Event",
                        description:
                            "Publish church events and special gatherings",
                        onPressedCard: () {
                          context.pushNamed(
                            AppRoute.activityPublish,
                            extra: const RouteParam(
                              params: {
                                RouteParamKey.activityType: ActivityType.event,
                              },
                            ),
                          );
                        },
                      ),
                      Gap.h12,
                      CardPublishingOperationWidget(
                        title: "Publish Announcement",
                        description:
                            "Publish important announcements and updates",
                        onPressedCard: () {
                          context.pushNamed(
                            AppRoute.activityPublish,
                            extra: const RouteParam(
                              params: {
                                RouteParamKey.activityType:
                                    ActivityType.announcement,
                              },
                            ),
                          );
                        },
                      ),
                      Gap.h24,

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.membership!.membershipPositions.length,
                        separatorBuilder: (_, _) => Gap.h16,
                        itemBuilder: (context, index) {
                          return OperationSegmentCardWidget(
                            position:
                                state.membership!.membershipPositions[index],
                          );
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
