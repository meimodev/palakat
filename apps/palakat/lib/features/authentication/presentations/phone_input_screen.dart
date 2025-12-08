import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  const PhoneInputScreen({super.key});

  /// Determines if retry button should be shown based on error message
  bool _shouldShowRetry(String errorMessage) {
    final lowerError = errorMessage.toLowerCase();
    return lowerError.contains('network') ||
        lowerError.contains('server') ||
        lowerError.contains('connect') ||
        lowerError.contains('timeout') ||
        lowerError.contains('timed out') ||
        lowerError.contains('unavailable') ||
        lowerError.contains('failed');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        SemanticsService.announce(
          'Verification code sent to your phone. Please enter the code.',
          TextDirection.ltr,
        );
        context.goNamed(AppRoute.otpVerification);
      }

      // Announce errors for screen readers
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        SemanticsService.announce(
          'Error: ${next.errorMessage}',
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: BaseColor.white,
        body: Padding(
          padding: EdgeInsets.all(BaseSize.w12),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Phone Input Card
                Material(
                  color: BaseColor.cardBackground1,
                  elevation: 1,
                  shadowColor: Colors.black.withValues(alpha: 0.05),
                  surfaceTintColor: BaseColor.teal[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(BaseSize.w16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header with icon and title
                        Row(
                          children: [
                            Container(
                              width: BaseSize.w32,
                              height: BaseSize.w32,
                              decoration: BoxDecoration(
                                color: BaseColor.teal[100],
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: FaIcon(
                                AppIcons.phone,
                                size: BaseSize.w16,
                                color: BaseColor.teal[700],
                              ),
                            ),
                            Gap.w12,
                            Expanded(
                              child: Text(
                                context.l10n.btn_signIn,
                                style: BaseTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: BaseColor.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gap.h16,

                        // Phone Number Input
                        Semantics(
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
                                hint: '0812-3456-7890',
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
                      ],
                    ),
                  ),
                ),

                // Error Display below card with animation
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: errorMessage != null
                      ? Column(
                          children: [
                            Gap.h12,
                            AuthErrorDisplay(
                              message: errorMessage,
                              onRetry: _shouldShowRetry(errorMessage)
                                  ? controller.sendOtp
                                  : null,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                Gap.h16,

                // Continue Button
                Semantics(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
