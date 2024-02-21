import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/data.dart';

part 'doctor_content_response.freezed.dart';
part 'doctor_content_response.g.dart';

@freezed
class DoctorContentResponse with _$DoctorContentResponse {
  const factory DoctorContentResponse({
    @Default("") String serial,
    @Default("") String about,
    @Default("") String pictureURL,
    @Default([]) List<DoctorContentEducationResponse> educations,
  }) = _DoctorContentResponse;

  factory DoctorContentResponse.fromJson(Map<String, dynamic> json) =>
      _$DoctorContentResponseFromJson(json);
}
