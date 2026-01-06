import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/models.dart';

part 'dashboard_screen_state.freezed.dart';

@freezed
abstract class DashboardScreenState with _$DashboardScreenState {
  const factory DashboardScreenState({
    @Default(AsyncValue.loading()) AsyncValue<HomeDashboardResponse> home,
    @Default(AsyncValue.loading())
    AsyncValue<MemberScreenStateCounts> memberCounts,
    @Default(AsyncValue.loading()) AsyncValue<FinanceOverview> financeOverview,
    @Default(AsyncValue.loading())
    AsyncValue<PaginationResponseWrapper<FinanceEntry>> financeEntries,
    @Default(AsyncValue.loading())
    AsyncValue<PaginationResponseWrapper<Approver>> pendingApprovals,
  }) = _DashboardScreenState;
}
