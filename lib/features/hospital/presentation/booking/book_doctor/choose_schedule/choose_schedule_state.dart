import 'package:halo_hermina/features/domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'choose_schedule_state.freezed.dart';

@freezed
class ChooseScheduleState with _$ChooseScheduleState {
  const factory ChooseScheduleState({
    @Default(true) bool isLoadingPrice,
    @Default(0) int doctorPrice,
    Doctor? doctor,
    Hospital? hospital,
    String? specialistSerial,
  }) = _ChooseScheduleState;
}
