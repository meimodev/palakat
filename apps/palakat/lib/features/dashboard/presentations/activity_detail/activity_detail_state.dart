import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/models/models.dart';

part 'activity_detail_state.freezed.dart';

@freezed
abstract class ActivityDetailState with _$ActivityDetailState {
  const factory ActivityDetailState({
    @Default(true) bool isLoading,
    Activity? activity,
    String? errorMessage,
  }) = _ActivityDetailState;
}
