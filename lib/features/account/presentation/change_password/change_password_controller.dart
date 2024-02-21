import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/presentation.dart';

class ChangePasswordController extends StateNotifier<ChangePasswordState> {
  ChangePasswordController(this.context, this.accountService)
      : super(
          const ChangePasswordState(),
        );

  final BuildContext context;
  final AccountService accountService;

  // form
  final formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmationPasswordController = TextEditingController();

  final oldPasswordNode = FocusNode();
  final newPasswordNode = FocusNode();
  final confirmationPasswordNode = FocusNode();

  String get oldPassword => oldPasswordController.text;
  String get newPassword => newPasswordController.text;
  String get confirmationPassword => confirmationPasswordController.text;

  bool get isEmptyPassword => accountService.isEmptyPassword;

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

  void toggleObscureOldPassword() {
    state = state.copyWith(
      isOldPasswordObscure: !state.isOldPasswordObscure,
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

  void onSubmit() async {
    if (formKey.currentState!.validate()) {
      clearAllError();

      state = state.copyWith(valid: const AsyncLoading());

      final result = await accountService.changePassword(
        oldPassword: !isEmptyPassword ? oldPassword : null,
        newPassword: newPassword,
      );

      result.when(
        success: (data) {
          state = state.copyWith(
            valid: const AsyncData(true),
          );

          context.pop();
          Snackbar.success(
            message: LocaleKeys.text_changePasswordSuccessful.tr(),
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

final changePasswordControllerProvider = StateNotifierProvider.family<
    ChangePasswordController, ChangePasswordState, BuildContext>(
  (ref, context) {
    return ChangePasswordController(context, ref.read(accountServiceProvider));
  },
);
