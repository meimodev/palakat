import 'package:local_auth/local_auth.dart';

class BiometricState {
  final bool isLoading;
  final bool enableBiometric;
  final List<BiometricType> biometricType;

  const BiometricState({
    this.isLoading = true,
    this.enableBiometric = false,
    this.biometricType = const [],
  });

  BiometricState copyWith({
    bool? isLoading,
    bool? enableBiometric,
    List<BiometricType>? biometricType,
  }) {
    return BiometricState(
      isLoading: isLoading ?? this.isLoading,
      enableBiometric: enableBiometric ?? this.enableBiometric,
      biometricType: biometricType ?? this.biometricType,
    );
  }
}
