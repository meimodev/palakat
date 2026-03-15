import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/core/constants/enums.dart';

final dashboardRouting = GoRoute(
  path: '/dashboard',
  name: AppRoute.dashboard,
  builder: (context, state) => const DashboardScreen(),
  routes: [
    GoRoute(
      path: 'view-all',
      name: AppRoute.viewAll,
      pageBuilder: (context, state) {
        final params = (state.extra as RouteParam?)?.params;
        final type = params?[RouteParamKey.activityType] as ActivityType?;
        final mediaQuery = MediaQuery.maybeOf(context);
        final reduceMotion =
            (mediaQuery?.disableAnimations ?? false) ||
            (mediaQuery?.accessibleNavigation ?? false);

        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: ViewAllScreen(activityType: type),
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
    GoRoute(
      path: 'activity-detail/:activityId',
      name: AppRoute.activityDetail,
      pageBuilder: (context, state) {
        final activityIdStr = state.pathParameters['activityId'];

        assert(
          activityIdStr != null,
          'activityId path parameter cannot be null',
        );

        final activityId = int.parse(activityIdStr!);

        // Check if navigating from approval context (Req 6.2, 6.3)
        final params = (state.extra as RouteParam?)?.params;
        final isFromApprovalContext =
            params?[RouteParamKey.isFromApprovalContext] as bool? ?? false;
        final mediaQuery = MediaQuery.maybeOf(context);
        final reduceMotion =
            (mediaQuery?.disableAnimations ?? false) ||
            (mediaQuery?.accessibleNavigation ?? false);

        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: ActivityDetailScreen(
            activityId: activityId,
            isFromApprovalContext: isFromApprovalContext,
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
    ),
    GoRoute(
      path: 'alarm-ring/:activityId',
      name: AppRoute.alarmRing,
      builder: (context, state) {
        final activityIdStr = state.pathParameters['activityId'];
        final activityId = int.tryParse(activityIdStr ?? '');
        final extra = state.extra as RouteParam?;
        final params = extra?.params ?? const <String, dynamic>{};

        if (activityId == null) {
          return const DashboardScreen();
        }

        return AlarmRingScreen(
          activityId: activityId,
          alarmAtUtcIso: params['alarmAtUtcIso'] as String?,
          title: params['title'] as String?,
          reminderName: params['reminderName'] as String?,
          reminderValue: params['reminderValue'] as String?,
          alarmKey: params['alarmKey'] as String?,
          notificationId: params['notificationId'] as int?,
        );
      },
    ),
  ],
);
