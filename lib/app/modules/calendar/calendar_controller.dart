import 'package:get/get.dart';
import 'package:palakat/data/models/event.dart';
import 'package:palakat/data/models/model_mock.dart';
import 'package:palakat/data/repos/user_repo.dart';

class CalendarController extends GetxController {
  final userRepo = Get.find<UserRepo>();

  var events = <Event>[].obs;
  var isLoading = true.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    events.value = ModelMock.events;
    isLoading.value = false;
  }

  void onAddNewEvent(
    String title,
    String location,
    String dateTime,
    List<String> reminders,
  )  {
    final e = Event(
      id: events.length.toString(),
      title: title,
      location: location,
      author:  userRepo.user,
      dateTime: dateTime,
      reminders: reminders,
    );
    events.add(e);
  }

  void onEditEvent(
    String id,
    String title,
    String location,
    String dateTime,
    List<String> reminders,
  ) {}
}
