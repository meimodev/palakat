import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class RegistrationController extends StateNotifier<RegistrationState> {
  RegistrationController({
    required this.authService,
  }) : super(const RegistrationState());

  final AuthenticationService authService;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final placeOfBirthController = TextEditingController();
  final dateOfBirthController = TextEditingController();

  String get firstName => firstNameController.text;
  String get lastName => lastNameController.text;
  String get email => emailController.text;
  String get phone => phoneController.text;
  String get password => passwordController.text;
  String get placeOfBirth => placeOfBirthController.text;
  String get dateOfBirth => dateOfBirthController.text;

  void init(SignUpType signUpType, {String? email, String? phone}) {
    state = state.copyWith(selectedSignUpMode: signUpType);

    if (email != null) {
      emailController.text = email;
    }

    if (phone != null) {
      phoneController.text = phone;
    }
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

  void onRegister(BuildContext context) async {
    clearAllError();

    if ([SignUpType.email, SignUpType.social]
        .contains(state.selectedSignUpMode)) {
      state = state.copyWith(valid: const AsyncLoading());

      final result = await authService.register(
        type: state.selectedSignUpMode.name,
        email: email,
        password: password,
        phone: phone,
        firstName: firstName,
        lastName: lastName,
        placeOfBirth: placeOfBirth,
        dateOfBirth: state.savedDate,
        genderSerial: state.selectedGender,
      );

      result.when(
        success: (data) async {
          state = state.copyWith(
            valid: const AsyncData(true),
          );

          if (state.selectedSignUpMode == SignUpType.email) {
            await showGeneralDialogWidget(
              context,
              image: Assets.images.mailList.image(
                width: BaseSize.customWidth(100),
                height: BaseSize.customHeight(100),
              ),
              title: LocaleKeys.text_checkYourEmailAddress.tr(),
              subtitle:
                  LocaleKeys.text_registrationEmailHasBeenSentToYourEmail.tr(),
              content: Column(
                children: [
                  Gap.h20,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        LocaleKeys.text_didntGetTheEmail.tr(),
                        style: TypographyTheme.textMRegular.toNeutral60,
                      ),
                      Gap.w4,
                      RippleTouch(
                        child: Text(
                          LocaleKeys.text_resendEmail.tr(),
                          style: TypographyTheme.textMRegular.toPrimary,
                        ),
                        onTap: () {
                          authService.resendEmail(email: email);
                          context.goNamed(AppRoute.login);
                          Snackbar.success(
                            message: LocaleKeys
                                .text_emailVerificationHasBeenResend
                                .tr(),
                          );
                        },
                      )
                    ],
                  ),
                  Gap.h40,
                ],
              ),
              primaryButtonTitle: LocaleKeys.text_backToHome.tr(),
              action: () => context.goNamed(AppRoute.login),
            );
          }

          if (context.mounted) context.goNamed(AppRoute.login);
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
    } else {
      state = state.copyWith(valid: const AsyncLoading());

      final result = await authService.register(
        type: SignUpType.phone.name,
        email: email,
        password: password,
        phone: phone,
        firstName: firstName,
        lastName: lastName,
        placeOfBirth: placeOfBirth,
        dateOfBirth: state.savedDate,
        genderSerial: state.selectedGender,
      );

      result.when(
        success: (data) {
          state = state.copyWith(
            valid: const AsyncData(true),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Consumer(
                builder: (context, ref, child) {
                  final registerFormState =
                      ref.watch(registrationControllerProvider);
                  return OtpVerificationScreen(
                    phone: phone,
                    type: OtpType.registerUser,
                    isPublic: true,
                    scaffoldType: ScaffoldType.authGradient,
                    onSubmit: (val) => onRegisterWithPhone(
                      context: context,
                      otp: val,
                    ),
                    isErrorSubmit: registerFormState.errors['otp'] != null,
                    onChange: (val) => clearError('otp'),
                  );
                },
              ),
            ),
          );
        },
        failure: (error, _) {
          state = state.copyWith(
            valid: const AsyncData(true),
          );
          final message = NetworkExceptions.getErrorMessage(error);
          final errors = NetworkExceptions.getErrors(error);
          final faultCode = NetworkExceptions.getFaultCode(error);

          if (faultCode == ApiFaultCode.mheUserRegisterOtpIncorrect) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Consumer(
                  builder: (context, ref, child) {
                    final registerFormState =
                        ref.watch(registrationControllerProvider);
                    return OtpVerificationScreen(
                      phone: phone,
                      type: OtpType.registerUser,
                      isPublic: true,
                      scaffoldType: ScaffoldType.authGradient,
                      onSubmit: (val) => onRegisterWithPhone(
                        context: context,
                        otp: val,
                      ),
                      isErrorSubmit: registerFormState.errors['otp'] != null,
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
  }

  Future onRegisterWithPhone(
      {required BuildContext context, String? otp}) async {
    state = state.copyWith(valid: const AsyncLoading());

    final result = await authService.register(
      type: SignUpType.phone.name,
      email: email,
      password: password,
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      placeOfBirth: placeOfBirth,
      dateOfBirth: state.savedDate,
      genderSerial: state.selectedGender,
      otp: otp,
    );

    result.when(
      success: (data) {
        state = state.copyWith(
          valid: const AsyncData(true),
        );

        Snackbar.success(message: LocaleKeys.text_registerSuccessful.tr());
        context.pop();
        context.goNamed(AppRoute.login);
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

  void toggleObscurePassword() {
    state = state.copyWith(
      isPasswordObscure: !state.isPasswordObscure,
    );
  }

  void saveDate(DateTime date) {
    dateOfBirthController.text = date.slashDate;
    state = state.copyWith(savedDate: date);
    clearError('dateOfBirth');
  }

  void changeGender(String? gender) {
    state = state.copyWith(
      selectedGender: gender,
    );
    clearError('genderSerial');
  }

  onAgreeChange(bool? val) {
    state = state.copyWith(
      isAgree: val,
    );
  }
}

final registrationControllerProvider = StateNotifierProvider.autoDispose<
    RegistrationController, RegistrationState>((ref) {
  return RegistrationController(
    authService: ref.read(authenticationServiceProvider),
  );
});
