import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_hospital_slot_request.g.dart';

@JsonSerializable(includeIfNull: false)
class DoctorHospitalSlotRequest {
  final String doctorSerial;
  final String hospitalSerial;
  final String specialistSerial;
  final DateTime date;

  const DoctorHospitalSlotRequest({
    required this.doctorSerial,
    required this.hospitalSerial,
    required this.specialistSerial,
    required this.date,
  });

  factory DoctorHospitalSlotRequest.fromJson(Map<String, dynamic> json) =>
      _$DoctorHospitalSlotRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DoctorHospitalSlotRequestToJson(this);
}
