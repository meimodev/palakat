import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/core/models/models.dart';

final operationsRouting = GoRoute(
  path: '/operations',
  name: AppRoute.operations,
  pageBuilder: (context, state) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion =
        (mediaQuery?.disableAnimations ?? false) ||
        (mediaQuery?.accessibleNavigation ?? false);

    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: const OperationsScreen(),
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
      path: 'report-generate',
      name: AppRoute.reportGenerate,
      pageBuilder: (context, state) {
        final mediaQuery = MediaQuery.maybeOf(context);
        final reduceMotion =
            (mediaQuery?.disableAnimations ?? false) ||
            (mediaQuery?.accessibleNavigation ?? false);

        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: const ReportGenerateScreen(),
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
      path: 'activity-publish',
      name: AppRoute.activityPublish,
      pageBuilder: (context, state) {
        final params = (state.extra as RouteParam?)?.params;
        ActivityType? type =
            params?[RouteParamKey.activityType] as ActivityType?;
        final typeName = state.uri.queryParameters[RouteParamKey.activityType];

        if (type == null && typeName != null) {
          for (final candidate in ActivityType.values) {
            if (candidate.name == typeName) {
              type = candidate;
              break;
            }
          }
        }

        assert(type != null, 'RouteParamKey.activityType cannot be null');

        final mediaQuery = MediaQuery.maybeOf(context);
        final reduceMotion =
            (mediaQuery?.disableAnimations ?? false) ||
            (mediaQuery?.accessibleNavigation ?? false);

        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: ActivityPublishScreen(type: type!),
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
      path: 'map',
      name: AppRoute.publishingMap,
      pageBuilder: (context, state) {
        final params = (state.extra as RouteParam?)?.params;
        final ot = params?[RouteParamKey.mapOperationType] as MapOperationType?;
        final locJson =
            params?[RouteParamKey.location] as Map<String, dynamic>?;
        final initialLocation = locJson != null
            ? Location.fromJson(locJson)
            : null;

        assert(ot != null, 'RouteParamKey.mapOperationType cannot be null');

        final mediaQuery = MediaQuery.maybeOf(context);
        final reduceMotion =
            (mediaQuery?.disableAnimations ?? false) ||
            (mediaQuery?.accessibleNavigation ?? false);

        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: MapScreen(
            mapOperationType: ot!,
            initialLocation: initialLocation,
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
    // Supervised Activities List Screen (Requirement 2.2)
    GoRoute(
      path: 'supervised-activities',
      name: AppRoute.supervisedActivitiesList,
      pageBuilder: (context, state) {
        final mediaQuery = MediaQuery.maybeOf(context);
        final reduceMotion =
            (mediaQuery?.disableAnimations ?? false) ||
            (mediaQuery?.accessibleNavigation ?? false);

        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SupervisedActivitiesListScreen(),
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
    // Finance Create Screen (Requirements 1.3, 4.1)
    GoRoute(
      path: 'finance-create',
      name: AppRoute.financeCreate,
      pageBuilder: (context, state) {
        final params = (state.extra as RouteParam?)?.params;
        final financeType = params?[RouteParamKey.financeType] as FinanceType?;
        final isStandalone =
            params?[RouteParamKey.isStandalone] as bool? ?? false;

        assert(financeType != null, 'RouteParamKey.financeType cannot be null');

        final mediaQuery = MediaQuery.maybeOf(context);
        final reduceMotion =
            (mediaQuery?.disableAnimations ?? false) ||
            (mediaQuery?.accessibleNavigation ?? false);

        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: FinanceCreateScreen(
            financeType: financeType!,
            isStandalone: isStandalone,
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
    // Members List Screen - View current church members
    GoRoute(
      path: 'members-list',
      name: AppRoute.membersList,
      pageBuilder: (context, state) {
        final mediaQuery = MediaQuery.maybeOf(context);
        final reduceMotion =
            (mediaQuery?.disableAnimations ?? false) ||
            (mediaQuery?.accessibleNavigation ?? false);

        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: const MembersListScreen(),
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
      path: 'member-birthdays',
      name: AppRoute.memberBirthdays,
      pageBuilder: (context, state) {
        final mediaQuery = MediaQuery.maybeOf(context);
        final reduceMotion =
            (mediaQuery?.disableAnimations ?? false) ||
            (mediaQuery?.accessibleNavigation ?? false);

        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: const MemberBirthdaysScreen(),
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
      path: 'member-detail/:membershipId',
      name: AppRoute.memberDetail,
      pageBuilder: (context, state) {
        final membershipIdStr = state.pathParameters['membershipId'];

        assert(
          membershipIdStr != null,
          'membershipId path parameter cannot be null',
        );

        final membershipId = int.parse(membershipIdStr!);
        final mediaQuery = MediaQuery.maybeOf(context);
        final reduceMotion =
            (mediaQuery?.disableAnimations ?? false) ||
            (mediaQuery?.accessibleNavigation ?? false);

        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: MemberDetailScreen(membershipId: membershipId),
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
    // Member Invite Screen - Invite new members to the church
    GoRoute(
      path: 'member-invite',
      name: AppRoute.memberInvite,
      pageBuilder: (context, state) {
        final mediaQuery = MediaQuery.maybeOf(context);
        final reduceMotion =
            (mediaQuery?.disableAnimations ?? false) ||
            (mediaQuery?.accessibleNavigation ?? false);

        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: const MemberInviteScreen(),
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
      path: 'member-create',
      name: AppRoute.memberCreate,
      pageBuilder: (context, state) {
        final mediaQuery = MediaQuery.maybeOf(context);
        final reduceMotion =
            (mediaQuery?.disableAnimations ?? false) ||
            (mediaQuery?.accessibleNavigation ?? false);

        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: const MemberCreateScreen(),
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
