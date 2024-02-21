import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';

class VerificationEmailController extends StateNotifier<void> {
  VerificationEmailController({
    required this.authService,
    required this.accountService,
    required this.context,
  }) : super(null);
  final AuthenticationService authService;
  final AccountService accountService;
  final BuildContext context;

  void init(String email, String token) async {
    final result = await authService.verifyEmail(
      email: email,
      token: token,
    );

    result.when(
      success: (data) async {
        if (authService.isLoggedIn) {
          await accountService.getProfile();
        }

        if (context.mounted) context.goNamed(AppRoute.home);
        Snackbar.success(
          message: LocaleKeys.text_verifyEmailSuccess.tr(),
          duration: 4,
        );
      },
      failure: (error, _) {
        final message = NetworkExceptions.getErrorMessage(error);

        context.goNamed(AppRoute.home);
        Snackbar.error(message: message);
      },
    );
  }
}

final verificationEmailControllerProvider = StateNotifierProvider.family<
    VerificationEmailController, void, BuildContext>((ref, context) {
  return VerificationEmailController(
    authService: ref.read(authenticationServiceProvider),
    accountService: ref.read(accountServiceProvider),
    context: context,
  );
});
