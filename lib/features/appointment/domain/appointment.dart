import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/model/serial_name.dart';
import 'package:halo_hermina/features/domain.dart';

part 'appointment.freezed.dart';
part 'appointment.g.dart';

@freezed
class Appointment with _$Appointment {
  const factory Appointment({
    required String serial,
    required AppointmentType type,
    int? queueNumber,
    required String bookingID,
    required AppointmentGuaranteeType guaranteeType,
    required bool isPreAppointment,
    required AppointmentStatus status,
    AppointmentInsuranceStatus? insuranceStatus,
    String? cancelReason,
    Patient? patient,
    required DateTime date,
    Doctor? doctor,
    Hospital? hospital,
    SerialName? specialist,
    String? currentJourney,
    @Default(false) bool canCancel,
    @Default(false) bool canReschedule,
    @Default(false) bool canManage,
    @Default(false) bool canPrintInvoice,
    @Default(false) bool canSelfCheckin,
  }) = _Appointment;

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);
}
