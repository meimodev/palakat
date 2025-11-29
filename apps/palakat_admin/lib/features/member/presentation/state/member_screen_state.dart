import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/models.dart';

part 'member_screen_state.freezed.dart';

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

// MemberScreenStateCounts is now imported from palakat_shared via palakat_admin/models.dart
