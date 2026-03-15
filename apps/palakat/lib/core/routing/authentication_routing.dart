import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';

final authenticationRouting = GoRoute(
  path: '/authentication',
  name: AppRoute.authentication,
  pageBuilder: (context, state) => _buildAuthPage(
    context: context,
    state: state,
    child: PhoneInputScreen(returnTo: state.uri.queryParameters['returnTo']),
    beginOffset: const Offset(0, 0.04),
  ),
  routes: [
    GoRoute(
      path: 'otp-verification',
      name: AppRoute.otpVerification,
      pageBuilder: (context, state) => _buildAuthPage(
        context: context,
        state: state,
        child: OtpVerificationScreen(
          returnTo: state.uri.queryParameters['returnTo'],
        ),
        beginOffset: const Offset(0.04, 0),
      ),
    ),
  ],
);

CustomTransitionPage<void> _buildAuthPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  required Offset beginOffset,
}) {
  final mediaQuery = MediaQuery.maybeOf(context);
  final reduceMotion =
      (mediaQuery?.disableAnimations ?? false) ||
      (mediaQuery?.accessibleNavigation ?? false);

  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 320),
    reverseTransitionDuration: reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (reduceMotion) {
        return child;
      }

      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
