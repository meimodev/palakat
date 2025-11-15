import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/models.dart';

part 'report_screen_state.freezed.dart';

@freezed
abstract class ReportScreenState with _$ReportScreenState {
  const factory ReportScreenState({
    @Default(AsyncValue.loading()) AsyncValue<PaginationResponseWrapper<Report>> reports,
    @Default('') String searchQuery,
    @Default(DateRangePreset.allTime) DateRangePreset dateRangePreset,
    DateTimeRange? customDateRange,
    GeneratedBy? generatedByFilter,
    @Default(10) int pageSize,
    @Default(1) int currentPage,
  }) = _ReportScreenState;
}
