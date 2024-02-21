import 'package:halo_hermina/features/domain.dart';

class AppointmentRescheduleSummaryState {
  final Appointment? appointment;
  final DateTime? rescheduleDateTime;
  final bool isLoading;

  AppointmentRescheduleSummaryState({
    this.appointment,
    this.rescheduleDateTime,
    this.isLoading = false,
  });

  AppointmentRescheduleSummaryState copyWith({
    Appointment? appointment,
    DateTime? rescheduleDateTime,
    bool? isLoading,
  }) {
    return AppointmentRescheduleSummaryState(
      appointment: appointment ?? this.appointment,
      rescheduleDateTime: rescheduleDateTime ?? this.rescheduleDateTime,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
