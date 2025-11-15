import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/models.dart';

part 'member_screen_state.freezed.dart';
part 'member_screen_state.g.dart';

@freezed
abstract class MemberScreenState with _$MemberScreenState {
  const factory MemberScreenState({
    @Default(AsyncValue.loading()) AsyncValue<PaginationResponseWrapper<Account>> accounts,
    @Default(AsyncValue.loading()) AsyncValue<MemberScreenStateCounts> counts,
    @Default(AsyncValue.loading()) AsyncValue<List<MemberPosition>> positions,
    @Default('') String searchQuery,
    MemberPosition? selectedPosition,
    @Default(10) int pageSize,
    @Default(1) int currentPage,
  }) = _MemberScreenState;
}

@freezed
abstract class MemberScreenStateCounts with _$MemberScreenStateCounts {
  const factory MemberScreenStateCounts({
    @Default(0) int total,
    @Default(0) int claimed,
    @Default(0) int baptized,
    @Default(0) int sidi,
  }) = _MemberScreenStateCounts;

  factory MemberScreenStateCounts.fromJson(Map<String, dynamic> json) => _$MemberScreenStateCountsFromJson(json);
}
