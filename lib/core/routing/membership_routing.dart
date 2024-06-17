import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';

final accountRouting = GoRoute(
  path: '/account',
  name: AppRoute.account,
  builder: (context, state) => const AccountScreen(),
  routes: [
    GoRoute(
      path: 'membership',
      name: AppRoute.membership,
      builder: (context, state) => const MembershipScreen(),
    ),
  ],
);
