import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/models/models.dart';

part 'view_all_state.freezed.dart';

@freezed
abstract class ViewAllState with _$ViewAllState {
  const factory ViewAllState({
    @Default(<Activity>[]) List<Activity> activities,
  }) = _ViewAllState;
}
