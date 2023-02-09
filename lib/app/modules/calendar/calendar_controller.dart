import 'package:get/get.dart';
import 'package:palakat/data/models/event.dart';
import 'package:palakat/data/models/user_app.dart';
import 'package:palakat/data/repos/event_repo.dart';
import 'package:palakat/data/repos/user_repo.dart';

class CalendarController extends GetxController {
  final userRepo = Get.find<UserRepo>();
  final eventRepo = Get.find<EventRepo>();

  var events = <Event>[].obs;
  var isLoading = true.obs;

  late UserApp user;

  @override
  Future<void> onInit() async {
    super.onInit();

    isLoading.value = true;
    user = await userRepo.user();
    events.value = await eventRepo.readEventByAuthor(userId: user.id!);
    isLoading.value = false;
  }

  Future<void> onAddNewEvent(
    String title,
    String location,
    DateTime dateTime,
    List<String> reminders,
  ) async {
    isLoading.value = true;

    final event = Event(
      id: "",
      title: title,
      location: location,
      author: user,
      reminders: reminders,
      authorId: user.id!,
      eventDateTimeStamp: dateTime,
      churchId: user.membership!.churchId,
    );
    print("create event $event");
    final newEvent = await eventRepo.writeEvent(event);
    print("newly created $newEvent");
    events.add(event);

    isLoading.value = false;

  }

  void onEditEvent(
    Event event,
  ) {}
}
