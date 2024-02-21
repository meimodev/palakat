import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/domain.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(false) bool isGpsEnabled,
    double? currentLatitude,
    double? currentLongitude,
    @Default(false) bool isLoadingSelfCheckin,
    @Default(true) bool isLoadingAppointment,
    @Default([]) List<Appointment> todayAppointments,
  }) = _HomeState;
}
