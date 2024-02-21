import 'package:halo_hermina/features/domain.dart';

class AppointmentRescheduleState {
  final bool isLoadingPrice;
  final int doctorPrice;
  final Appointment? appointment;

  AppointmentRescheduleState({
    this.isLoadingPrice = true,
    this.doctorPrice = 0,
    this.appointment,
  });

  AppointmentRescheduleState copyWith({
    bool? isLoadingPrice,
    int? doctorPrice,
    Appointment? appointment,
  }) {
    return AppointmentRescheduleState(
      isLoadingPrice: isLoadingPrice ?? this.isLoadingPrice,
      doctorPrice: doctorPrice ?? this.doctorPrice,
      appointment: appointment ?? this.appointment,
    );
  }
}
