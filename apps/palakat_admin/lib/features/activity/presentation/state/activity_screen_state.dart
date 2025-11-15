import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/models.dart';

part 'activity_screen_state.freezed.dart';

@freezed
abstract class ActivityScreenState with _$ActivityScreenState {
  const factory ActivityScreenState({
    @Default(AsyncValue.loading()) AsyncValue<PaginationResponseWrapper<Activity>> activities,
    @Default('') String searchQuery,
    @Default(DateRangePreset.allTime) DateRangePreset dateRangePreset,
    DateTimeRange? customDateRange,
    ActivityType? activityTypeFilter,
    @Default(10) int pageSize,
    @Default(1) int currentPage,
  }) = _ActivityScreenState;
}
