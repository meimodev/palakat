import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';

class PatientPortalForgotPinController
    extends StateNotifier<PatientPortalForgotPinState> {
  PatientPortalForgotPinController()
      : super(PatientPortalForgotPinState(
          activateCreatePin: false,
          enableMainButton: true,
        ));

  final formKey = GlobalKey<FormState>();
  final tecVerificationCode = TextEditingController();
  final tecPin = TextEditingController();
  final tecPinConfirm = TextEditingController();

  void toggleCreatePin() {
    state = state.copyWith(activateCreatePin: !state.activateCreatePin);

    tecVerificationCode.clear();
    tecPin.clear();
    tecPinConfirm.clear();
  }

  void checkPinValidity() {
    final valid =
        tecPin.text.isNotEmpty && (formKey.currentState?.validate() ?? false);
    state = state.copyWith(enableMainButton: valid);
  }
}

final patientPortalForgotPinController = StateNotifierProvider.autoDispose<
    PatientPortalForgotPinController, PatientPortalForgotPinState>((ref) {
  return PatientPortalForgotPinController();
});
