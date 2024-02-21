import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/features/data.dart';

part 'doctor_response.freezed.dart';
part 'doctor_response.g.dart';

@freezed
class DoctorResponse with _$DoctorResponse {
  const factory DoctorResponse({
    @Default("") String serial,
    @Default("") String name,
    SerialNameResponse? specialist,
    @Default([]) List<HospitalResponse> hospitals,
    DoctorContentResponse? content,
  }) = _DoctorResponse;

  factory DoctorResponse.fromJson(Map<String, dynamic> json) =>
      _$DoctorResponseFromJson(json);
}
