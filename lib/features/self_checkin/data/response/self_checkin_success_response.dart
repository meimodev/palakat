import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/data.dart';

part 'self_checkin_success_response.freezed.dart';
part 'self_checkin_success_response.g.dart';

@freezed
class SelfCheckinSuccessResponse with _$SelfCheckinSuccessResponse {
  const factory SelfCheckinSuccessResponse({
    int? queueNumber,
    @Default("") String bookingID,
    PatientResponse? patient,
    DoctorResponse? doctor,
  }) = _SelfCheckinSuccessResponse;

  factory SelfCheckinSuccessResponse.fromJson(Map<String, dynamic> json) =>
      _$SelfCheckinSuccessResponseFromJson(json);
}
