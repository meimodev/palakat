import 'package:flutter/widgets.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:palakat/core/routing/app_routing.dart';
// import 'package:palakat/core/widgets/widgets.dart';

extension XBuildContext on BuildContext {
  // void navigateToHome(WidgetRef ref) {
  //   goNamed(AppRoute.home);
  //   ref.read(bottomNavBarProvider.notifier).navigateToHome();
  // }
  //
  // /// [INFO]
  // /// this function is for navigate to style screen from another screen,
  // /// so it will combine go router with [BottomNavBarController]
  // void navigateToAppointment(WidgetRef ref) {
  //   goNamed(AppRoute.home);
  //   ref.read(bottomNavBarProvider.notifier).navigateToAppointment();
  // }
  //
  // /// [INFO]
  // /// this function is for navigate to market screen from another screen,
  // /// so it will combine go router with [BottomNavBarController]
  // void navigateToPatientPortal(WidgetRef ref) {
  //   goNamed(AppRoute.home);
  //   ref.read(bottomNavBarProvider.notifier).navigateToPatientPortal();
  // }
  //
  // /// [INFO]
  // /// this function is for navigate to selling screen from another screen,
  // /// so it will combine go router with [BottomNavBarController]
  // void navigateToNotification(WidgetRef ref) {
  //   goNamed(AppRoute.home);
  //   ref.read(bottomNavBarProvider.notifier).navigateToNotification();
  // }
  //
  // /// [INFO]
  // /// this function is for navigate to profile screen from another screen,
  // /// so it will combine go router with [BottomNavBarController]
  // void navigateToAccount(WidgetRef ref) {
  //   goNamed(AppRoute.home);
  //   ref.read(bottomNavBarProvider.notifier).navigateToAccount();
  // }

  void popUntilNamed<T extends Object?>(String name, [T? result]) {
    String? currentName = ModalRoute.of(this)?.settings.name;
    while (currentName != name) {
      if (!canPop()) {
        return;
      }

      pop<T?>(result);
    }
  }

  /// [INFO]
  /// For popping all screens until screen with named route [targetRouteName] ,
  /// using go router to check route names
  void popUntilNamedWithResult<T extends Object?>({
    required String targetRouteName,
    T? result,
  }) {
    final router = GoRouter.of(this);
    final delegate = router.routerDelegate;
    final routes = delegate.currentConfiguration.routes.reversed.toList();
    for (int i = 0; i < routes.length; i++) {
      final route = routes[i] as GoRoute;
      if (route.name == targetRouteName) break;
      router.pop(result);
    }
  }

  void popUntilBeforeNamed({required String targetRouteName}) {
    final router = GoRouter.of(this);
    final delegate = router.routerDelegate;
    final routes = delegate.currentConfiguration.routes.reversed.toList();
    for (int i = 0; i < routes.length; i++) {
      final route = routes[i] as GoRoute;
      if (route.name == targetRouteName) {
        router.pop();
        break;
      }
      router.pop();
    }
  }

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  double get screenWidth => MediaQuery.of(this).size.width;

  double screenWidthPercentage(double percentage) => screenWidth * percentage;

  double get screenHeight => MediaQuery.of(this).size.height;

  double screenHeightPercentage(double percentage) => screenHeight * percentage;

  double get bottomPadding => mediaQuery.viewPadding.bottom;
}
