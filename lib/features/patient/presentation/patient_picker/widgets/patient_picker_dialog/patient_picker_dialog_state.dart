import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/domain.dart';

part 'patient_picker_dialog_state.freezed.dart';

@freezed
class PatientPickerDialogState with _$PatientPickerDialogState {
  const factory PatientPickerDialogState({
    @Default(true) bool isLoading,
    Patient? selected,
    @Default([]) List<Patient> data,
  }) = _PatientPickerDialogState;
}
