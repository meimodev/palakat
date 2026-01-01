import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/models/activity.dart';
import 'package:palakat_shared/core/models/membership.dart';

part 'home_dashboard.freezed.dart';
part 'home_dashboard.g.dart';

@freezed
abstract class HomeDashboardRange with _$HomeDashboardRange {
  const factory HomeDashboardRange({
    required DateTime startDate,
    required DateTime endDate,
  }) = _HomeDashboardRange;

  factory HomeDashboardRange.fromJson(Map<String, dynamic> json) =>
      _$HomeDashboardRangeFromJson(json);
}

@freezed
abstract class HomeDashboardData with _$HomeDashboardData {
  const factory HomeDashboardData({
    required Membership membership,
    required HomeDashboardRange range,
    @Default(<Activity>[]) List<Activity> thisWeekActivities,
    @Default(<Activity>[]) List<Activity> thisWeekAnnouncements,
    Activity? nextUpActivity,
  }) = _HomeDashboardData;

  factory HomeDashboardData.fromJson(Map<String, dynamic> json) =>
      _$HomeDashboardDataFromJson(json);
}

@freezed
abstract class HomeDashboardResponse with _$HomeDashboardResponse {
  const factory HomeDashboardResponse({
    required String message,
    required HomeDashboardData data,
  }) = _HomeDashboardResponse;

  factory HomeDashboardResponse.fromJson(Map<String, dynamic> json) =>
      _$HomeDashboardResponseFromJson(json);
}
