import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/models/models.dart';

part 'dashboard_state.freezed.dart';

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    @Default(true) bool thisWeekActivitiesLoading,
    @Default(<Activity>[]) List<Activity> thisWeekActivities,
    @Default(true) bool thisWeekAnnouncementsLoading,
    @Default(<Activity>[]) List<Activity> thisWeekAnnouncements,
    final Membership? membership,
    @Default(true) bool membershipLoading,
  }) = _DashboardState;
}
