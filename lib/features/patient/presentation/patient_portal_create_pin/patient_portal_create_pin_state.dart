class PatientPortalCreatePinState {
  final bool canProceed;
  final Duration duration;
  final bool loading;
  final String errorOtp;

  const PatientPortalCreatePinState({
    this.duration = Duration.zero,
    this.canProceed = false,
    this.loading = false,
    this.errorOtp = "",
  });

  PatientPortalCreatePinState copyWith({
    bool? canProceed,
    Duration? duration,
    bool? loading,
    String? errorOtp,
  }) {
    return PatientPortalCreatePinState(
      canProceed: canProceed ?? this.canProceed,
      duration: duration ?? this.duration,
      loading: loading ?? this.loading,
      errorOtp: errorOtp ?? this.errorOtp,
    );
  }
}
