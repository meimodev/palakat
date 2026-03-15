import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';

final accountRouting = GoRoute(
  path: '/account',
  name: AppRoute.account,
  pageBuilder: (context, state) {
    // Extract verified phone and account ID from extra parameter
    final extra = state.extra;
    String? verifiedPhone;
    int? accountId;
    String? firebaseIdToken;
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion =
        (mediaQuery?.disableAnimations ?? false) ||
        (mediaQuery?.accessibleNavigation ?? false);

    if (extra is Map<String, dynamic>) {
      verifiedPhone = extra['verifiedPhone'] as String?;
      accountId = extra['accountId'] as int?;
      firebaseIdToken = extra['firebaseIdToken'] as String?;
    } else if (extra is RouteParam) {
      verifiedPhone = extra.params['verifiedPhone'] as String?;
      accountId = extra.params['accountId'] as int?;
      firebaseIdToken = extra.params['firebaseIdToken'] as String?;
    }

    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: AccountScreen(
        verifiedPhone: verifiedPhone,
        accountId: accountId,
        firebaseIdToken: firebaseIdToken,
      ),
      transitionDuration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 260),
      reverseTransitionDuration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (reduceMotion) {
          return child;
        }

        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.025),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  },
  routes: [
    GoRoute(
      path: 'membership',
      name: AppRoute.membership,
      pageBuilder: (context, state) {
        // Extract membershipId from extra parameter
        final extra = state.extra;
        int? membershipId;
        final mediaQuery = MediaQuery.maybeOf(context);
        final reduceMotion =
            (mediaQuery?.disableAnimations ?? false) ||
            (mediaQuery?.accessibleNavigation ?? false);

        if (extra is Map<String, dynamic>) {
          membershipId = extra['membershipId'] as int?;
        } else if (extra is RouteParam) {
          membershipId = extra.params['membershipId'] as int?;
        }

        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: MembershipScreen(membershipId: membershipId),
          transitionDuration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 260),
          reverseTransitionDuration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 220),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (reduceMotion) {
              return child;
            }

            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeOutCubic,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.025),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
      },
    ),
  ],
);
