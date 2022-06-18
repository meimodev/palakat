import 'package:flutter/material.dart';
import 'package:palakat/app/modules/account/account_screen.dart';
import 'package:palakat/app/modules/anthem/anthem_screen.dart';
import 'package:palakat/app/modules/calendar/calendar_screen.dart';
import 'package:palakat/app/modules/home/home_screen.dart';
import 'package:palakat/app/modules/splash/splash.dart';

class Routes {
  static const String splash = '/';
  static const String home = '/home';
  static const String calendar = '/calendar';
  static const String anthem = '/anthem';
  static const String account = '/account';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case calendar:
        return MaterialPageRoute(builder: (_) => const CalendarScreen());
      case anthem:
        return MaterialPageRoute(builder: (_) => const AnthemScreen());
      case account:
        return MaterialPageRoute(builder: (_) => const AccountScreen());

      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}