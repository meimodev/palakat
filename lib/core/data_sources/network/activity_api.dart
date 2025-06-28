import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'model/model.dart';

class ActivityApi {
  Future<List<Map<String, dynamic>>> getActivities(
    GetActivitiesRequest req,
  ) async {
    throw UnimplementedError();
    // try {
    //   if (req.activitySerial != null) {
    //     final doc = await activities.doc(req.activitySerial!).get();
    //     return Result.success([doc.data() ?? {}]);
    //   }
    //
    //   var query = activities.where(
    //     "church_serial",
    //     isEqualTo: req.churchSerial,
    //   );
    //
    //   if (req.activityType != null) {
    //     query = query.where(
    //       "type",
    //       isEqualTo: req.activityType!.name,
    //     );
    //   }
    //
    //   if (req.activityDateRange != null) {
    //     query = query
    //         .where(
    //           "activity_date",
    //           isGreaterThanOrEqualTo: Timestamp.fromDate(
    //               req.activityDateRange!.start.toStartOfTheDay),
    //         )
    //         .where(
    //           "activity_date",
    //           isLessThanOrEqualTo: Timestamp.fromDate(
    //               req.activityDateRange!.end.toStartOfTheDay),
    //         );
    //   }
    //
    //   if (req.publishDateRange != null) {
    //     query = query
    //         .where(
    //           "publish_date",
    //           isGreaterThanOrEqualTo: Timestamp.fromDate(
    //               req.publishDateRange!.start.toStartOfTheDay),
    //         )
    //         .where(
    //           "publish_date",
    //           isLessThanOrEqualTo:
    //               Timestamp.fromDate(req.publishDateRange!.end.toStartOfTheDay),
    //         );
    //   }
    //
    //   final res = await query.get();
    //
    //   return Result.success(
    //     res.docs.map((e) => e.data()).toList(),
    //   );
    // } catch (e, st) {
    //   return Result.failure("firebase error $e", st);
    // }
  }
}

final activityApiProvider = Provider<ActivityApi>((ref) {
  return ActivityApi();
});
