

import 'package:palakat/core/data_sources/network/model/model.dart';

abstract class ActivityApiContract {
  Future<Result<List<Map<String, dynamic>>>> getActivities(
      GetActivitiesRequest req);
}

