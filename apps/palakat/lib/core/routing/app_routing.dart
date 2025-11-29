import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/routing.dart';
import 'package:palakat/features/presentation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_routing.g.dart';

class AppRoute {
  static const String main = 'main';
  static const String viewAll = 'view-all';

  // home
  static const String home = 'home';

  //Rating
  static const String rating = 'rating';

  //Term and Condition
  static const String termAndCondition = 'term-and-condition';

  //Authentication
  static const String authentication = "authentication";
  static const String phoneInput = "phone-input";
  static const String otpVerification = "otp-verification";

  //Dashboard
  static const String dashboard = 'dashboard';
  static const String activityDetail = "activity-detail";

  //Account
  static const String account = 'account';
  static const String membership = 'membership';

  //song
  static const String songBook = 'song-book';
  static const String songBookDetail = 'song-book-detail';

  //operations
  static const String operations = 'operations';
  static const String activityPublish = "activity-publish";
  static const String publishingMap = "publish-map";
  static const String supervisedActivitiesList = "supervised-activities-list";
  static const String financeCreate = "finance-create";

  // approvals
  static const String approvals = 'approvals';
  static const String approvalDetail = 'approval-detail';
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter goRouter(Ref ref) {
  GoRouter.optionURLReflectsImperativeAPIs = true;
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/home',
    debugLogDiagnostics: kDebugMode,
    routerNeglect: true,
    observers: [if (kDebugMode) _GoRouterObserver()],
    routes: [
      GoRoute(
        path: '/home',
        name: AppRoute.home,
        builder: (context, state) => const HomeScreen(),
      ),
      authenticationRouting,
      dashboardRouting,
      songRouting,
      operationsRouting,
      approvalRouting,
      accountRouting,
    ],
  );
}

class RouteParam {
  final Map<String, dynamic> params;

  const RouteParam({required this.params});
}

class RouteParamKey {
  static const String activity = 'activity';
  static const String activityType = 'activityType';
  static const String song = 'song';
  static const String mapOperationType = 'mapOperationType';
  static const String location = 'location';
  static const String financeType = 'financeType';
  static const String isStandalone = 'isStandalone';
}

class _GoRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint(
      '🔀 GoRouter: PUSH ${route.settings.name ?? route.settings.toString()}',
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint(
      '🔀 GoRouter: POP ${route.settings.name ?? route.settings.toString()}',
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    debugPrint(
      '🔀 GoRouter: REPLACE ${oldRoute?.settings.name} -> ${newRoute?.settings.name}',
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint(
      '🔀 GoRouter: REMOVE ${route.settings.name ?? route.settings.toString()}',
    );
  }
}
