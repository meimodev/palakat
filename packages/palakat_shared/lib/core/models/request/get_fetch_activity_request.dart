import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';

part 'get_fetch_activity_request.freezed.dart';
part 'get_fetch_activity_request.g.dart';

@Freezed(toJson: true, fromJson: true)
abstract class GetFetchActivitiesRequest with _$GetFetchActivitiesRequest {
  const factory GetFetchActivitiesRequest({
    int? churchId,
    int? membershipId,
    int? columnId,
    DateTime? startDate,
    DateTime? endDate,
    ActivityType? activityType,
    String? search,
    bool? hasExpense,
    bool? hasRevenue,
  }) = _GetFetchActivitiesRequest;

  factory GetFetchActivitiesRequest.fromJson(Map<String, dynamic> json) =>
      _$GetFetchActivitiesRequestFromJson(json);
}
