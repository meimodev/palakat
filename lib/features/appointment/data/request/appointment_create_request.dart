import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/domain.dart';

part 'appointment_create_request.g.dart';

@JsonSerializable(includeIfNull: false)
class AppointmentCreateRequest {
  final AppointmentType type;
  final AppointmentGuaranteeType guaranteeType;
  final String hospitalSerial;
  final String doctorSerial;
  final String patientSerial;
  final String specialistSerial;
  final DateTime date;
  final String? insuranceCardSerial;
  final String? insurancePhotoSerial;

  const AppointmentCreateRequest({
    required this.type,
    required this.guaranteeType,
    required this.hospitalSerial,
    required this.doctorSerial,
    required this.patientSerial,
    required this.specialistSerial,
    required this.date,
    this.insuranceCardSerial,
    this.insurancePhotoSerial,
  });

  @override
  factory AppointmentCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$AppointmentCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentCreateRequestToJson(this);
}
