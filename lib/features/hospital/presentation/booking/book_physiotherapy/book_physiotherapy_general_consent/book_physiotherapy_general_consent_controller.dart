import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/presentation.dart';

class BookPhysiotherapyGeneralConsentController
    extends StateNotifier<BookPhysiotherapyGeneralConsentState> {
  BookPhysiotherapyGeneralConsentController()
      : super(const BookPhysiotherapyGeneralConsentState());

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final dateOfBirthController = TextEditingController();

  void onRegister() {
    // DO SOMETHING
  }

  void toggleObscurePassword() {
    state = state.copyWith(
      isPasswordObscure: !state.isPasswordObscure,
    );
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void saveDate() {
    state = state.copyWith(savedDate: state.selectedDate ?? DateTime.now());
    dateOfBirthController.text = state.savedDate?.slashDate ?? '-';
  }

  void changeGender(String? gender) {
    state = state.copyWith(
      selectedGender: gender,
    );
  }

  onAgreeChange(bool? val) {
    state = state.copyWith(
      isAgree: val,
    );
  }
}

final bookPhysiotherapyGeneralConsentControllerProvider =
    StateNotifierProvider.autoDispose<BookPhysiotherapyGeneralConsentController,
        BookPhysiotherapyGeneralConsentState>((ref) {
  return BookPhysiotherapyGeneralConsentController();
});
