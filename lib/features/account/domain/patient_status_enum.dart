import 'package:freezed_annotation/freezed_annotation.dart';

enum PatientStatus {
  @JsonValue('VERIFIED')
  verified,
  @JsonValue('UNVERIFIED')
  unverified
}
