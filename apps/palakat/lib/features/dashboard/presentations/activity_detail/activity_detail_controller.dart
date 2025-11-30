import 'package:palakat/features/dashboard/presentations/activity_detail/activity_detail_state.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_detail_controller.g.dart';

@riverpod
class ActivityDetailController extends _$ActivityDetailController {
  @override
  ActivityDetailState build(int activityId) {
    Future.microtask(() => fetchActivity());
    return const ActivityDetailState();
  }

  ActivityRepository get _activityRepo => ref.read(activityRepositoryProvider);

  Future<void> fetchActivity() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _activityRepo.fetchActivity(activityId: activityId);

    result.when(
      onSuccess: (activity) {
        state = state.copyWith(isLoading: false, activity: activity);
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
