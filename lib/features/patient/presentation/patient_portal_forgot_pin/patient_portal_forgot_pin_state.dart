class PatientPortalForgotPinState {
  final bool activateCreatePin;
  final bool enableMainButton;

  PatientPortalForgotPinState({
    required this.activateCreatePin,
    required this.enableMainButton,
  });

  PatientPortalForgotPinState copyWith({
    bool? activateCreatePin,
    bool? enableMainButton,
  }) =>
      PatientPortalForgotPinState(
        activateCreatePin: activateCreatePin ?? this.activateCreatePin,
        enableMainButton: enableMainButton ?? this.enableMainButton,
      );
}
