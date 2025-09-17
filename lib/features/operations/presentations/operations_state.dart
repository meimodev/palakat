import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/models/membership.dart';
import 'package:palakat/features/operations/domain/entities/report.dart';

part 'operations_state.freezed.dart';

@freezed
abstract class OperationsState with _$OperationsState {
  const factory OperationsState({
    Membership? membership,
    @Default(true) bool loadingScreen,
  }) = _OperationsState;
}
