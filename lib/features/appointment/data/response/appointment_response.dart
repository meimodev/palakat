import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/features/data.dart';

part 'appointment_response.freezed.dart';
part 'appointment_response.g.dart';

@freezed
class AppointmentResponse with _$AppointmentResponse {
  const factory AppointmentResponse({
    @Default("") String serial,
    @Default("") String type,
    int? queueNumber,
    @Default("") String bookingID,
    @Default("") String guaranteeType,
    @Default(false) bool isPreAppointment,
    @Default("") String status,
    String? insuranceStatus,
    String? cancelReason,
    PatientResponse? patient,
    required DateTime date,
    DoctorResponse? doctor,
    HospitalResponse? hospital,
    SerialNameResponse? specialist,
    @Default("") String currentJourney,
    @Default(false) bool canCancel,
    @Default(false) bool canReschedule,
    @Default(false) bool canManage,
    @Default(false) bool canPrintInvoice,
    @Default(false) bool canSelfCheckin,
  }) = _AppointmentResponse;

  factory AppointmentResponse.fromJson(Map<String, dynamic> json) =>
      _$AppointmentResponseFromJson(json);
}
