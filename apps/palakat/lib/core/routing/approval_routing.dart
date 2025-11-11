import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat/features/approval/presentations/approval_detail_screen.dart';

final approvalRouting = GoRoute(
  path: '/approvals',
  name: AppRoute.approvals,
  builder: (context, state) => const ApprovalScreen(),
  routes: [
    GoRoute(
      path: 'detail',
      name: AppRoute.approvalDetail,
      builder: (context, state) {
        final extra = state.extra as RouteParam?;
        final params = extra?.params ?? const <String, dynamic>{};
        final activityId = params['activityId'] as int?;
        final currentMembershipId = params['currentMembershipId'] as int?;

        if (activityId == null) {
          // Fallback if nothing was passed
          return const ApprovalScreen();
        }

        return ApprovalDetailScreen(
          activityId: activityId,
          currentMembershipId: currentMembershipId,
        );
      },
    ),
  ],
);
