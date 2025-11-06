import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/core/models/models.dart';


part 'approval_state.freezed.dart';

@freezed
abstract class ApprovalState with _$ApprovalState {
  const factory ApprovalState({
    Membership? membership,
    @Default(true) bool loadingScreen,
    @Default(<Activity>[]) List<Activity> approvals,
    // Date filter fields
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    // Computed/derived list based on filters
    @Default(<Activity>[]) List<Activity> filteredApprovals,
  }) = _ApprovalState;
}
