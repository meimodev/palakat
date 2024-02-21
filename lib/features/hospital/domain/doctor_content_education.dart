import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_content_education.freezed.dart';
part 'doctor_content_education.g.dart';

@freezed
class DoctorContentEducation with _$DoctorContentEducation {
  const factory DoctorContentEducation({
    @Default("") String year,
    @Default("") String school,
  }) = _DoctorContentEducation;

  factory DoctorContentEducation.fromJson(Map<String, dynamic> json) =>
      _$DoctorContentEducationFromJson(json);
}
