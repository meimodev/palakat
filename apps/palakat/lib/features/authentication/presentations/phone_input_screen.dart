import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/authentication/presentations/widgets/phone_input_formatter.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';

/// Phone input screen for Firebase Phone Authentication
///
/// This screen allows users to enter their phone number.
/// It follows the Material 3 design system with teal color scheme.
///
/// Phone format: 0XXX-XXXX-XXXX (12-13 digits starting with 0)
class PhoneInputScreen extends ConsumerWidget {
  final String? returnTo;

  const PhoneInputScreen({super.key, this.returnTo});

  /// Determines if retry button should be shown based on error message
  bool _shouldShowRetry(BuildContext context, String errorMessage) {
    final l10n = context.l10n;
    final nonRetryableMessages = <String>{
      l10n.validation_phoneRequired,
      l10n.validation_invalidPhone,
      l10n.churchRequest_validation_phoneMustStartWithZero,
      l10n.churchRequest_validation_phoneMinDigits(12),
      l10n.churchRequest_validation_phoneMaxDigits(13),
    };

    return !nonRetryableMessages.contains(errorMessage);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // Optimize state watching - only watch specific fields that affect UI
    final controller = ref.read(authenticationControllerProvider.notifier);

    // Listen for state changes to navigate to OTP screen
    ref.listen<AuthenticationState>(authenticationControllerProvider, (
      previous,
      next,
    ) {
      // Navigate to OTP verification screen when showOtpScreen becomes true
      if (next.showOtpScreen && (previous?.showOtpScreen != true)) {
        // Announce for screen readers
        SemanticsService.announce(l10n.auth_otpSent, TextDirection.ltr);
        final rt = returnTo;
        if (rt != null && rt.isNotEmpty) {
          context.goNamed(
            AppRoute.otpVerification,
            queryParameters: {'returnTo': rt},
          );
        } else {
          context.goNamed(AppRoute.otpVerification);
        }
      }

      // Announce errors for screen readers
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        SemanticsService.announce(
          '${l10n.err_error}: ${next.errorMessage}',
          TextDirection.ltr,
        );
      }
    });

    // Watch individual state fields to minimize rebuilds
    final phoneNumber = ref.watch(
      authenticationControllerProvider.select((s) => s.phoneNumber),
    );
    final isSendingOtp = ref.watch(
      authenticationControllerProvider.select((s) => s.isSendingOtp),
    );
    final errorMessage = ref.watch(
      authenticationControllerProvider.select((s) => s.errorMessage),
    );

    final rt = returnTo;

    return PopScope(
      canPop: rt == null || rt.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (rt != null && rt.isNotEmpty) {
          context.go(rt);
        }
      },
      child: AuthScaffold(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthReveal(
              child: AuthSurfaceCard(
                icon: AppIcons.phone,
                title: context.l10n.btn_signIn,
                child: Semantics(
                  label: context.l10n.lbl_phone,
                  hint: context.l10n.auth_enterPhoneNumber,
                  textField: true,
                  enabled: !isSendingOtp,
                  child: AnimatedOpacity(
                    opacity: isSendingOtp ? 0.5 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: isSendingOtp,
                      child: InputWidget.text(
                        currentInputValue: phoneNumber,
                        onChanged: controller.onPhoneNumberChanged,
                        hint: l10n.churchRequest_hintPhoneExample,
                        label: context.l10n.lbl_phone,
                        textInputType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          PhoneInputFormatter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AuthAnimatedPresence(
              visible: errorMessage != null,
              child: Padding(
                padding: EdgeInsets.only(top: BaseSize.h12),
                child: AuthErrorDisplay(
                  message: errorMessage ?? '',
                  onRetry:
                      errorMessage != null &&
                          _shouldShowRetry(context, errorMessage)
                      ? controller.sendOtp
                      : null,
                ),
              ),
            ),
            Gap.h16,
            AuthReveal(
              delay: const Duration(milliseconds: 90),
              child: Semantics(
                label: context.l10n.btn_continue,
                hint: context.l10n.auth_otpSent,
                button: true,
                enabled: !isSendingOtp,
                child: ButtonWidget.primary(
                  text: context.l10n.btn_continue,
                  isLoading: isSendingOtp,
                  onTap: controller.sendOtp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
