import 'package:freezed_annotation/freezed_annotation.dart';

enum AppointmentStatus {
  @JsonValue("SELF_CHECKIN")
  selfCheckin,
  @JsonValue("DOCTOR_NOT_AVAILABLE")
  doctorNotAvailable,
  @JsonValue("CANCELED")
  canceled,
  @JsonValue("SLOT_TAKEN")
  slotTaken,
}
