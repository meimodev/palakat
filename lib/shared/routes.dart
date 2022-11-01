import 'package:get/get.dart';
import 'package:palakat/app/modules/account/account_binding.dart';
import 'package:palakat/app/modules/account/account_screen.dart';
import 'package:palakat/app/modules/home/home_binding.dart';
import 'package:palakat/app/modules/home/home_screen.dart';

class Routes {
  static const String home = '/';
  static const String calendar = '/calendar';
  static const String anthem = '/songs';
  static const String account = '/account';

  static List<GetPage> getRoutes() {
    return [
      GetPage(
        name: home,
        page: () => const HomeScreen(),
        binding: HomeBinding(),
        transition: Transition.fade,
        maintainState: true,
        preventDuplicates: true,
      ),

      GetPage(
        name: account,
        page: () => const AccountScreen(),
        binding: AccountBinding(),
        transition: Transition.rightToLeftWithFade,
      ),
    ];
  }
}
