import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class ForgotPasswordController extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordController({
    required this.authService,
    required this.context,
  }) : super(const ForgotPasswordState());

  final AuthenticationService authService;
  final BuildContext context;

  final emailController = TextEditingController();

  String get email => emailController.text;

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
    clearAllError();
    state = state.copyWith(valid: const AsyncLoading());

    final result = await authService.forgotPassword(
      email: email,
      type: ForgotPasswordType.user.value,
    );

    result.when(
      success: (data) async {
        state = state.copyWith(
          valid: const AsyncData(true),
        );

        await showGeneralDialogWidget(
          context,
          image: Assets.images.mailList.image(
            width: BaseSize.customWidth(100),
            height: BaseSize.customHeight(100),
          ),
          title: LocaleKeys.text_checkYourEmailAddress.tr(),
          subtitle:
              LocaleKeys.text_resetPasswordLinkHasBeenSentToYourEmail.tr(),
          primaryButtonTitle: LocaleKeys.text_backToHome.tr(),
          content: Gap.h20,
          action: () => context.goNamed(AppRoute.home),
        );

        if (context.mounted) context.goNamed(AppRoute.home);
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

final forgotPasswordControllerProvider = StateNotifierProvider.family<
    ForgotPasswordController,
    ForgotPasswordState,
    BuildContext>((ref, context) {
  return ForgotPasswordController(
    authService: ref.read(authenticationServiceProvider),
    context: context,
  );
});
