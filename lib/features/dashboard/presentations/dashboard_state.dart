import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/core/models/models.dart';

part 'dashboard_state.freezed.dart';

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    @Default(true) bool thisWeekActivitiesLoading,
    @Default(<Activity>[]) List<Activity> thisWeekActivities,
    @Default(true) bool thisWeekAnnouncementsLoading,
    @Default(<Activity>[]) List<Activity> thisWeekAnnouncements,
    @Default(true) bool membershipLoading,
    final Account? account,
    final String? errorMessage,
  }) = _DashboardState;
}
