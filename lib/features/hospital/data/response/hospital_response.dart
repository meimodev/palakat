import 'package:freezed_annotation/freezed_annotation.dart';

part 'hospital_response.freezed.dart';
part 'hospital_response.g.dart';

@freezed
class HospitalResponse with _$HospitalResponse {
  const factory HospitalResponse({
    @Default("") String serial,
    @Default("") String name,
    String? address,
    String? about,
    double? longitude,
    double? latitude,
    String? pictureURL,
    String? phone,
    String? callCenter,
    String? instagram,
    String? email,
  }) = _HospitalResponse;

  factory HospitalResponse.fromJson(Map<String, dynamic> json) =>
      _$HospitalResponseFromJson(json);
}
