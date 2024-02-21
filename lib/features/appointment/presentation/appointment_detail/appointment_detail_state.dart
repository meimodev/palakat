import 'package:halo_hermina/features/domain.dart';

class AppointmentDetailState {
  final String serial;
  final bool isLoading;
  final Appointment? appointment;

  const AppointmentDetailState({
    this.appointment,
    this.serial = "",
    this.isLoading = true,
  });

  AppointmentDetailState copyWith({
    Appointment? appointment,
    String? serial,
    bool? isLoading,
  }) {
    return AppointmentDetailState(
      serial: serial ?? this.serial,
      isLoading: isLoading ?? this.isLoading,
      appointment: appointment ?? this.appointment,
    );
  }
}
