import 'package:get/get.dart';
import 'package:palakat/data/models/church.dart';
import 'package:palakat/data/models/event.dart';
import 'package:palakat/data/models/user.dart';

class DashboardController extends GetxController {
  var user = User(
    id: 20,
    name: 'Jhon Mokodompit',
    phone: '0812 1234 1234',
    column: '17',
    dob: '04 September 1990',
    church: Church(
      id: '22',
      name: 'Gereja Banteng Indonesia',
      location: 'Wawalintouan Tondano',
    ),
  );

  var isLoading = true.obs;
  var eventsThisWeek = <Event>[];


  @override
  void onInit() async {
    super.onInit();
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
  }
}
