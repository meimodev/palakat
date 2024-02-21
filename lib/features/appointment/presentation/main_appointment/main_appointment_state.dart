import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/model/serial_name.dart';
import 'package:halo_hermina/features/domain.dart';

part 'main_appointment_state.freezed.dart';

enum FilterTab { active, past }

@freezed
class MainAppointmentState with _$MainAppointmentState {
  const factory MainAppointmentState({
    @Default(FilterTab.active) FilterTab selectedFilter,
    @Default(1) int upcomingPage,
    @Default(1) int pastPage,
    @Default([]) List<SerialName> services,
    @Default([]) List<Doctor> doctors,
    @Default([]) List<SerialName> specialists,
    @Default([]) List<Hospital> hospitals,
    @Default([]) List<SerialName> patients,
    @Default([]) List<SerialName> tempServices,
    @Default([]) List<Doctor> tempDoctors,
    @Default([]) List<SerialName> tempSpecialists,
    @Default([]) List<Hospital> tempHospitals,
    @Default([]) List<SerialName> tempPatients,
    @Default([]) List<Appointment> activeAppointments,
    @Default([]) List<Appointment> upcomingAppointments,
    @Default([]) List<Appointment> pastAppointments,
    @Default(false) bool hasMoreUpcomingPage,
    @Default(false) bool hasMorePastPage,
    @Default(false) bool loadingActive,
    @Default(false) bool loadingUpcoming,
    @Default(false) bool loadingMoreUpcoming,
    @Default(false) bool loadingPast,
    @Default(false) bool loadingMorePast,
    @Default(false) bool searching,
    @Default(false) bool isGpsEnabled,
    double? currentLatitude,
    double? currentLongitude,
    @Default(false) bool isLoadingSelfCheckin,
  }) = _MainAppointmentState;
}

class AppointmentSelectItem {
  final AppointmentManageType value;
  final String label;
  final String subLabel;

  const AppointmentSelectItem({
    required this.value,
    required this.label,
    required this.subLabel,
  });
}
