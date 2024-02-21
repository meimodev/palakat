import 'package:halo_hermina/features/domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_doctor_summary_state.freezed.dart';

@freezed
class BookDoctorSummaryState with _$BookDoctorSummaryState {
  const factory BookDoctorSummaryState({
    @Default(false) bool isLoadingSubmit,
    Doctor? doctor,
    Hospital? hospital,
    String? specialistSerial,
    Patient? patient,
    DateTime? dateTime,
    AppointmentGuaranteeType? guaranteeType,
  }) = _BookDoctorSummaryState;
}
