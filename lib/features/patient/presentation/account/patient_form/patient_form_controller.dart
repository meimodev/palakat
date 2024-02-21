import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/network/network.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class PatientFormController extends StateNotifier<PatientFormState> {
  PatientFormController(this.patientService, this.sharedService)
      : super(
          PatientFormState(),
        );

  late BuildContext _context;
  final PatientService patientService;
  final SharedService sharedService;

  static String ktpKey = 'KTP';

  final scrollController = ScrollController();

  final medicalFormKey = GlobalKey<FormState>();
  final patientFormKey = GlobalKey<FormState>();
  final mrnController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final titleController = TextEditingController();
  final placeOfBirthController = TextEditingController();
  final identityCardTypeController = TextEditingController();
  final identityCardNumberController = TextEditingController();
  final addressController = TextEditingController();
  final rtNumberController = TextEditingController();
  final rwNumberController = TextEditingController();
  final provinceController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final villageController = TextEditingController();
  final postalCodeController = TextEditingController();
  final religionController = TextEditingController();
  final maritalController = TextEditingController();
  final educationController = TextEditingController();
  final occupationController = TextEditingController();
  final citizenshipController = TextEditingController();
  final ethnicController = TextEditingController();

  String get mrn => mrnController.text;

  String get firstName => firstNameController.text;

  String get lastName => lastNameController.text;

  String get dateOfBirth => dateOfBirthController.text;

  String get email => emailController.text;

  String get phone => phoneController.text;

  String get title => titleController.text;

  String get placeOfBirth => placeOfBirthController.text;

  String get identityCardType => identityCardTypeController.text;

  String get identityCardNumber => identityCardNumberController.text;

  String get address => addressController.text;

  String get rtNumber => rtNumberController.text;

  String get rwNumber => rwNumberController.text;

  String get province => provinceController.text;

  String get city => cityController.text;

  String get district => districtController.text;

  String get village => villageController.text;

  String get postalCode => postalCodeController.text;

  String get religion => religionController.text;

  String get marital => maritalController.text;

  String get education => educationController.text;

  String get occupation => occupationController.text;

  String get citizenship => citizenshipController.text;

  String get ethnic => ethnicController.text;

  List<String> steps = [
    LocaleKeys.text_personalInformation.tr(),
    LocaleKeys.text_addressInformation.tr(),
    LocaleKeys.text_additionalInformation.tr(),
    LocaleKeys.text_generalConsent.tr()
  ];

  void init(BuildContext context) async {
    _context = context;

    state = state.copyWith(isFetchingInitialData: true);
    await loadInitialData();
    state = state.copyWith(isFetchingInitialData: false);
  }

  loadInitialData() async {
    final resultGender =
        await sharedService.getGeneralDataGender(page: 1, pageSize: 10);

    resultGender.when(
      success: (data) {
        state = state.copyWith(genderOptions: data);
      },
      failure: (error, _) {
        final message = NetworkExceptions.getErrorMessage(error);
        Snackbar.error(message: message);
        toPatientList();
      },
    );
  }

  void clearError(String key) {
    if (state.errors.containsKey(key)) {
      final errors = state.errors;
      errors.removeWhere((k, _) => k == key);
      state = state.copyWith(
        errors: errors,
      );
    }
  }

  void clearAllError() {
    state = state.copyWith(errors: {});
  }

  void toPatientList() {
    if (_context.mounted) {
      _context.popUntilBeforeNamed(targetRouteName: AppRoute.patientForm);
    }
  }

  void changeHaveBeenTreated(YesOrNoAnswer? answer) {
    state = state.copyWith(
      haveBeenTreated: answer,
    );
  }

  void changeGender(String? val) {
    state = state.copyWith(selectedGender: val);
    clearError("genderSerial");
  }

  void saveDateOfBirth(DateTime date) {
    dateOfBirthController.text = date.slashDate;
    state = state.copyWith(savedDate: date);
    clearError('dateOfBirth');
  }

  void onTitleChange(GeneralData val) {
    state = state.copyWith(selectedTitle: val);
    clearError("titleSerial");

    titleController.text = val.value;
  }

  void onIdentityCardTypeChange(IdentityType val) {
    state = state.copyWith(selectedIdentityType: val);
    clearError("identityType");

    identityCardTypeController.text = val.label;
  }

  void onProvinceChange(GeneralData val) {
    state = state.copyWith(selectedProvince: val);
    clearError("provinceSerial");

    provinceController.text = val.value;
  }

  void onCityChange(GeneralData val) {
    state = state.copyWith(selectedCity: val);
    clearError("citySerial");

    cityController.text = val.value;
  }

  void onDistrictChange(GeneralData val) {
    state = state.copyWith(selectedDistrict: val);
    clearError("districtSerial");

    districtController.text = val.value;
  }

  void onVillageChange(GeneralData val) {
    state = state.copyWith(selectedVillage: val);
    clearError("villageSerial");

    villageController.text = val.value;
  }

  void onReligionChange(GeneralData val) {
    state = state.copyWith(selectedReligion: val);
    clearError("religionSerial");

    religionController.text = val.value;
  }

  void onMaritalChange(GeneralData val) {
    state = state.copyWith(selectedMarital: val);
    clearError("maritalSerial");

    maritalController.text = val.value;
  }

  void onEducationChange(GeneralData val) {
    state = state.copyWith(selectedEducation: val);
    clearError("educationSerial");

    educationController.text = val.value;
  }

  void onOccupationChange(GeneralData val) {
    state = state.copyWith(selectedOccupation: val);
    clearError("occupationSerial");

    occupationController.text = val.value;
  }

  void onCitizenshipChange(GeneralData val) {
    state = state.copyWith(selectedCitizenship: val);
    clearError("citizenshipSerial");

    citizenshipController.text = val.value;
  }

  void onEthnicChange(GeneralData val) {
    state = state.copyWith(selectedEthnic: val);
    clearError("ethnicSerial");

    ethnicController.text = val.value;
  }

  void onPhotoChange(MediaUpload val) {
    state = state.copyWith(selectedPhoto: val);
    clearError("identityCardSerial");
  }

  void onPhotoRemove() {
    state = state.copyWith(selectedPhoto: const MediaUpload());
  }

  void onPhotoWithIdCardChange(MediaUpload val) {
    state = state.copyWith(selectedPhotoWithIdCard: val);
    clearError("photoSerial");
  }

  void onPhotoWithIdCardRemove() {
    state = state.copyWith(selectedPhotoWithIdCard: const MediaUpload());
  }

  onAgreeChange(bool? val) {
    state = state.copyWith(
      isAgree: val,
    );
  }

  void handleNextNewPatient() {
    state = state.copyWith(
      patientType: PatientType.withNoMrn,
    );
  }

  void onPatientPhoneChange(String? val) {
    state = state.copyWith(selectedPatientPhone: val);
  }

  bool isValidGeneralConsentAgreement() {
    if (state.formStep == steps.length - 1) {
      return state.isAgree;
    }

    return true;
  }

  void onBackPatientFormStep() {
    if (state.formStep > 0) {
      state = state.copyWith(formStep: state.formStep -= 1);
    } else {
      state = state.copyWith(
        patientType: PatientType.withMrn,
      );
    }
  }

  void onNextPatientFormStep() {
    scrollController.jumpTo(0);
    state = state.copyWith(formStep: state.formStep += 1);
  }

  Future onPatientWithNoMRNSubmit({
    bool isVisitFrontOffice = false,
    String? otp,
  }) async {
    clearAllError();

    state = state.copyWith(valid: const AsyncLoading());

    final result = await patientService.registerPatientForm(
      step: state.formStep + 1,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      dateOfBirth: state.savedDate,
      titleSerial: state.selectedTitle?.serial,
      placeOfBirth: placeOfBirth,
      identityType: state.selectedIdentityType,
      identityNumber: identityCardNumber,
      genderSerial: state.selectedGender,
      address: address,
      rtNumber: rtNumber,
      rwNumber: rwNumber,
      provinceSerial: state.selectedProvince?.serial,
      citySerial: state.selectedCity?.serial,
      districtSerial: state.selectedDistrict?.serial,
      villageSerial: state.selectedVillage?.serial,
      postalCode: postalCode,
      religionSerial: state.selectedReligion?.serial,
      maritalSerial: state.selectedMarital?.serial,
      educationSerial: state.selectedEducation?.serial,
      occupationSerial: state.selectedOccupation?.serial,
      citizenshipSerial: state.selectedCitizenship?.serial,
      ethnicSerial: state.selectedEthnic?.serial,
      photoSerial: state.selectedPhoto?.serial,
      identityCardSerial: state.selectedPhotoWithIdCard?.serial,
      isVisitFrontOffice: isVisitFrontOffice ? isVisitFrontOffice : null,
      otp: otp,
    );

    await result.when(
      success: (data) async {
        state = state.copyWith(
          valid: const AsyncData(true),
        );

        await showGeneralDialogWidget(
          _context,
          image: Assets.images.check.image(
            width: BaseSize.customWidth(100),
            height: BaseSize.customWidth(100),
          ),
          title: LocaleKeys.text_registrationComplete.tr(),
          subtitle:
              LocaleKeys.text_youhaveToWaitForApprovalMaximum1x24Hours.tr(),
          primaryButtonTitle: LocaleKeys.text_backToPatientList.tr(),
          content: Gap.h24,
          action: () {
            _context.pop();
          },
        );

        if (_context.mounted) {
          toPatientList();
        }
      },
      failure: (error, _) async {
        state = state.copyWith(
          valid: const AsyncData(true),
        );
        final message = NetworkExceptions.getErrorMessage(error);
        final errors = NetworkExceptions.getErrors(error);
        final faultCode = NetworkExceptions.getFaultCode(error);

        if (faultCode == ApiFaultCode.mhePatientOtpNotVerified) {
          final faultData = NetworkExceptions.getFaultData(error);
          var phones = faultData['phones'];
          if (phones != null) {
            await showPatientPhoneNumberSelect(_context,
                phones: List<String>.from(phones));
          }
        } else if (faultCode ==
            ApiFaultCode.mhePatientCreatePatientOtpIncorrect) {
          state = state.copyWith(
            errors: {'otp': message},
          );
        } else if (faultCode == ApiFaultCode.mhePatientDataIncompleted) {
          onNextPatientFormStep();
        } else {
          if (errors.isNotEmpty) {
            state = state.copyWith(
              errors: errors,
            );
          } else {
            Snackbar.error(message: message);
          }
        }
      },
    );
  }

  Future onPatientMRNSubmit(
      {bool isVisitFrontOffice = false, String? otp}) async {
    if (medicalFormKey.currentState!.validate()) {
      clearAllError();

      state = state.copyWith(valid: const AsyncLoading());

      final result = await patientService.registerPatientMRN(
          mrn: mrn,
          dateOfBirth: state.savedDate,
          isVisitFrontOffice: isVisitFrontOffice ? isVisitFrontOffice : null,
          otp: otp,
          phone: otp != null ? state.selectedPatientPhone : null);

      await result.when(
        success: (data) async {
          state = state.copyWith(
            valid: const AsyncData(true),
          );

          _context.pop();
          await showGeneralDialogWidget(
            _context,
            image: Assets.images.check.image(
              width: BaseSize.customWidth(100),
              height: BaseSize.customWidth(100),
            ),
            title: LocaleKeys.text_registrationComplete.tr(),
            subtitle:
                LocaleKeys.text_youhaveToWaitForApprovalMaximum1x24Hours.tr(),
            primaryButtonTitle: LocaleKeys.text_backToPatientList.tr(),
            action: () {
              _context.pop();
            },
          );

          if (_context.mounted) toPatientList();
        },
        failure: (error, _) async {
          state = state.copyWith(
            valid: const AsyncData(true),
          );
          final message = NetworkExceptions.getErrorMessage(error);
          final errors = NetworkExceptions.getErrors(error);
          final faultCode = NetworkExceptions.getFaultCode(error);

          if (faultCode == ApiFaultCode.mhePatientOtpNotVerified) {
            final faultData = NetworkExceptions.getFaultData(error);
            var phones = faultData['phones'];
            if (phones != null) {
              await showPatientPhoneNumberSelect(_context,
                  phones: List<String>.from(phones));
            }
          } else if (faultCode ==
              ApiFaultCode.mhePatientCreatePatientOtpIncorrect) {
            state = state.copyWith(
              errors: {'otp': message},
            );
          } else {
            if (errors.isNotEmpty) {
              state = state.copyWith(
                errors: errors,
              );
            } else {
              Snackbar.error(message: message);
            }
          }
        },
      );
    }
  }

  Future sendOtp() async {
    _context.pop();
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (_) => Consumer(
          builder: (context, ref, child) {
            final patientFormState = ref.watch(patientFormControllerProvider);
            return OtpVerificationScreen(
              phone: patientFormState.selectedPatientPhone,
              type: OtpType.registerPatient,
              onSubmit: (val) =>
                  patientFormState.patientType == PatientType.withNoMrn
                      ? onPatientWithNoMRNSubmit(otp: val)
                      : onPatientMRNSubmit(otp: val),
              isErrorSubmit: patientFormState.errors['otp'] != null,
              onChange: (val) => clearError('otp'),
            );
          },
        ),
      ),
    );
  }
}

final patientFormControllerProvider =
    StateNotifierProvider.autoDispose<PatientFormController, PatientFormState>(
  (ref) {
    return PatientFormController(
      ref.read(patientServiceProvider),
      ref.read(sharedServiceProvider),
    );
  },
);
