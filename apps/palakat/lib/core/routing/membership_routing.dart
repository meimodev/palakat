import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';

final accountRouting = GoRoute(
  path: '/account',
  name: AppRoute.account,
  builder: (context, state) {
    // Extract verified phone from extra parameter
    final extra = state.extra;
    String? verifiedPhone;

    if (extra is Map<String, dynamic>) {
      verifiedPhone = extra['verifiedPhone'] as String?;
    } else if (extra is RouteParam) {
      verifiedPhone = extra.params['verifiedPhone'] as String?;
    }

    return AccountScreen(verifiedPhone: verifiedPhone);
  },
  routes: [
    GoRoute(
      path: 'membership',
      name: AppRoute.membership,
      builder: (context, state) => const MembershipScreen(),
    ),
  ],
);
