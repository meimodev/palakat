import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/core/constants/enums.dart';

part 'get_fetch_activity_request.freezed.dart';
part 'get_fetch_activity_request.g.dart';

@freezed
abstract class GetFetchActivitiesRequest with _$GetFetchActivitiesRequest {
  const factory GetFetchActivitiesRequest({
    int? churchId,
    int? membershipId,
    int? columnId,
    DateTime? startDate,
    DateTime? endDate,
    ActivityType? activityType,
    String? search,
  }) = _GetFetchActivitiesRequest;

  factory GetFetchActivitiesRequest.fromJson(Map<String, dynamic> json) =>
      _$GetFetchActivitiesRequestFromJson(json);

}
