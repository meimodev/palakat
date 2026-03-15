import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';

/// GoRoute configuration for the settings screen.
///
/// Requirements: 1.1
final settingsRouting = GoRoute(
  path: '/settings',
  name: AppRoute.settings,
  pageBuilder: (context, state) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion =
        (mediaQuery?.disableAnimations ?? false) ||
        (mediaQuery?.accessibleNavigation ?? false);

    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: const SettingsScreen(),
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
      path: 'activity-alarms',
      name: AppRoute.alarmSettings,
      pageBuilder: (context, state) {
        final mediaQuery = MediaQuery.maybeOf(context);
        final reduceMotion =
            (mediaQuery?.disableAnimations ?? false) ||
            (mediaQuery?.accessibleNavigation ?? false);

        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: const AlarmSettingsScreen(),
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
