import 'package:freezed_annotation/freezed_annotation.dart';

enum AppointmentInsuranceStatus {
  @JsonValue("APPROVED")
  approved,
  @JsonValue("PENDING")
  pending,
  @JsonValue("REJECTED")
  rejected
}
