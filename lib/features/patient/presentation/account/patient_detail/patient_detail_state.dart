import 'package:halo_hermina/features/domain.dart';

class PatientDetailState {
  final bool isLoading;
  final String? serial;
  final Patient? patient;

  const PatientDetailState({
    this.isLoading = true,
    this.serial,
    this.patient,
  });

  PatientDetailState copyWith({
    bool? isLoading,
    String? serial,
    Patient? patient,
  }) {
    return PatientDetailState(
      isLoading: isLoading ?? this.isLoading,
      serial: serial ?? this.serial,
      patient: patient ?? this.patient,
    );
  }
}
