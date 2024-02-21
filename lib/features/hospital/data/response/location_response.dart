import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/data.dart';

part 'location_response.freezed.dart';
part 'location_response.g.dart';

@freezed
class LocationResponse with _$LocationResponse {
  const factory LocationResponse({
    @Default("") String serial,
    @Default("") String name,
    @Default([]) List<HospitalResponse> hospitals,
  }) = _LocationResponse;

  factory LocationResponse.fromJson(Map<String, dynamic> json) =>
      _$LocationResponseFromJson(json);
}
