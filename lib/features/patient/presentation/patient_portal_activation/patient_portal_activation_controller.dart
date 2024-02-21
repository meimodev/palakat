import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/network/model/network_exceptions.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:halo_hermina/features/shared/domain/media_upload.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class PatientPortalActivationController
    extends StateNotifier<PatientPortalActivationState> {
  PatientPortalActivationController(
    this._patientService,
    this._accountService,
  ) : super(const PatientPortalActivationState()) {
    init();
  }

  final PatientService _patientService;
  final AccountService _accountService;

  final tecFirstName = TextEditingController();
  final tecLastName = TextEditingController();
  final tecDateOfBirth = TextEditingController();
  final tecPhoneNumber = TextEditingController();
  final tecEmail = TextEditingController();
  final tecIdentityCard = TextEditingController();
  final tecIdentityCardNumber = TextEditingController();

  String get firstName => tecFirstName.text;

  String get lastName => tecLastName.text;

  String get dateOfBirth => tecDateOfBirth.text;

  String get phoneNumber => tecPhoneNumber.text;

  String get email => tecEmail.text;

  String get identityCard => tecIdentityCard.text;

  String get identityCardNumber => tecIdentityCardNumber.text;

  UserData? get user => _accountService.user;

  void init() {
    if (user != null) {
      tecFirstName.text = user!.firstName;
      tecLastName.text = user!.lastName;
      tecDateOfBirth.text = user!.dateOfBirth?.toDateTime?.ddMmmmYyyy ?? "";
      tecPhoneNumber.text = user!.phone ?? "";
      tecEmail.text = user!.email ?? "";
      tecIdentityCard.text = user!.identityType?.label ?? "";
      tecIdentityCardNumber.text = user!.ktpNumber ?? "";

      state = state.copyWith(genderSerial: user!.gender!.serial);
    }
  }

  void setIdentity(IdentityType val) {
    tecIdentityCard.text = val.label;
    switch (val) {
      case IdentityType.ktp:
        tecIdentityCardNumber.text = user?.ktpNumber ?? "";
        break;
      case IdentityType.passport:
        tecIdentityCardNumber.text = user?.passportNumber ?? "";
        break;
    }
    state = state.copyWith(
      selectedIdentity: val,
    );
    checkProceed();
  }

  void setTNCAccept(bool value) {
    state = state.copyWith(tncAccept: value);
    checkProceed();
  }

  void onPhotoChange(MediaUpload media) {
    state = state.copyWith(selectedPhoto: media);
    checkProceed();
  }

  void onPhotoWithIdCardChange(MediaUpload media) {
    state = state.copyWith(selectedPhotoWithIdentityCard: media);
    checkProceed();
  }

  void onPhotoRemove() {
    state = state.copyWith(selectedPhoto: const MediaUpload());
    checkProceed();
  }

  void onPhotoWithIdCardRemove() {
    state = state.copyWith(selectedPhotoWithIdentityCard: const MediaUpload());
    checkProceed();
  }

  void checkProceed() {
    final List<String> data = [
      firstName,
      lastName,
      phoneNumber,
      email,
      identityCardNumber,
      state.genderSerial,
      state.selectedPhoto?.fileURL ?? "",
      state.selectedPhotoWithIdentityCard?.fileURL ?? "",
      state.tncAccept ? "OK" : "",
      state.errors.isEmpty ? "OK" : "",
    ];

    final canProceed = !data.contains("");
    state = state.copyWith(canProceed: canProceed);
  }

  void onPressedSubmit({
    required void Function(ActivatePatientPortalFormRequest formData) onProceed,
  }) async {
    state = state.copyWith(loading: true);

    final result = await _patientService.activatePatientPortalForm(
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth.toFormattedDate(format: "dd MMMM yyyy"),
      phone: phoneNumber,
      email: email,
      identityType: state.selectedIdentity,
      identityNumber: identityCardNumber,
      identityCardSerial: state.selectedPhotoWithIdentityCard!.serial,
      photoSerial: state.selectedPhotoWithIdentityCard!.serial,
    );

    result.when(
      success: (response) {
        state = state.copyWith(loading: false);
        successProceed(onProceed);
      },
      failure: (error, st) {
        state = state.copyWith(loading: false);
        final message = NetworkExceptions.getErrorMessage(error);
        final faultCode = NetworkExceptions.getFaultCode(error);

        if (faultCode == ApiFaultCode.mheOtpIsMandatory) {
          successProceed(onProceed);
        } else {
          Snackbar.error(message: message);
        }
      },
    );
  }

  void successProceed(
    void Function(ActivatePatientPortalFormRequest formData) onProceed,
  ) {
    onProceed(
      ActivatePatientPortalFormRequest(
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth.toFormattedDate(format: "dd MMMM yyyy"),
        phone: phoneNumber,
        email: email,
        identityType: state.selectedIdentity,
        identityNumber: identityCardNumber,
        identityCardSerial: state.selectedPhotoWithIdentityCard!.serial,
        photoSerial: state.selectedPhotoWithIdentityCard!.serial,
      ),
    );
  }
}

final patientPortalActivationController = StateNotifierProvider.autoDispose<
    PatientPortalActivationController, PatientPortalActivationState>((ref) {
  return PatientPortalActivationController(
    ref.read(patientServiceProvider),
    ref.read(accountServiceProvider),
  );
});
