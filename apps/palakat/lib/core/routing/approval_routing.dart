import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/approval/presentations/approval_item.dart';
import 'package:palakat/features/approval/presentations/finance_approval_detail_screen.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/models.dart';
import 'package:palakat/features/approval/presentations/approval_detail_screen.dart';

final approvalRouting = GoRoute(
  path: '/approvals',
  name: AppRoute.approvals,
  pageBuilder: (context, state) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion =
        (mediaQuery?.disableAnimations ?? false) ||
        (mediaQuery?.accessibleNavigation ?? false);

    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: const ApprovalScreen(),
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
      path: 'detail',
      name: AppRoute.approvalDetail,
      pageBuilder: (context, state) {
        final extra = state.extra as RouteParam?;
        final params = extra?.params ?? const <String, dynamic>{};
        final approvalId = params['approvalId'] as int?;
        final approvalTypeName = params['approvalType'] as String?;
        final activityId = params['activityId'] as int?;
        final currentMembershipId = params['currentMembershipId'] as int?;
        final useGeneralFetch = params['useGeneralFetch'] == true;
        ApprovalSubjectType? approvalType;
        if (approvalTypeName != null) {
          for (final value in ApprovalSubjectType.values) {
            if (value.name == approvalTypeName) {
              approvalType = value;
              break;
            }
          }
        }
        final mediaQuery = MediaQuery.maybeOf(context);
        final reduceMotion =
            (mediaQuery?.disableAnimations ?? false) ||
            (mediaQuery?.accessibleNavigation ?? false);

        final child =
            approvalType == ApprovalSubjectType.revenue ||
                approvalType == ApprovalSubjectType.expense
            ? (approvalId == null
                  ? const ApprovalScreen()
                  : FinanceApprovalDetailScreen(
                      financeId: approvalId,
                      financeType: approvalType == ApprovalSubjectType.revenue
                          ? FinanceEntryType.revenue
                          : FinanceEntryType.expense,
                      currentMembershipId: currentMembershipId,
                      useGeneralFetch: useGeneralFetch,
                    ))
            : (activityId == null && approvalId == null
                  ? const ApprovalScreen()
                  : ApprovalDetailScreen(
                      activityId: activityId ?? approvalId!,
                      currentMembershipId: currentMembershipId,
                    ));

        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: child,
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
