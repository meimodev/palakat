import 'dart:math';

import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/activity.dart';
import 'package:palakat/core/utils/extensions/date_time_extension.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/presentation.dart';

part 'view_all_controller.g.dart';

@riverpod
class ViewAllController extends _$ViewAllController {
  @override
  ViewAllState build() {
    final List<Activity> activities = List<Activity>.generate(
      10,
      (index) => Activity(
        id: '$index',
        title: 'activity title $index',
        bipra: Bipra.values[Random().nextInt(Bipra.values.length - 1)],
        type: ActivityType
            .values[Random().nextInt(ActivityType.values.length - 1)],
        publishDate: DateTime.now(),
        activityDate: DateTime.now().add(
              Duration(days: Random().nextInt(5)),
            ),
      ),
    );

    return ViewAllState(
      activities: activities,
    );
  }
}
