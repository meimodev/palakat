import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/model/model.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/hospital/domain/doctor_content.dart';

part 'doctor.freezed.dart';
part 'doctor.g.dart';

@freezed
class Doctor with _$Doctor {
  const factory Doctor({
    @Default("") String serial,
    @Default("") String name,
    SerialName? specialist,
    @Default([]) List<Hospital> hospitals,
    DoctorContent? content,
  }) = _Doctor;

  factory Doctor.fromJson(Map<String, dynamic> json) => _$DoctorFromJson(json);
}
