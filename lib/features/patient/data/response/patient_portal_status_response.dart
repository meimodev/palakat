import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/constants/constants.dart';

part 'patient_portal_status_response.freezed.dart';
part 'patient_portal_status_response.g.dart';

@freezed
class PatientPortalStatusResponse with _$PatientPortalStatusResponse {
  const factory PatientPortalStatusResponse({

    @Default(PatientPortalStatus.notActivated) PatientPortalStatus status,

  }) = _PatientPortalStatusResponse;

  factory PatientPortalStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$PatientPortalStatusResponseFromJson(json);
}
