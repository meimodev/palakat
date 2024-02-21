import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class LoginController extends StateNotifier<LoginState> {
  LoginController({
    required this.authService,
    required this.accountService,
    required this.context,
  }) : super(const LoginState());

  final AuthenticationService authService;
  final AccountService accountService;
  final BuildContext context;

  final emailNode = FocusNode();
  final passwordNode = FocusNode();
  final numberNode = FocusNode();

  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  get email => emailController.text;
  get phone => phoneController.text;
  get password => passwordController.text;

  void init(bool? redirectBack) {
    state = state.copyWith(redirectBack: redirectBack ?? false);
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

  void onLogin(BuildContext context) async {
    clearAllError();

    if (state.selectedLoginMode == LoginType.email) {
      state = state.copyWith(isLoading: true);

      final result = await authService.login(
        username: email,
        password: password,
        type: state.selectedLoginMode.name,
      );

      result.when(
        success: handleSuccessLogin,
        failure: (error, _) {
          state = state.copyWith(isLoading: false);
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
      state = state.copyWith(isLoading: true);

      final result = await authService.checkPhone(
        phone: phone,
      );

      result.when(
        success: (data) async {
          state = state.copyWith(isLoading: false);

          // TODO: Change to gorouting to ensure navigator recorded in sentry
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Consumer(
                builder: (context, ref, child) {
                  final registerFormState =
                      ref.watch(registrationControllerProvider);
                  return OtpVerificationScreen(
                    phone: phone,
                    type: OtpType.login,
                    isPublic: true,
                    scaffoldType: ScaffoldType.authGradient,
                    onSubmit: (val) => onLoginWithPhone(
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
          state = state.copyWith(isLoading: false);
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

  Future onLoginWithPhone({required BuildContext context, String? otp}) async {
    state = state.copyWith(isLoading: true);

    final result = await authService.login(
      username: phone,
      password: otp ?? '',
      type: LoginType.phone.name,
    );

    await result.when(
      success: handleSuccessLogin,
      failure: (error, _) {
        state = state.copyWith(isLoading: false);
        final message = NetworkExceptions.getErrorMessage(error);
        final errors = NetworkExceptions.getErrors(error);

        state = state.copyWith(errors: errors);

        Snackbar.error(message: message);
      },
    );
  }

  Future handleSuccessLogin(LoginResponse response) async {
    final userLang = await accountService.getUserLanguage();

    state = state.copyWith(isLoading: false);
    if (context.mounted) {
      if (userLang != null) {
        context.setLocale(userLang.languageKey.locale);
      }
      if (state.redirectBack) {
        context.popUntilNamedWithResult(targetRouteName: AppRoute.home, result: true);
      } else {
        context.goNamed(AppRoute.home);
      }
    }
  }

  void changeMode(LoginType selectedMode) {
    clearAllError();
    emailNode.unfocus();
    passwordNode.unfocus();
    numberNode.unfocus();
    emailController.clear();
    passwordController.clear();
    phoneController.clear();
    state = state.copyWith(
      selectedLoginMode: selectedMode,
    );
  }

  void toggleObscurePassword() {
    state = state.copyWith(
      isPasswordObscure: !state.isPasswordObscure,
    );
  }

  void handleErrorLoginSocial(
    NetworkExceptions error, {
    String? email,
  }) {
    state = state.copyWith(isLoading: false);
    final message = NetworkExceptions.getErrorMessage(error);
    final faultCode = NetworkExceptions.getFaultCode(error);
    final errors = NetworkExceptions.getErrors(error);

    if (faultCode == ApiFaultCode.mheAuthNotRegistered) {
      context.pushNamed(
        AppRoute.registration,
        extra: RouteParam(
          params: {
            RouteParamKey.signUpType: SignUpType.social,
            RouteParamKey.email: email,
          },
        ),
      );

      Snackbar.error(message: LocaleKeys.text_accountNotRegistered.tr());
    } else if (errors.isNotEmpty) {
      state = state.copyWith(
        errors: errors,
      );
    } else {
      Snackbar.error(message: message);
    }
  }

  void handleGoogleSignIn() async {
    if (!state.isLoading) {
      state = state.copyWith(isLoading: true);

      final user = await SocialSignIn.signInWithGoogle();

      if (user != null) {
        final result = await authService.loginSocial(
          type: LoginSocialType.google,
          email: user.email,
        );

        result.when(
          success: handleSuccessLogin,
          failure: (error, stackTrace) => handleErrorLoginSocial(
            error,
            email: user.email,
          ),
        );
      }

      state = state.copyWith(isLoading: false);
    }
  }

  void handleFacebookSignIn() async {
    if (!state.isLoading) {
      state = state.copyWith(isLoading: true);

      final userData = await SocialSignIn.signInWithFacebook();

      if (userData != null && userData['email'] != null) {
        final result = await authService.loginSocial(
          type: LoginSocialType.facebook,
          email: userData['email'],
        );

        result.when(
          success: handleSuccessLogin,
          failure: (error, stackTrace) => handleErrorLoginSocial(
            error,
            email: userData['email'],
          ),
        );
      }

      state = state.copyWith(isLoading: false);
    }
  }

  void handleAppleSignIn() async {
    if (!state.isLoading) {
      state = state.copyWith(isLoading: true);

      var credential = await SocialSignIn.signInWithApple();

      if (credential.email != null && credential.userIdentifier != null) {
        final resultSaveSocialProvider = await authService.saveSocialProvider(
          type: LoginSocialType.apple,
          email: credential.email ?? "",
          providerID: credential.userIdentifier ?? "",
        );

        if (resultSaveSocialProvider is Failure) {
          handleErrorLoginSocial(
            (resultSaveSocialProvider as Failure).error,
          );

          Snackbar.error(message: LocaleKeys.text_loginWithAppleFailed.tr());

          return;
        }
      }

      String? currentEmail = credential.email;

      if (currentEmail == null) {
        final resultCheckEmail = await authService.checkEmailSocialProvider(
          type: LoginSocialType.apple,
          providerID: credential.userIdentifier ?? "",
        );

        if (resultCheckEmail is Success) {
          currentEmail =
              (resultCheckEmail as Success<EmailResponse>).data.email;
        } else {
          handleErrorLoginSocial(
            (resultCheckEmail as Failure).error,
          );

          Snackbar.error(message: LocaleKeys.text_loginWithAppleFailed.tr());

          return;
        }
      }

      final result = await authService.loginSocial(
        type: LoginSocialType.apple,
        email: currentEmail,
      );

      result.when(
        success: handleSuccessLogin,
        failure: (error, stackTrace) => handleErrorLoginSocial(
          error,
          email: currentEmail,
        ),
      );

      state = state.copyWith(isLoading: false);
    }
  }
}

final loginControllerProvider =
    StateNotifierProvider.family<LoginController, LoginState, BuildContext>(
        (ref, context) {
  return LoginController(
    authService: ref.read(authenticationServiceProvider),
    accountService: ref.read(accountServiceProvider),
    context: context,
  );
});
