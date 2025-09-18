import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/models/membership.dart';
import 'package:palakat/core/models/activity.dart';

part 'approval_state.freezed.dart';

@freezed
abstract class ApprovalState with _$ApprovalState {
  const factory ApprovalState({
    Membership? membership,
    @Default(true) bool loadingScreen,
    @Default(<Activity>[]) List<Activity> approvals,
  }) = _ApprovalState;
}
