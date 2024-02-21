import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/domain.dart';

part 'doctor_content.freezed.dart';
part 'doctor_content.g.dart';

@freezed
class DoctorContent with _$DoctorContent {
  const factory DoctorContent({
    @Default("") String serial,
    @Default("") String pictureURL,
    @Default("") String about,
    @Default([]) List<DoctorContentEducation> educations,
  }) = _DoctorContent;

  factory DoctorContent.fromJson(Map<String, dynamic> json) =>
      _$DoctorContentFromJson(json);
}
