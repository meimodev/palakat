import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:palakat/data/models/event.dart';
import 'package:palakat/data/models/user_app.dart';
import 'package:palakat/data/repos/event_repo.dart';
import 'package:palakat/data/repos/user_repo.dart';
import 'dart:developer' as dev;

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
    if (user.membershipId.isEmpty) {
      isLoading.value = false;
      return;
    }

    _initEventsStreamingListener();

    isLoading.value = false;
  }

  Future<void> onAddNewEvent(String title, String location, DateTime dateTime,
      List<String> reminders) async {
    isLoading.value = true;

    await eventRepo.writeEvent(Event(
      id: "",
      title: title,
      location: location,
      author: user,
      reminders: reminders,
      authorId: user.id!,
      eventDateTimeStamp: dateTime,
      churchId: user.membership!.churchId,
    ));

    isLoading.value = false;
  }

  void onEditEvent(
    Event event,
  ) {}

  void _initEventsStreamingListener() async {
    final stream = await eventRepo.streamEventsByAuthor(userId: user.id!);
    stream.listen((event) {
      for (var change in event.docChanges) {
        final data = change.doc.data();
        dev.log("[FIRESTORE] event published stream ${change.type} $data");
        switch (change.type) {
          case DocumentChangeType.added:
            _addPublishedEvents(Event.fromMap(data));
            break;
          case DocumentChangeType.modified:
            _modifyPublishedEvents(Event.fromMap(data));
            break;
          case DocumentChangeType.removed:
            _removePublishedEvents(Event.fromMap(data));
            break;
        }
      }
    });
  }

  void _addPublishedEvents(Event event) {
    events.add(event);
    _sortPublishedEvents();
  }

  void _modifyPublishedEvents(Event event) {
    events.value = events
        .map<Event>((element) => event.id == element.id ? event : element)
        .toList();
  }

  void _removePublishedEvents(Event event) {
    events.removeWhere((element) => element.id == event.id);
    _sortPublishedEvents();
  }

  void _sortPublishedEvents() {
    events.sort((a, b) => a.eventDateTimeStamp.compareTo(b.eventDateTimeStamp));
  }
}
