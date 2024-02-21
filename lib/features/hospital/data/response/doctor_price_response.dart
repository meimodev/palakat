import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_price_response.freezed.dart';
part 'doctor_price_response.g.dart';

@freezed
class DoctorPriceResponse with _$DoctorPriceResponse {
  const factory DoctorPriceResponse({
    @Default("") String doctorSerial,
    @Default("") String hospitalSerial,
    @Default(0) int price,
  }) = _DoctorPriceResponse;

  factory DoctorPriceResponse.fromJson(Map<String, dynamic> json) =>
      _$DoctorPriceResponseFromJson(json);
}
