import 'package:halo_hermina/core/constants/constants.dart';

class BookPregnancyGeneralConsentState {
  final bool isRegisterValid;
  final bool isPasswordObscure;
  final bool isAgree;
  final DateTime? selectedDate;
  final DateTime? savedDate;
  final String? selectedGender;

  const BookPregnancyGeneralConsentState(
      {this.isRegisterValid = false,
      this.isPasswordObscure = true,
      this.isAgree = false,
      this.selectedDate,
      this.savedDate,
      this.selectedGender});

  BookPregnancyGeneralConsentState copyWith(
      {bool? isRegisterValid,
      bool? isPasswordObscure,
      bool? isAgree,
      final DateTime? selectedDate,
      final DateTime? savedDate,
      String? selectedGender}) {
    return BookPregnancyGeneralConsentState(
      isRegisterValid: isRegisterValid ?? this.isRegisterValid,
      isPasswordObscure: isPasswordObscure ?? this.isPasswordObscure,
      isAgree: isAgree ?? this.isAgree,
      selectedDate: selectedDate ?? this.selectedDate,
      savedDate: savedDate ?? this.savedDate,
      selectedGender: selectedGender ?? this.selectedGender,
    );
  }
}
