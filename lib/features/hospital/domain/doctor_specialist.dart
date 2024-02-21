import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_specialist.freezed.dart';
part 'doctor_specialist.g.dart';

@freezed
class DoctorSpecialist with _$DoctorSpecialist {
  const factory DoctorSpecialist({
    @Default("") String doctorSerial,
    @Default("") String hospitalSerial,
    @Default("") String specialistSerial,
  }) = _DoctorSpecialist;

  factory DoctorSpecialist.fromJson(Map<String, dynamic> json) =>
      _$DoctorSpecialistFromJson(json);
}
