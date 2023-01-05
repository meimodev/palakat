import 'package:get/get.dart';
import 'package:palakat/data/models/model_mock.dart';

class DashboardController extends GetxController {
  final user = ModelMock.user;

  var isLoading = true.obs;
  var eventsThisWeek = ModelMock.events;

  @override
  void onInit() async {
    super.onInit();
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
  }
}
