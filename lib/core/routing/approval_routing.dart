import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat/core/models/models.dart';
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
        final approvalId = params['approvalId'] as int?;
        final currentMembershipId = params['currentMembershipId'] as int?;

        if (approvalId == null) {
          // Fallback if nothing was passed
          return const ApprovalScreen();
        }

        return ApprovalDetailScreen(
          approvalId: approvalId,
          currentMembershipId: currentMembershipId,
        );
      },
    ),
  ],
);
