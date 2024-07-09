import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/data_sources/data_sources.dart';
import 'package:palakat/core/models/models.dart';

class ActivityRepository {
  ActivityRepository({
    required this.activityApi,
  });

  final ActivityApiContract activityApi;

  Future<Result<List<Activity>>> getActivities(GetActivitiesRequest req) async {
    final res = await activityApi.getActivities(req);
    return res.when(
      success: (data) => Result.success(
        data.map(Activity.fromJson).toList(),
      ),
      failure: Result.failure,
    );
  }
}

final activityRepositoryProvider =
    Provider.autoDispose<ActivityRepository>((ref) {
  return ActivityRepository(
    activityApi: ref.read(activityApiProvider),
  );
});
