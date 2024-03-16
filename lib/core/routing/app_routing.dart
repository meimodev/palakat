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
  static String dashboard = 'dashboard';
  static String viewAll = 'view-all';

  // splash
  static String splash = 'splash';

  // static String waiting = 'waiting';
  // static String welcome = 'welcome';

  // home
  static String home = 'home';

  // authentication
  static String login = 'login';
  static String signup = "signup";
  static String verifyEmail = "verify-email";
  static String forgotPassword = "forgot-password";
  static String resetPassword = "reset-password";
  static String registration = 'registration';

  // // account
  // static String biometric = 'biometric';
  // static String language = 'language';
  // static String changePassword = 'change-password';
  // static String help = 'help';
  // static String profile = 'profile';
  // static String patientList = 'patient-list';
  // static String patientDetail = 'patient-detail';
  // static String patientForm = 'patient-form';
  // static String addressList = 'address-list';
  // static String addressForm = 'address-form';
  // static String addressSearch = 'address-search';
  // static String addressMap = 'address-map';


  // appointment
  static String appointmentServiceList = 'appointment-service-list';
  static String appointmentDetail = 'appointment-detail';
  static String appointmentReschedule = 'appointment-reschedule';
  static String appointmentRescheduleSummary = 'appointment-reschedule-summary';

  //Rating
  static String rating = 'rating';

  //Term and Condition
  static String termAndCondition = 'term-and-condition';

  //Authentication
  static String authentication = "authentication";

  static String activityDetail = "activity-detail";
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
      ],
    );
  },
);

class RouteParam {
  final Map<String, dynamic> params;

  const RouteParam({required this.params});
}
