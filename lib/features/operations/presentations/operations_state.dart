import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/core/models/models.dart';

part 'operations_state.freezed.dart';

@freezed
abstract class OperationsState with _$OperationsState {
  const factory OperationsState({
    Membership? membership,
    @Default(true) bool loadingScreen,
    final String? errorMessage,
  }) = _OperationsState;
}
