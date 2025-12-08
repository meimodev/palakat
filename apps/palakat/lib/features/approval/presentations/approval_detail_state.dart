import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/models/models.dart';

part 'approval_detail_state.freezed.dart';

@freezed
abstract class ApprovalDetailState with _$ApprovalDetailState {
  const factory ApprovalDetailState({
    @Default(true) bool loadingScreen,

    /// Loading state for approve/reject actions (Req 5.5)
    @Default(false) bool isActionLoading,
    Activity? activity,
    final String? errorMessage,

    /// Success message after approve/reject action
    final String? successMessage,
  }) = _ApprovalDetailState;
}
