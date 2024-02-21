import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_hospital_slot.freezed.dart';
part 'doctor_hospital_slot.g.dart';

@freezed
class DoctorHospitalSlot with _$DoctorHospitalSlot {
  const factory DoctorHospitalSlot({
    required List<String> times,
  }) = _DoctorHospitalSlot;

  factory DoctorHospitalSlot.fromJson(Map<String, dynamic> json) =>
      _$DoctorHospitalSlotFromJson(json);
}
