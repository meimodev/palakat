
import 'package:palakat/core/constants/constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/presentation.dart';

part 'activity_publish_controller.g.dart';

@riverpod
class ActivityPublishController extends _$ActivityPublishController {
  @override
  ActivityPublishState build() {
    return const ActivityPublishState(type: ActivityType.event);
  }

}
