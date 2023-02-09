import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:palakat/data/models/event.dart';
import 'package:palakat/data/models/user_app.dart';
import 'package:palakat/data/repos/event_repo.dart';
import 'package:palakat/data/repos/user_repo.dart';
import 'package:palakat/shared/shared.dart';
import 'dart:developer' as dev;

class DashboardController extends GetxController {
  UserApp? user;

  final userRepo = Get.find<UserRepo>();
  final eventRepo = Get.find<EventRepo>();

  var isLoading = true.obs;
  var events = <Event>[];

  @override
  void onInit() async {
    super.onInit();

    //redirect to homepage if phone not confirmed
    if (!await userRepo.isSignedIn()) {
      await userRepo.signOut();
      Get.offAndToNamed(Routes.signing);
      return;
    }

    user = await userRepo.user();
    //redirect to signing page if membership data not fulfilled
    if (user!.membership == null) {
      await userRepo.signOut();
      Get.offAndToNamed(Routes.signing);
      return;
    }

    _initEventsStreamingListener();

    isLoading.value = false;
  }

  void onUpdateUserInfo(UserApp user) async {
    isLoading.value = true;
    this.user = await userRepo.readUser(user.id!);
    isLoading.value = false;
  }

  void onTapAccountCard() {
    Get.toNamed(Routes.account, arguments: user);
  }

  void onPressedSignOutButton() {
    userRepo.signOut();
    Future.delayed(Duration.zero)
        .then((value) => Get.offAndToNamed(Routes.signing));
  }

  void _initEventsStreamingListener() async {
    final stream =
        await eventRepo.streamEventsThisWeek(user!.membership!.churchId);

    stream.listen((event) {
      isLoading.value = true;

      for (var change in event.docChanges) {
        final data = change.doc.data();
        dev.log("[FIRESTORE] event this week stream ${change.type} $data");
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
      isLoading.value = false;
    });
  }

  void _addPublishedEvents(Event event) {
    events.add(event);
    _sortPublishedEvents();
  }

  void _modifyPublishedEvents(Event event) {
    events = events
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
