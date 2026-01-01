import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/services/permission_manager_service_provider.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/authentication/data/utils/phone_number_formatter.dart';
import 'package:palakat/features/notification/data/pusher_beams_controller.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:pinput/pinput.dart';

/// OTP verification screen for Firebase Phone Authentication
///
/// This screen allows users to enter the 6-digit OTP code sent via SMS.
/// It includes a countdown timer and resend functionality.
class OtpVerificationScreen extends ConsumerWidget {
  final String? returnTo;

  const OtpVerificationScreen({super.key, this.returnTo});

  /// Determines if retry button should be shown based on error message
  bool _shouldShowRetry(BuildContext context, String errorMessage) {
    final l10n = context.l10n;
    final nonRetryableMessages = <String>{
      l10n.validation_requiredField,
      l10n.validation_invalidFormat,
    };

    return !nonRetryableMessages.contains(errorMessage);
  }

  /// Check for 7-day permission re-request on sign-in
  /// Requirements: 6.1
  Future<void> _checkPermissionReRequest(
    WidgetRef ref,
    BuildContext context,
  ) async {
    final permissionManager = ref.read(permissionManagerServiceProvider);

    // Sync permission status with system
    await permissionManager.syncPermissionStatus();

    // Check if we should show rationale (7-day check)
    final shouldShow = await permissionManager.shouldShowRationale();

    if (shouldShow && context.mounted) {
      // Show permission rationale and request if user allows
      final permissionState = ref.read(permissionStateProvider.notifier);
      await permissionState.requestPermissions(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // Optimize state watching - only watch specific fields
    final controller = ref.read(authenticationControllerProvider.notifier);
    final rt = returnTo;

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
          '${l10n.err_error}: ${next.errorMessage}',
          TextDirection.ltr,
        );
      }

      // Announce verification success
      if (next.showSuccessFeedback && (previous?.showSuccessFeedback != true)) {
        SemanticsService.announce(
          l10n.auth_verificationSuccessful,
          TextDirection.ltr,
        );
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.goBackToPhoneInput();
      },
      child: SafeArea(
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
                      label: l10n.btn_back,
                      hint: l10n.btn_goBack,
                      button: true,
                      child: IconButton(
                        onPressed: () {
                          // Cancel timer and reset state
                          controller.goBackToPhoneInput();
                          // Navigation will be handled by the listener
                        },
                        icon: FaIcon(
                          AppIcons.back,
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
                                child: FaIcon(
                                  AppIcons.security,
                                  size: BaseSize.w16,
                                  color: BaseColor.teal[700],
                                ),
                              ),
                              Gap.w12,
                              Expanded(
                                child: Text(
                                  context.l10n.auth_verifyOtp,
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
                            context.l10n.auth_enterCode,
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
                                onAlreadyRegistered: (account) async {
                                  // Check for 7-day permission re-request (Requirement 6.1)
                                  await _checkPermissionReRequest(ref, context);

                                  // Register push notifications after successful sign-in
                                  try {
                                    final membership = account.membership;
                                    if (membership != null &&
                                        membership.id != null) {
                                      final pusherBeamsController = ref.read(
                                        pusherBeamsControllerProvider.notifier,
                                      );
                                      // Pass account explicitly since membership.account
                                      // might be null (no back-reference from backend)
                                      await pusherBeamsController
                                          .registerInterests(
                                            membership,
                                            account: account,
                                          );
                                    }
                                  } catch (e) {
                                    debugPrint(
                                      '🔔 Push notification registration failed: $e',
                                    );
                                  }

                                  final membershipId = account.membership?.id;
                                  if (membershipId == null) {
                                    if (context.mounted) {
                                      context.goNamed(AppRoute.membership);
                                    }
                                    return;
                                  }

                                  // Navigate to home screen for existing users
                                  if (context.mounted) {
                                    if (rt != null && rt.isNotEmpty) {
                                      context.go(rt);
                                    } else {
                                      context.goNamed(AppRoute.home);
                                    }
                                  }
                                },
                                onNotRegistered: (firebaseIdToken) {
                                  // Navigate to registration for new users
                                  // Pass verified phone to registration screen
                                  final verifiedPhone =
                                      fullPhoneNumber.isNotEmpty
                                      ? fullPhoneNumber
                                      : ref.read(
                                          authenticationControllerProvider
                                              .select((s) => s.phoneNumber),
                                        );
                                  context.pushNamed(
                                    AppRoute.account,
                                    extra: {
                                      'verifiedPhone': verifiedPhone,
                                      'firebaseIdToken': firebaseIdToken,
                                    },
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
                            resendCodeLabel: context.l10n.btn_resendCode,
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
                                onRetry: _shouldShowRetry(context, errorMessage)
                                    ? () {
                                        // Clear error and retry verification if OTP is complete
                                        controller.clearError();
                                        if (otp.length ==
                                            AppConstants.otpLength) {
                                          controller.verifyOtp(
                                            onAlreadyRegistered: (account) async {
                                              // Check for 7-day permission re-request (Requirement 6.1)
                                              await _checkPermissionReRequest(
                                                ref,
                                                context,
                                              );

                                              // Register push notifications after successful sign-in
                                              try {
                                                // Use membership from account directly
                                                final membership =
                                                    account.membership;
                                                if (membership != null &&
                                                    membership.id != null) {
                                                  final pusherBeamsController =
                                                      ref.read(
                                                        pusherBeamsControllerProvider
                                                            .notifier,
                                                      );
                                                  // Pass account explicitly
                                                  await pusherBeamsController
                                                      .registerInterests(
                                                        membership,
                                                        account: account,
                                                      );
                                                }
                                              } catch (e) {
                                                debugPrint(
                                                  '🔔 Push notification registration failed: $e',
                                                );
                                              }

                                              final membershipId =
                                                  account.membership?.id;
                                              if (membershipId == null) {
                                                if (context.mounted) {
                                                  context.goNamed(
                                                    AppRoute.membership,
                                                  );
                                                }
                                                return;
                                              }

                                              if (context.mounted) {
                                                if (rt != null &&
                                                    rt.isNotEmpty) {
                                                  context.go(rt);
                                                } else {
                                                  context.goNamed(
                                                    AppRoute.home,
                                                  );
                                                }
                                              }
                                            },
                                            onNotRegistered: (firebaseIdToken) {
                                              final verifiedPhone =
                                                  fullPhoneNumber.isNotEmpty
                                                  ? fullPhoneNumber
                                                  : ref.read(
                                                      authenticationControllerProvider
                                                          .select(
                                                            (s) =>
                                                                s.phoneNumber,
                                                          ),
                                                    );
                                              context.pushNamed(
                                                AppRoute.account,
                                                extra: {
                                                  'verifiedPhone':
                                                      verifiedPhone,
                                                  'firebaseIdToken':
                                                      firebaseIdToken,
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
                        ? _SuccessFeedback(
                            successLabel:
                                context.l10n.auth_verificationSuccessful,
                          )
                        : (isVerifyingOtp || isValidatingAccount)
                        ? ButtonWidget.primary(
                            text: l10n.loading_please_wait,
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
    // Auto-focus when screen appears with a slight delay to ensure layout is complete
    // This prevents RenderBox layout errors during focus traversal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && widget.enabled) {
          _focusNode.requestFocus();
        }
      });
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
      label: context.l10n.auth_verifyOtp,
      hint: context.l10n.auth_enterCode,
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
          autofocus: false, // Disabled to prevent RenderBox layout errors
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
  final String resendCodeLabel;

  const _TimerAndResendButton({
    required this.remainingSeconds,
    required this.canResendOtp,
    required this.isLoading,
    required this.onResend,
    required this.formatTime,
    required this.resendCodeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!canResendOtp) ...[
          Semantics(
            label: l10n.auth_resendIn(remainingSeconds),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  AppIcons.timer,
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
              label: l10n.loading_please_wait,
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
              label: resendCodeLabel,
              hint: resendCodeLabel,
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
                  resendCodeLabel,
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
  final String successLabel;

  const _SuccessFeedback({required this.successLabel});

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
              alignment: Alignment.center,
              child: FaIcon(
                AppIcons.check,
                size: BaseSize.w16,
                color: BaseColor.white,
              ),
            ),
            Gap.w12,
            Text(
              successLabel,
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
