import 'package:halo_hermina/features/domain.dart';

class DoctorAutocompleteState {
  final List<Doctor> doctors;
  final bool isLoading;
  final List<String>? specialistSerial;
  final List<String>? hospitalSerial;

  const DoctorAutocompleteState({
    this.doctors = const [],
    this.isLoading = false,
    this.specialistSerial,
    this.hospitalSerial,
  });

  DoctorAutocompleteState copyWith({
    List<Doctor>? doctors,
    bool? isLoading,
    List<String>? specialistSerial,
    List<String>? hospitalSerial,
  }) {
    return DoctorAutocompleteState(
      doctors: doctors ?? this.doctors,
      isLoading: isLoading ?? this.isLoading,
      specialistSerial: specialistSerial ?? this.specialistSerial,
      hospitalSerial: hospitalSerial ?? this.hospitalSerial,
    );
  }
}
