import 'package:halo_hermina/core/constants/enums/enums.dart';
import 'package:local_auth/local_auth.dart';

class MainPatientPortalState {
  bool loading;
  PatientPortalStatus patientPortalStatus;
  bool authorized;
  bool canUseBiometric;
  List<BiometricType> biometricType;

  MainPatientPortalState({
    required this.patientPortalStatus,
    required this.authorized,
    this.loading = true,
    this.canUseBiometric = false,
    this.biometricType = const [],
  });

  MainPatientPortalState copyWith({
    PatientPortalStatus? patientPortalStatus,
    bool? authorized,
    bool? loading,
    bool? canUseBiometric,
    List<BiometricType>? biometricType,
  }) =>
      MainPatientPortalState(
        loading: loading ?? this.loading,
        patientPortalStatus: patientPortalStatus ?? this.patientPortalStatus,
        authorized: authorized ?? this.authorized,
        canUseBiometric: canUseBiometric ?? this.canUseBiometric,
        biometricType: biometricType ?? this.biometricType,
      );
}
