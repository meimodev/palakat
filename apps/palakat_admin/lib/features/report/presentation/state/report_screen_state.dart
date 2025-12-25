import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_shared/core/models/report_job.dart';

part 'report_screen_state.freezed.dart';

@freezed
abstract class ReportScreenState with _$ReportScreenState {
  const factory ReportScreenState({
    @Default(AsyncValue.loading())
    AsyncValue<PaginationResponseWrapper<Report>> reports,
    @Default('') String searchQuery,
    @Default(DateRangePreset.allTime) DateRangePreset dateRangePreset,
    DateTimeRange? customDateRange,
    GeneratedBy? generatedByFilter,
    @Default(10) int pageSize,
    @Default(1) int currentPage,

    /// List of pending/processing report jobs
    @Default([]) List<ReportJob> pendingReportJobs,

    /// Loading state for pending report jobs
    @Default(false) bool loadingPendingReportJobs,

    /// Error message for pending report jobs fetch
    String? pendingReportJobsError,
  }) = _ReportScreenState;
}
