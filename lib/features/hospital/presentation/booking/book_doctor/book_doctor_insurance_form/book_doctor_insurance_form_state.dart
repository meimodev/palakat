import 'package:halo_hermina/features/domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_doctor_insurance_form_state.freezed.dart';

@freezed
class BookDoctorInsuranceFormState with _$BookDoctorInsuranceFormState {
  const factory BookDoctorInsuranceFormState({
    @Default(false) bool isLoadingSubmit,
    @Default(false) bool isAgree,
    Doctor? doctor,
    Hospital? hospital,
    String? specialistSerial,
    Patient? patient,
    DateTime? dateTime,
    MediaUpload? selectedCard,
    MediaUpload? selectedCardWithPhoto,
    AppointmentGuaranteeType? guaranteeType,
    @Default({}) Map<String, dynamic> errors,
  }) = _BookDoctorInsuranceFormState;
}
