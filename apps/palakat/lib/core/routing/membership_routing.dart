import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';

final accountRouting = GoRoute(
  path: '/account',
  name: AppRoute.account,
  builder: (context, state) {
    // Extract verified phone and account ID from extra parameter
    final extra = state.extra;
    String? verifiedPhone;
    int? accountId;

    if (extra is Map<String, dynamic>) {
      verifiedPhone = extra['verifiedPhone'] as String?;
      accountId = extra['accountId'] as int?;
    } else if (extra is RouteParam) {
      verifiedPhone = extra.params['verifiedPhone'] as String?;
      accountId = extra.params['accountId'] as int?;
    }

    return AccountScreen(verifiedPhone: verifiedPhone, accountId: accountId);
  },
  routes: [
    GoRoute(
      path: 'membership',
      name: AppRoute.membership,
      builder: (context, state) {
        // Extract membershipId from extra parameter
        final extra = state.extra;
        int? membershipId;

        if (extra is Map<String, dynamic>) {
          membershipId = extra['membershipId'] as int?;
        } else if (extra is RouteParam) {
          membershipId = extra.params['membershipId'] as int?;
        }

        return MembershipScreen(membershipId: membershipId);
      },
    ),
  ],
);
