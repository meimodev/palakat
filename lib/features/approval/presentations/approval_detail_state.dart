import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/models/activity.dart';

part 'approval_detail_state.freezed.dart';

@freezed
abstract class ApprovalDetailState with _$ApprovalDetailState {
  const factory ApprovalDetailState({
    @Default(true) bool loadingScreen,
    Activity? activity,
  }) = _ApprovalDetailState;
}
