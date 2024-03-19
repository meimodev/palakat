import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// import 'package:palakat/core/config/app_config.dart';
import 'package:palakat/core/routing/routing.dart';

// import 'package:palakat/features/application.dart';
// import 'package:palakat/features/domain.dart';
import 'package:palakat/features/presentation.dart';

class AppRoute {
  static String main = 'main';
  static String viewAll = 'view-all';

  // splash
  static String splash = 'splash';

  // static String waiting = 'waiting';
  // static String welcome = 'welcome';

  // home
  static String home = 'home';


  //Rating
  static String rating = 'rating';

  //Term and Condition
  static String termAndCondition = 'term-and-condition';

  //Authentication
  static String authentication = "authentication";

  //Dashboard
  static String dashboard = 'dashboard';
  static String activityDetail = "activity-detail";

  // Publishing
  static String publishing = 'publishing';
  static String activityPublish = "activity-publish";
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>(
  (ref) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: kDebugMode,
      routerNeglect: true,
      routes: [
        GoRoute(
          path: '/',
          name: AppRoute.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/home',
          name: AppRoute.home,
          builder: (context, state) => const HomeScreen(),
        ),
        authenticationRouting,
        dashboardRouting,
        publishingRouting,
      ],
    );
  },
);

class RouteParam {
  final Map<String, dynamic> params;

  const RouteParam({required this.params});
}
