import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_price_request.g.dart';

@JsonSerializable(includeIfNull: false)
class DoctorPriceRequest {
  final String doctorSerial;
  final String hospitalSerial;

  const DoctorPriceRequest({
    required this.doctorSerial,
    required this.hospitalSerial,
  });

  factory DoctorPriceRequest.fromJson(Map<String, dynamic> json) =>
      _$DoctorPriceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DoctorPriceRequestToJson(this);
}
