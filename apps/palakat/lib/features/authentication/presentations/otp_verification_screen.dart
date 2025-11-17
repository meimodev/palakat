import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/authentication/data/utils/phone_number_formatter.dart';
import 'package:palakat/features/presentation.dart';
import 'package:pinput/pinput.dart';

/// OTP verification screen for Firebase Phone Authentication
///
/// This screen allows users to enter the 6-digit OTP code sent via SMS.
/// It includes a countdown timer and resend functionality.
class OtpVerificationScreen extends ConsumerWidget {
  const OtpVerificationScreen({super.key});

  /// Determines if retry button should be shown based on error message
  bool _shouldShowRetry(String errorMessage) {
    final lowerError = errorMessage.toLowerCase();
    return lowerError.contains('network') ||
        lowerError.contains('server') ||
        lowerError.contains('connect') ||
        lowerError.contains('timeout') ||
        lowerError.contains('timed out') ||
        lowerError.contains('unavailable') ||
        lowerError.contains('failed') ||
        lowerError.contains('error occurred');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Optimize state watching - only watch specific fields
    final controller = ref.read(authenticationControllerProvider.notifier);

    // Listen for state changes to handle navigation
    ref.listen<AuthenticationState>(authenticationControllerProvider, (
      previous,
      next,
    ) {
      // Navigate back to phone input when showOtpScreen becomes false
      if (!next.showOtpScreen && (previous?.showOtpScreen == true)) {
        context.pop();
      }

      // Announce errors for screen readers
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        SemanticsService.announce(
          'Error: ${next.errorMessage}',
          TextDirection.ltr,
        );
      }

      // Announce verification success
      if (next.showSuccessFeedback && (previous?.showSuccessFeedback != true)) {
        SemanticsService.announce('Verification successful', TextDirection.ltr);
      }
    });

    // Watch individual state fields to minimize rebuilds
    final fullPhoneNumber = ref.watch(
      authenticationControllerProvider.select((s) => s.fullPhoneNumber),
    );
    final otp = ref.watch(
      authenticationControllerProvider.select((s) => s.otp),
    );
    final isVerifyingOtp = ref.watch(
      authenticationControllerProvider.select((s) => s.isVerifyingOtp),
    );
    final isValidatingAccount = ref.watch(
      authenticationControllerProvider.select((s) => s.isValidatingAccount),
    );
    final errorMessage = ref.watch(
      authenticationControllerProvider.select((s) => s.errorMessage),
    );
    final remainingSeconds = ref.watch(
      authenticationControllerProvider.select((s) => s.remainingSeconds),
    );
    final canResendOtp = ref.watch(
      authenticationControllerProvider.select((s) => s.canResendOtp),
    );
    final isSendingOtp = ref.watch(
      authenticationControllerProvider.select((s) => s.isSendingOtp),
    );
    final showSuccessFeedback = ref.watch(
      authenticationControllerProvider.select((s) => s.showSuccessFeedback),
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
                // Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: Semantics(
                    label: 'Back button',
                    hint: 'Go back to phone number input',
                    button: true,
                    child: IconButton(
                      onPressed: () {
                        // Cancel timer and reset state
                        controller.goBackToPhoneInput();
                        // Navigation will be handled by the listener
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: BaseColor.black,
                        size: BaseSize.w24,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
                const Spacer(),

                // OTP Verification Card
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
                              child: Icon(
                                Icons.security_outlined,
                                size: BaseSize.w16,
                                color: BaseColor.teal[700],
                              ),
                            ),
                            Gap.w12,
                            Expanded(
                              child: Text(
                                "Verify OTP",
                                style: BaseTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: BaseColor.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gap.h16,

                        // Masked phone number display
                        Text(
                          'Enter the verification code sent to',
                          style: BaseTypography.bodyMedium.toSecondary,
                          textAlign: TextAlign.center,
                        ),
                        Gap.h6,
                        Text(
                          PhoneNumberFormatter.format(
                            fullPhoneNumber,
                            convertPlusToZero: true,
                          ),
                          style: BaseTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: BaseColor.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Gap.h16,

                        // Pinput OTP input
                        _OtpInput(
                          enabled: !isVerifyingOtp && !isValidatingAccount,
                          onChanged: controller.onOtpChanged,
                          onCompleted: (otp) {
                            // Auto-submit when 6 digits entered
                            controller.verifyOtp(
                              onAlreadyRegistered: (account) {
                                // Navigate to home screen for existing users
                                context.goNamed(AppRoute.home);
                              },
                              onNotRegistered: () {
                                // Navigate to registration for new users
                                // Pass verified phone to registration screen
                                final verifiedPhone = fullPhoneNumber.isNotEmpty
                                    ? fullPhoneNumber
                                    : ref.read(
                                        authenticationControllerProvider.select(
                                          (s) => s.phoneNumber,
                                        ),
                                      );
                                context.goNamed(
                                  AppRoute.account,
                                  extra: {'verifiedPhone': verifiedPhone},
                                );
                              },
                            );
                          },
                        ),
                        Gap.h16,

                        // Timer and resend button
                        _TimerAndResendButton(
                          remainingSeconds: remainingSeconds,
                          canResendOtp: canResendOtp,
                          isLoading: isSendingOtp,
                          onResend: controller.resendOtp,
                          formatTime: controller.formatTime,
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
                                  ? () {
                                      // Clear error and retry verification if OTP is complete
                                      controller.clearError();
                                      if (otp.length ==
                                          AppConstants.otpLength) {
                                        controller.verifyOtp(
                                          onAlreadyRegistered: (account) {
                                            context.goNamed(AppRoute.home);
                                          },
                                          onNotRegistered: () {
                                            final verifiedPhone =
                                                fullPhoneNumber.isNotEmpty
                                                ? fullPhoneNumber
                                                : ref.read(
                                                    authenticationControllerProvider
                                                        .select(
                                                          (s) => s.phoneNumber,
                                                        ),
                                                  );
                                            context.goNamed(
                                              AppRoute.account,
                                              extra: {
                                                'verifiedPhone': verifiedPhone,
                                              },
                                            );
                                          },
                                        );
                                      } else {
                                        // If OTP is not complete, suggest resending
                                        controller.resendOtp();
                                      }
                                    }
                                  : null,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                Gap.h16,

                // Success feedback or verify button with animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: showSuccessFeedback
                      ? _SuccessFeedback()
                      : (isVerifyingOtp || isValidatingAccount)
                      ? ButtonWidget.primary(
                          text: isValidatingAccount
                              ? "Validating..."
                              : "Verifying...",
                          isLoading: true,
                          onTap: () {},
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// OTP input widget using Pinput package
class _OtpInput extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;

  const _OtpInput({
    required this.onChanged,
    this.onCompleted,
    this.enabled = true,
  });

  @override
  State<_OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<_OtpInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus when screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        color: BaseColor.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: BaseColor.neutral30, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        color: BaseColor.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: BaseColor.teal[700]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: BaseColor.teal[200]!.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    return Semantics(
      label: 'OTP verification code input',
      hint: 'Enter the 6-digit verification code sent to your phone',
      textField: true,
      enabled: widget.enabled,
      child: Opacity(
        opacity: widget.enabled ? 1.0 : 0.5,
        child: Pinput(
          controller: _controller,
          focusNode: _focusNode,
          length: AppConstants.otpLength,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          onChanged: widget.enabled ? widget.onChanged : null,
          onCompleted: widget.enabled ? widget.onCompleted : null,
          keyboardType: TextInputType.number,
          autofocus: true,
          enabled: widget.enabled,
        ),
      ),
    );
  }
}

/// Timer and resend button widget
class _TimerAndResendButton extends StatelessWidget {
  final int remainingSeconds;
  final bool canResendOtp;
  final bool isLoading;
  final VoidCallback onResend;
  final String Function(int) formatTime;

  const _TimerAndResendButton({
    required this.remainingSeconds,
    required this.canResendOtp,
    required this.isLoading,
    required this.onResend,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!canResendOtp) ...[
          Semantics(
            label: 'Resend code available in ${formatTime(remainingSeconds)}',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: BaseSize.w16,
                  color: BaseColor.secondaryText,
                ),
                Gap.w6,
                Text(
                  formatTime(remainingSeconds),
                  style: BaseTypography.bodyMedium.toSecondary,
                ),
              ],
            ),
          ),
        ] else ...[
          if (isLoading)
            Semantics(
              label: 'Resending verification code',
              child: SizedBox(
                width: BaseSize.w16,
                height: BaseSize.w16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    BaseColor.teal[700]!,
                  ),
                ),
              ),
            )
          else
            Semantics(
              label: 'Resend code button',
              hint: 'Tap to resend verification code to your phone',
              button: true,
              child: TextButton(
                onPressed: onResend,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: BaseSize.w12,
                    vertical: BaseSize.h8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Resend Code',
                  style: BaseTypography.bodyMedium.copyWith(
                    color: BaseColor.teal[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// Success feedback widget with animation
class _SuccessFeedback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w16,
          vertical: BaseSize.h12,
        ),
        decoration: BoxDecoration(
          color: BaseColor.teal[50],
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          border: Border.all(color: BaseColor.teal[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: BaseSize.w24,
              height: BaseSize.w24,
              decoration: BoxDecoration(
                color: BaseColor.teal[700],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: BaseSize.w16,
                color: BaseColor.white,
              ),
            ),
            Gap.w12,
            Text(
              'Verification Successful',
              style: BaseTypography.bodyMedium.copyWith(
                color: BaseColor.teal[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
