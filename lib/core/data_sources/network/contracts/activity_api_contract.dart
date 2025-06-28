

import 'package:palakat/core/data_sources/network/model/model.dart';

abstract class ActivityApiContract {
  Future<List<Map<String, dynamic>>> getActivities(
      GetActivitiesRequest req);
}

