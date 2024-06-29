import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/models/models.dart';

part 'dashboard_state.freezed.dart';

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState({
    @Default(<Activity>[]) List<Activity> thisWeekActivities,
  }) = _DashboardState;
}
