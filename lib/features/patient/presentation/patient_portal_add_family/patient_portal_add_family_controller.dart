import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';

class PatientPortalAddFamilyController
    extends StateNotifier<PatientPortalAddFamilyState> {
  PatientPortalAddFamilyController()
      : super(const PatientPortalAddFamilyState());

  final tecName = TextEditingController();
  final tecDateOfBirth = TextEditingController();

  void setGender(String? gender) {
    state = state.copyWith(gender: gender);
    checkProceed();
  }

  void setIdCardBase64(String base64String) {
    state = state.copyWith(idCardBase64: base64String);
    checkProceed();
  }

  void setIdCardAndPhotoBase64(String base64String) {
    state = state.copyWith(idCardAndPhotoBase64: base64String);
    checkProceed();
  }

  void setTNCAccept(bool value) {
    state = state.copyWith(tncAccept: value);
    checkProceed();
  }

  void checkProceed() {
    final List<String> data = [
      tecName.text,
      tecDateOfBirth.text,
      state.gender ?? "",
      state.idCardBase64,
      state.idCardAndPhotoBase64,
      state.tncAccept ? "Accepted" : ""
    ];

    final canProceed = !data.contains("");
    print("canProceed $canProceed");
    state = state.copyWith(canProceed: canProceed);
  }
}

final patientPortalAddFamilyController = StateNotifierProvider.autoDispose<
    PatientPortalAddFamilyController, PatientPortalAddFamilyState>((ref) {
  return PatientPortalAddFamilyController();
});
