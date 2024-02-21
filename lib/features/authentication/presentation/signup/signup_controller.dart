import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/utils/social_sign_in.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class SignUpController extends StateNotifier<SignUpState> {
  SignUpController({
    required this.context,
    required this.authService,
    required this.accountService,
  }) : super(const SignUpState());

  final BuildContext context;
  final AuthenticationService authService;
  final AccountService accountService;

  final emailNode = FocusNode();
  final numberNode = FocusNode();

  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  get email => emailController.text;
  get phone => phoneController.text;

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

  void onSignUp(BuildContext context) async {
    clearAllError();
    state = state.copyWith(isLoading: true);

    final result = state.selectedSignUpMode == SignUpType.email
        ? await authService.checkUserWithEmail(
            email: email,
          )
        : await authService.checkUserWithPhone(
            phone: phone,
          );

    result.when(
      success: (data) {
        state = state.copyWith(isLoading: false);

        context.pushNamed(
          AppRoute.registration,
          extra: RouteParam(
            params: {
              RouteParamKey.signUpType: state.selectedSignUpMode,
              RouteParamKey.email: email,
              RouteParamKey.phone: phone,
            },
          ),
        );
      },
      failure: (error, _) {
        state = state.copyWith(
          isLoading: false,
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

  void changeMode(SignUpType? selectedMode) {
    clearAllError();
    state = state.copyWith(
      selectedSignUpMode: selectedMode,
    );
    emailNode.unfocus();
    numberNode.unfocus();
    emailController.clear();
    phoneController.clear();
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
          success: handleSuccessLoginSocial,
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
          success: handleSuccessLoginSocial,
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
        success: handleSuccessLoginSocial,
        failure: (error, stackTrace) => handleErrorLoginSocial(
          error,
          email: currentEmail,
        ),
      );

      state = state.copyWith(isLoading: false);
    }
  }

  void handleSuccessLoginSocial(LoginResponse response) async {
    final userLang = await accountService.getUserLanguage();

    state = state.copyWith(isLoading: false);
    if (context.mounted) {
      if (userLang != null) {
        context.setLocale(userLang.languageKey.locale);
      }
      context.goNamed(AppRoute.home);

      Snackbar.success(message: LocaleKeys.text_accountAlreadyRegistered.tr());
    }
  }

  void handleErrorLoginSocial(NetworkExceptions error, {String? email}) {
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
}

final signUpControllerProvider = StateNotifierProvider.family
    .autoDispose<SignUpController, SignUpState, BuildContext>((ref, context) {
  return SignUpController(
    context: context,
    authService: ref.read(authenticationServiceProvider),
    accountService: ref.read(accountServiceProvider),
  );
});
