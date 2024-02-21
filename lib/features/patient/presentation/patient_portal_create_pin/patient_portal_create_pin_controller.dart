import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/api/api_fault_code.dart';
import 'package:halo_hermina/core/datasources/network/model/network_exceptions.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class PatientPortalCreatePinController
    extends StateNotifier<PatientPortalCreatePinState> {
  PatientPortalCreatePinController(this._sharedService, this._patientService)
      : super(
          const PatientPortalCreatePinState(
            duration: Duration(seconds: 30),
          ),
        );

  final SharedService _sharedService;
  final PatientService _patientService;

  final tecVerificationCode = TextEditingController();
  final tecNewPin = TextEditingController();
  final tecNewPinConfirm = TextEditingController();

  final formKey = GlobalKey<FormState>();

  String get otp => tecVerificationCode.text;

  String get newPinConfirm => tecNewPinConfirm.text;

  void requestOtp(String phone, OtpProvider provider) async {
    state = state.copyWith(loading: true);

    final result = await _sharedService.requestOtpPublic(
      phone: phone,
      provider: provider.name,
      type: OtpType.registerPatientPortal.key,
    );

    result.when(
      success: (data) {
        state = state.copyWith(
          loading: false,
          duration: Duration(seconds: data.duration),
        );
      },
      failure: handleApiErrors,
    );
  }

  void onPressedSubmit(
    ActivatePatientPortalFormRequest formData,
    VoidCallback onProceed,
  ) async {
    state = state.copyWith(loading: true);

    final result = await _patientService.activatePatientPortalForm(
      firstName: formData.firstName,
      lastName: formData.lastName,
      dateOfBirth: formData.dateOfBirth,
      email: formData.email,
      phone: formData.phone,
      identityType: formData.identityType,
      identityNumber: formData.identityNumber,
      identityCardSerial: formData.identityCardSerial,
      photoSerial: formData.photoSerial,
    );

    result.when(
      success: (data) {
        state = state.copyWith(loading: false);
        onProceed();
      },
      failure: handleApiErrors,
    );
  }

  void handleApiErrors(NetworkExceptions error, StackTrace st) {
    state = state.copyWith(loading: false);
    final message = NetworkExceptions.getErrorMessage(error);
    final faultCode = NetworkExceptions.getFaultCode(error);

    if (faultCode == ApiFaultCode.mheOtpIsMandatory ||
        faultCode == ApiFaultCode.mheOtpIsInvalid) {
      state = state.copyWith(errorOtp: message);
      return;
    }

    Snackbar.error(message: message);
  }

  void checkProceed() {
    final valid = formKey.currentState?.validate() ?? false;
    state = state.copyWith(canProceed: valid);
  }

  void onChangedOtp(String value) {
    state = state.copyWith(errorOtp: "");
    checkProceed();
  }
}

final patientPortalCreatePinProvider = StateNotifierProvider.autoDispose<
    PatientPortalCreatePinController, PatientPortalCreatePinState>(
  (ref) => PatientPortalCreatePinController(
    ref.read(sharedServiceProvider),
    ref.read(patientServiceProvider),
  ),
);
