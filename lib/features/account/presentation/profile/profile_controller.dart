import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:pinput/pinput.dart';

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController(this.accountService, this.context)
      : super(const ProfileState());

  final BuildContext context;
  final AccountService accountService;

  UserData? get user => accountService.user;

  // form
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final identityCardController = TextEditingController();
  final identityCardNumberController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final placeOfBirthController = TextEditingController();

  String get firstName => firstNameController.text;
  String get lastName => lastNameController.text;
  String get email => emailController.text;
  String get phone => phoneController.text;
  String get identityCard => identityCardController.text;
  String get identityNumber => identityCardNumberController.text;
  String get dateOfBirth => dateOfBirthController.text;
  String get placeOfBirth => placeOfBirthController.text;

  void init() async {
    final result = await accountService.getProfile();

    result.whenOrNull(
      success: (data) {
        firstNameController.setText(data.firstName);
        lastNameController.setText(data.lastName);
        emailController.setText(data.email ?? "");
        phoneController.setText(data.phone ?? "");
        identityCardController.setText(data.identityType?.label ?? "");
        identityCardNumberController.setText(data.identityNumber ?? "");
        dateOfBirthController.setText(data.dateOfBirth?.slashDate ?? "");
        placeOfBirthController.setText(data.placeOfBirth ?? "");

        state = state.copyWith(
          isLoading: false,
          selectedIdentity: data.identityType,
          savedDate: data.dateOfBirth?.toDateTime,
          selectedGender: data.gender?.serial,
        );
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

  void changeGender(String? gender) {
    state = state.copyWith(
      selectedGender: gender,
    );
    clearError("genderSerial");
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void saveIdentity(IdentityType val) {
    state = state.copyWith(selectedIdentity: val);
    clearError("identityType");
    identityCardController.text = val.label;
  }

  void saveDate(DateTime date) {
    state = state.copyWith(savedDate: state.selectedDate ?? DateTime.now());
    dateOfBirthController.text = state.savedDate?.slashDate ?? '-';
    clearError("dateOfBirth");
  }

  void onSubmit() async {
    clearAllError();
    state = state.copyWith(valid: const AsyncLoading());

    final result = await accountService.updateProfile(
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: state.savedDate,
      email: email,
      identityType: state.selectedIdentity,
      identityNumber: identityNumber,
      genderSerial: state.selectedGender,
      phone: phone,
      placeOfBirth: placeOfBirth,
    );

    result.when(
      success: (data) {
        state = state.copyWith(
          valid: const AsyncData(true),
        );

        context.pop();
        Snackbar.success(
          message: LocaleKeys.text_updateProfileSuccessful.tr(),
        );
      },
      failure: (error, _) {
        state = state.copyWith(
          valid: const AsyncData(true),
        );
        final message = NetworkExceptions.getErrorMessage(error);
        final errors = NetworkExceptions.getErrors(error);
        final faultCode = NetworkExceptions.getFaultCode(error);

        if (faultCode == ApiFaultCode.mheUserOtpIncorrect) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Consumer(
                builder: (context, ref, child) {
                  final profileFormState =
                      ref.watch(profileControllerProvider(context));
                  return OtpVerificationScreen(
                    phone: phone,
                    type: OtpType.changePhone,
                    isPublic: true,
                    scaffoldType: ScaffoldType.authGradient,
                    onSubmit: (val) => onSubmitChangePhone(
                      context: context,
                      otp: val,
                    ),
                    isErrorSubmit: profileFormState.errors['otp'] != null,
                    onChange: (val) => clearError('otp'),
                  );
                },
              ),
            ),
          );
        } else if (errors.isNotEmpty) {
          state = state.copyWith(
            errors: errors,
          );
        } else {
          Snackbar.error(message: message);
        }
      },
    );
  }

  Future onSubmitChangePhone({
    required BuildContext context,
    String? otp,
  }) async {
    state = state.copyWith(valid: const AsyncLoading());

    final result = await accountService.updateProfile(
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: state.savedDate,
      email: email,
      identityType: state.selectedIdentity,
      identityNumber: identityNumber,
      genderSerial: state.selectedGender,
      phone: phone,
      placeOfBirth: placeOfBirth,
      otp: otp,
    );

    result.when(
      success: (data) {
        state = state.copyWith(
          valid: const AsyncData(true),
        );

        context.pop();
        Snackbar.success(
          message: LocaleKeys.text_updateProfileSuccessful.tr(),
        );
      },
      failure: (error, _) {
        state = state.copyWith(
          valid: const AsyncData(true),
        );
        final message = NetworkExceptions.getErrorMessage(error);
        final errors = NetworkExceptions.getErrors(error);

        if (errors.isNotEmpty) {
          state = state.copyWith(
            errors: errors,
          );
        } else {
          Snackbar.error(message: message);
        }
      },
    );
  }
}

final profileControllerProvider = StateNotifierProvider.family
    .autoDispose<ProfileController, ProfileState, BuildContext>(
  (ref, context) {
    return ProfileController(ref.read(accountServiceProvider), context);
  },
);
