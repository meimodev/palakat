import 'dart:math';

import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/presentation.dart';

part 'dashboard_controller.g.dart';

@riverpod
class DashboardController extends _$DashboardController {
  @override
  DashboardState build() {
    final List<Activity> activities = List<Activity>.generate(
      10,
      (index) => Activity(
        id: '$index',
        title: 'activity title $index',
        bipra: Bipra.values[Random().nextInt(Bipra.values.length)],
        type: ActivityType
            .values[Random().nextInt(ActivityType.values.length)],
        // type: ActivityType.announcement,
        publishDate: DateTime.now(),
        activityDate: DateTime.now().add(
          Duration(days: Random().nextInt(5)),
        ),
      ),
    );

    final membership = Membership(
      id: "id",
      account: Account(
        id: "id",
        phone: "phone",
        name: "name",
        dob: DateTime.now(),
        gender: Gender.male,
        maritalStatus: MaritalStatus.married,
      ),
      church: Church(
        id: "id",
        name: "somename",
        location: Location(
          latitude: 1,
          longitude: 1,
          name: "some location",
        ),
      ),
      columnNumber: "22",
      baptize: true,
      sidi: true,
      bipra: Bipra.youths,
    );

    return DashboardState(
      thisWeekActivities: activities,
      membership: membership,
    );
  }

  List<Activity> getThisWeekAnnouncement() {
    return state.thisWeekActivities
        .where(
          (element) => element.type == ActivityType.announcement,
        )
        .toList();
  }
}
