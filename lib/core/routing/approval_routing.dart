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
        return ApprovalDetailScreen(
          title: params['title'] as String? ?? '',
          description: params['description'] as String? ?? '',
          requestedBy: params['requestedBy'] as String? ?? '',
          requestDate: params['requestDate'] as String? ?? '',
          approvers:
              (params['approvers'] as List?)?.cast<Approver>() ?? const <Approver>[],
          currentMembershipId: params['currentMembershipId'] as int?,
        );
      },
    ),
  ],
);
