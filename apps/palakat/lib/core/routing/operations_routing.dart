import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/core/models/models.dart';

final operationsRouting = GoRoute(
  path: '/operations',
  name: AppRoute.operations,
  builder: (context, state) => const OperationsScreen(),
  routes: [
    GoRoute(
      path: 'report-generate',
      name: AppRoute.reportGenerate,
      builder: (context, state) {
        final params = (state.extra as RouteParam?)?.params;
        final type = params?[RouteParamKey.reportType] as ReportGenerateType?;
        final normalizedType = type == ReportGenerateType.outcomingDocument
            ? ReportGenerateType.incomingDocument
            : type;
        return ReportGenerateScreen(initialReportType: normalizedType);
      },
    ),
    GoRoute(
      path: 'activity-publish',
      name: AppRoute.activityPublish,
      builder: (context, state) {
        final params = (state.extra as RouteParam?)?.params;
        final type = params?[RouteParamKey.activityType] as ActivityType?;

        assert(type != null, 'RouteParamKey.activityType cannot be null');

        return ActivityPublishScreen(type: type!);
      },
    ),
    GoRoute(
      path: 'map',
      name: AppRoute.publishingMap,
      builder: (context, state) {
        final params = (state.extra as RouteParam?)?.params;
        final ot = params?[RouteParamKey.mapOperationType] as MapOperationType?;
        final locJson =
            params?[RouteParamKey.location] as Map<String, dynamic>?;
        final initialLocation = locJson != null
            ? Location.fromJson(locJson)
            : null;

        assert(ot != null, 'RouteParamKey.mapOperationType cannot be null');

        return MapScreen(
          mapOperationType: ot!,
          initialLocation: initialLocation,
        );
      },
    ),
    // Supervised Activities List Screen (Requirement 2.2)
    GoRoute(
      path: 'supervised-activities',
      name: AppRoute.supervisedActivitiesList,
      builder: (context, state) => const SupervisedActivitiesListScreen(),
    ),
    // Finance Create Screen (Requirements 1.3, 4.1)
    GoRoute(
      path: 'finance-create',
      name: AppRoute.financeCreate,
      builder: (context, state) {
        final params = (state.extra as RouteParam?)?.params;
        final financeType = params?[RouteParamKey.financeType] as FinanceType?;
        final isStandalone =
            params?[RouteParamKey.isStandalone] as bool? ?? false;

        assert(financeType != null, 'RouteParamKey.financeType cannot be null');

        return FinanceCreateScreen(
          financeType: financeType!,
          isStandalone: isStandalone,
        );
      },
    ),
    // Members List Screen - View current church members
    GoRoute(
      path: 'members-list',
      name: AppRoute.membersList,
      builder: (context, state) => const MembersListScreen(),
    ),
    GoRoute(
      path: 'member-birthdays',
      name: AppRoute.memberBirthdays,
      builder: (context, state) => const MemberBirthdaysScreen(),
    ),
    GoRoute(
      path: 'member-detail/:membershipId',
      name: AppRoute.memberDetail,
      builder: (context, state) {
        final membershipIdStr = state.pathParameters['membershipId'];

        assert(
          membershipIdStr != null,
          'membershipId path parameter cannot be null',
        );

        final membershipId = int.parse(membershipIdStr!);
        return MemberDetailScreen(membershipId: membershipId);
      },
    ),
    // Member Invite Screen - Invite new members to the church
    GoRoute(
      path: 'member-invite',
      name: AppRoute.memberInvite,
      builder: (context, state) => const MemberInviteScreen(),
    ),
    GoRoute(
      path: 'member-create',
      name: AppRoute.memberCreate,
      builder: (context, state) => const MemberCreateScreen(),
    ),
  ],
);
