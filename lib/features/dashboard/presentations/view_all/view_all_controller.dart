import 'dart:math';

import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_admin/core/models/models.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/presentation.dart';

part 'view_all_controller.g.dart';

@riverpod
class ViewAllController extends _$ViewAllController {
  @override
  ViewAllState build() {
    final rnd = Random();
    final List<Activity> activities = List<Activity>.generate(
      10,
      (index) {
        final r = rnd.nextInt(ActivityType.values.length);
        final now = DateTime.now();

        final supervisor = Membership(
          id: index + 1,
          baptize: false,
          sidi: false,
        );

        return Activity(
          id: index,
          supervisorId: supervisor.id,
          bipra: Bipra.values[r % Bipra.values.length],
          title: 'activity title $index',
          location: Location(name: 'Location $index', latitude: 0, longitude: 0, id: index),
          date: now.add(Duration(days: r % 5)),
          note: 'Sample note for activity $index',
          fileUrl: '',
          createdAt: now,
          updatedAt: now,
          supervisor: supervisor,
          approvers: const <Approver>[],
        );
      },
    );

    return ViewAllState(activities: activities);
  }
}
