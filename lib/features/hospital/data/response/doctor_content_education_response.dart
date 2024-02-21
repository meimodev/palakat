import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_content_education_response.freezed.dart';
part 'doctor_content_education_response.g.dart';

@freezed
class DoctorContentEducationResponse with _$DoctorContentEducationResponse {
  const factory DoctorContentEducationResponse({
    @Default("") String year,
    @Default("") String school,
  }) = _DoctorContentEducationResponse;

  factory DoctorContentEducationResponse.fromJson(Map<String, dynamic> json) =>
      _$DoctorContentEducationResponseFromJson(json);
}
