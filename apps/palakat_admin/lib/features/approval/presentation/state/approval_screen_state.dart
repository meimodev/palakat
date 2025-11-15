import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/models.dart';

part 'approval_screen_state.freezed.dart';

@freezed
abstract class ApprovalScreenState with _$ApprovalScreenState {
  const factory ApprovalScreenState({
    @Default(AsyncValue.loading())
    AsyncValue<PaginationResponseWrapper<ApprovalRule>> rules,
    @Default(AsyncValue.loading())
    AsyncValue<PaginationResponseWrapper<MemberPosition>> positions,
    @Default('') String searchQuery,
    @Default(null) int? selectedPositionId,
    @Default(null) bool? activeOnly,
    @Default(10) int pageSize,
    @Default(1) int currentPage,
  }) = _ApprovalScreenState;
}
