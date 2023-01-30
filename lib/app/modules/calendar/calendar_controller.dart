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

  Future<void> onAddNewEvent(
    String title,
    String location,
    String dateTime,
    List<String> reminders,
  ) async {
    final e = Event(
      id: events.length.toString(),
      title: title,
      location: location,
      author: await userRepo.user,
      reminders: reminders,
      authorId: '',
      eventDateTimeStamp: DateTime.now(),
    );
    events.add(e);
  }

  void onEditEvent(
    Event event,
  ) {}
}
