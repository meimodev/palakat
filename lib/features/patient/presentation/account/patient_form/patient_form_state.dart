import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/features/domain.dart';

enum PatientType { withMrn, withNoMrn }

class PatientFormState {
  final bool isFetchingInitialData;
  final PatientType? patientType;
  final String? medicalRecordNumber;
  final YesOrNoAnswer? haveBeenTreated;
  final String? selectedGender;
  final String selectedPatientPhone;
  final GeneralData? selectedTitle;
  final DateTime? savedDate;
  final IdentityType? selectedIdentityType;
  final GeneralData? selectedProvince;
  final GeneralData? selectedCity;
  final GeneralData? selectedDistrict;
  final GeneralData? selectedVillage;
  final GeneralData? selectedReligion;
  final GeneralData? selectedMarital;
  final GeneralData? selectedEducation;
  final GeneralData? selectedOccupation;
  final GeneralData? selectedCitizenship;
  final GeneralData? selectedEthnic;
  final MediaUpload? selectedPhoto;
  final MediaUpload? selectedPhotoWithIdCard;
  final bool isAgree;
  final Map<String, dynamic> errors;
  final AsyncValue<bool?> valid;
  int formStep;
  final Map<String, String> genderOptions;

  PatientFormState(
      {this.isFetchingInitialData = false,
      this.patientType,
      this.medicalRecordNumber,
      this.haveBeenTreated,
      this.savedDate,
      this.selectedGender,
      this.selectedPatientPhone = '',
      this.selectedTitle,
      this.selectedIdentityType,
      this.selectedProvince,
      this.selectedCity,
      this.selectedDistrict,
      this.selectedVillage,
      this.selectedReligion,
      this.selectedMarital,
      this.selectedEducation,
      this.selectedOccupation,
      this.selectedCitizenship,
      this.selectedEthnic,
      this.selectedPhoto,
      this.selectedPhotoWithIdCard,
      this.isAgree = false,
      this.errors = const {},
      this.valid = const AsyncData(null),
      this.formStep = 0,
      this.genderOptions = const {}});

  PatientFormState copyWith(
      {bool? isFetchingInitialData,
      PatientType? patientType,
      DateTime? savedDate,
      String? medicalRecordNumber,
      YesOrNoAnswer? haveBeenTreated,
      String? selectedGender,
      String? selectedPatientPhone,
      GeneralData? selectedTitle,
      IdentityType? selectedIdentityType,
      GeneralData? selectedProvince,
      GeneralData? selectedCity,
      GeneralData? selectedDistrict,
      GeneralData? selectedVillage,
      GeneralData? selectedReligion,
      GeneralData? selectedMarital,
      GeneralData? selectedEducation,
      GeneralData? selectedOccupation,
      GeneralData? selectedCitizenship,
      GeneralData? selectedEthnic,
      MediaUpload? selectedPhoto,
      MediaUpload? selectedPhotoWithIdCard,
      bool? isAgree,
      Map<String, dynamic>? errors,
      AsyncValue<bool?>? valid,
      int? formStep,
      Map<String, String>? genderOptions}) {
    return PatientFormState(
      savedDate: savedDate ?? this.savedDate,
      isFetchingInitialData:
          isFetchingInitialData ?? this.isFetchingInitialData,
      patientType: patientType ?? this.patientType,
      medicalRecordNumber: medicalRecordNumber ?? this.medicalRecordNumber,
      haveBeenTreated: haveBeenTreated ?? this.haveBeenTreated,
      selectedGender: selectedGender ?? this.selectedGender,
      selectedPatientPhone: selectedPatientPhone ?? this.selectedPatientPhone,
      selectedTitle: selectedTitle ?? this.selectedTitle,
      selectedIdentityType: selectedIdentityType ?? this.selectedIdentityType,
      selectedProvince: selectedProvince ?? this.selectedProvince,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      selectedVillage: selectedVillage ?? this.selectedVillage,
      selectedReligion: selectedReligion ?? this.selectedReligion,
      selectedMarital: selectedMarital ?? this.selectedMarital,
      selectedEducation: selectedEducation ?? this.selectedEducation,
      selectedOccupation: selectedOccupation ?? this.selectedOccupation,
      selectedCitizenship: selectedCitizenship ?? this.selectedCitizenship,
      selectedEthnic: selectedEthnic ?? this.selectedEthnic,
      selectedPhoto: selectedPhoto ?? this.selectedPhoto,
      selectedPhotoWithIdCard:
          selectedPhotoWithIdCard ?? this.selectedPhotoWithIdCard,
      isAgree: isAgree ?? this.isAgree,
      errors: errors ?? this.errors,
      valid: valid ?? this.valid,
      formStep: formStep ?? this.formStep,
      genderOptions: genderOptions ?? this.genderOptions,
    );
  }
}
