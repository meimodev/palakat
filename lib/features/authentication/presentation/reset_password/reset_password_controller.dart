import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/presentation.dart';

class ResetPasswordController extends StateNotifier<ResetPasswordState> {
  ResetPasswordController({
    required this.authService,
    required this.context,
  }) : super(const ResetPasswordState());

  final AuthenticationService authService;
  final BuildContext context;

  final formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final confirmationPasswordController = TextEditingController();

  final newPasswordNode = FocusNode();
  final confirmationPasswordNode = FocusNode();

  String get newPassword => newPasswordController.text;
  String get confirmationPassword => confirmationPasswordController.text;

  void init(String userSerial, String token) {
    state = state.copyWith(
      userSerial: userSerial,
      token: token,
    );
  }

  void toggleObscureNewPassword() {
    state = state.copyWith(
      isNewPasswordObscure: !state.isNewPasswordObscure,
    );
  }

  void toggleObscureConfirmationPassword() {
    state = state.copyWith(
      isConfirmationPasswordObscure: !state.isConfirmationPasswordObscure,
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

  void onSubmit(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      clearAllError();
      state = state.copyWith(valid: const AsyncLoading());

      final result = await authService.resetPassword(
        password: newPassword,
        token: state.token,
        userSerial: state.userSerial,
      );

      result.when(
        success: (data) {
          state = state.copyWith(
            valid: const AsyncData(true),
          );

          context.goNamed(AppRoute.login);

          Snackbar.success(
            message: LocaleKeys.text_resetPasswordSuccessful.tr(),
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
}

final resetPasswordControllerProvider = StateNotifierProvider.family<
    ResetPasswordController, ResetPasswordState, BuildContext>((ref, context) {
  return ResetPasswordController(
    authService: ref.read(authenticationServiceProvider),
    context: context,
  );
});
