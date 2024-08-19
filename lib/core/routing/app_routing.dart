import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/routing.dart';
import 'package:palakat/features/presentation.dart';

class AppRoute {
  static const String main = 'main';
  static const String viewAll = 'view-all';

  // splash
  static const String splash = 'splash';

  // home
  static const String home = 'home';

  //Rating
  static const String rating = 'rating';

  //Term and Condition
  static const String termAndCondition = 'term-and-condition';

  //Authentication
  static const String authentication = "authentication";

  //Dashboard
  static const String dashboard = 'dashboard';
  static const String activityDetail = "activity-detail";

  // Publishing
  static const String publishing = 'publishing';
  static const String activityPublish = "activity-publish";
  static const String publishingMap = "publish-map";

  //Account
  static const String account = 'account';
  static const String membership = 'membership';

  //song
  static const String songBook = 'song-book';
  static const String songBookDetail = 'song-book-detail';

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
        songRouting,
        accountRouting,
      ],
    );
  },
);

class RouteParam {
  final Map<String, dynamic> params;

  const RouteParam({required this.params});
}
