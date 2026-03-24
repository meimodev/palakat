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
import 'package:palakat_shared/repositories.dart';
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
      await permissionState.requestPermissions();
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
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion =
        (mediaQuery?.disableAnimations ?? false) ||
        (mediaQuery?.accessibleNavigation ?? false);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.goBackToPhoneInput();
      },
      child: AuthScaffold(
        leading: AuthReveal(
          duration: const Duration(milliseconds: 280),
          offset: const Offset(-0.04, 0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Semantics(
              label: l10n.btn_back,
              hint: l10n.btn_goBack,
              button: true,
              child: IconButton(
                onPressed: controller.goBackToPhoneInput,
                tooltip: l10n.btn_back,
                icon: FaIcon(
                  AppIcons.back,
                  color: AppColors.onPrimary,
                  size: 20.0,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.square(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthReveal(
              delay: const Duration(milliseconds: 40),
              child: AuthSurfaceCard(
                icon: AppIcons.security,
                title: context.l10n.auth_verifyOtp,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthReveal(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.l10n.auth_enterCode,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.toSecondary,
                            textAlign: TextAlign.center,
                          ),
                          Gap.h6,
                          Text(
                            PhoneNumberFormatter.format(
                              fullPhoneNumber,
                              convertPlusToZero: true,
                            ),
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Gap.h16,
                    AuthReveal(
                      delay: const Duration(milliseconds: 70),
                      child: _OtpInput(
                        enabled: !isVerifyingOtp && !isValidatingAccount,
                        onChanged: controller.onOtpChanged,
                        onCompleted: (otp) {
                          controller.verifyOtp(
                            onAlreadyRegistered: (account) async {
                              await _checkPermissionReRequest(ref, context);

                              try {
                                final membership = account.membership;
                                if (membership != null &&
                                    membership.id != null) {
                                  final pusherBeamsController = ref.read(
                                    pusherBeamsControllerProvider.notifier,
                                  );
                                  await pusherBeamsController.registerInterests(
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
                                try {
                                  final membershipRepo = ref.read(
                                    membershipRepositoryProvider,
                                  );
                                  final pendingRes = await membershipRepo
                                      .membershipInvitationMyPending();
                                  final pending = pendingRes.when(
                                    onSuccess: (p) => p,
                                    onFailure: (_) {},
                                  );
                                  if (context.mounted) {
                                    if (pending?.id != null) {
                                      context.goNamed(AppRoute.home);
                                    } else {
                                      context.goNamed(AppRoute.membership);
                                    }
                                  }
                                } catch (_) {
                                  if (context.mounted) {
                                    context.goNamed(AppRoute.membership);
                                  }
                                }
                                return;
                              }

                              if (context.mounted) {
                                if (rt != null && rt.isNotEmpty) {
                                  context.go(rt);
                                } else {
                                  context.goNamed(AppRoute.home);
                                }
                              }
                            },
                            onNotRegistered: (firebaseIdToken) {
                              final verifiedPhone = fullPhoneNumber.isNotEmpty
                                  ? fullPhoneNumber
                                  : ref.read(
                                      authenticationControllerProvider.select(
                                        (s) => s.phoneNumber,
                                      ),
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
                    ),
                    Gap.h16,
                    AuthReveal(
                      delay: const Duration(milliseconds: 140),
                      child: _TimerAndResendButton(
                        remainingSeconds: remainingSeconds,
                        canResendOtp: canResendOtp,
                        isLoading: isSendingOtp,
                        onResend: controller.resendOtp,
                        formatTime: controller.formatTime,
                        resendCodeLabel: context.l10n.btn_resendCode,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AuthAnimatedPresence(
              visible: errorMessage != null,
              child: Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: AuthErrorDisplay(
                  message: errorMessage ?? '',
                  onRetry:
                      errorMessage != null &&
                          _shouldShowRetry(context, errorMessage)
                      ? () {
                          controller.clearError();
                          if (otp.length == AppConstants.otpLength) {
                            controller.verifyOtp(
                              onAlreadyRegistered: (account) async {
                                await _checkPermissionReRequest(ref, context);

                                try {
                                  final membership = account.membership;
                                  if (membership != null &&
                                      membership.id != null) {
                                    final pusherBeamsController = ref.read(
                                      pusherBeamsControllerProvider.notifier,
                                    );
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
                                  try {
                                    final membershipRepo = ref.read(
                                      membershipRepositoryProvider,
                                    );
                                    final pendingRes = await membershipRepo
                                        .membershipInvitationMyPending();
                                    final pending = pendingRes.when(
                                      onSuccess: (p) => p,
                                      onFailure: (_) {},
                                    );
                                    if (context.mounted) {
                                      if (pending?.id != null) {
                                        context.goNamed(AppRoute.home);
                                      } else {
                                        context.goNamed(AppRoute.membership);
                                      }
                                    }
                                  } catch (_) {
                                    if (context.mounted) {
                                      context.goNamed(AppRoute.membership);
                                    }
                                  }
                                  return;
                                }

                                if (context.mounted) {
                                  if (rt != null && rt.isNotEmpty) {
                                    context.go(rt);
                                  } else {
                                    context.goNamed(AppRoute.home);
                                  }
                                }
                              },
                              onNotRegistered: (firebaseIdToken) {
                                final verifiedPhone = fullPhoneNumber.isNotEmpty
                                    ? fullPhoneNumber
                                    : ref.read(
                                        authenticationControllerProvider.select(
                                          (s) => s.phoneNumber,
                                        ),
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
                          } else {
                            controller.resendOtp();
                          }
                        }
                      : null,
                ),
              ),
            ),

            Gap.h16,
            AuthAnimatedPresence(
              visible:
                  showSuccessFeedback || isVerifyingOtp || isValidatingAccount,
              child: AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 240),
                transitionBuilder: (child, animation) {
                  if (reduceMotion) {
                    return child;
                  }

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.03),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
                child: showSuccessFeedback
                    ? _SuccessFeedback(
                        key: const ValueKey('auth-success'),
                        successLabel: context.l10n.auth_verificationSuccessful,
                      )
                    : ButtonWidget.primary(
                        key: const ValueKey('auth-loading'),
                        text: l10n.loading_please_wait,
                        isLoading: true,
                        onTap: () {},
                      ),
              ),
            ),
          ],
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
      textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral, width: 1.5),
        borderRadius: BorderRadius.circular(16.0),
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: AppColors.secondary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
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
      child: AnimatedOpacity(
        opacity: widget.enabled ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 180),
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
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion =
        (mediaQuery?.disableAnimations ?? false) ||
        (mediaQuery?.accessibleNavigation ?? false);

    return AnimatedSwitcher(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 220),
      transitionBuilder: (child, animation) {
        if (reduceMotion) {
          return child;
        }

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.03),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        );
      },
      child: Row(
        key: ValueKey('resend-$canResendOtp-$isLoading'),
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
                    size: 16.0,
                    color: AppColors.onSurfaceVariant,
                  ),
                  Gap.w6,
                  Flexible(
                    child: Text(
                      formatTime(remainingSeconds),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.toSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            if (isLoading)
              Semantics(
                label: l10n.loading_please_wait,
                child: CompactLoadingWidget(
                  size: 16.0,
                  baseColor: AppColors.secondary.withValues(alpha: 0.24),
                  highlightColor: AppColors.surface,
                ),
              )
            else
              Semantics(
                label: resendCodeLabel,
                hint: resendCodeLabel,
                button: true,
                child: ButtonWidget.text(
                  text: resendCodeLabel,
                  onTap: onResend,
                  buttonSize: ButtonSize.small,
                  textColor: AppColors.secondary,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Success feedback widget with animation
class _SuccessFeedback extends StatelessWidget {
  final String successLabel;

  const _SuccessFeedback({super.key, required this.successLabel});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondary,
      elevation: 1,
      shadowColor: AppColors.onSurface,
      surfaceTintColor: AppColors.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: AppColors.secondary, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              alignment: Alignment.center,
              child: FaIcon(
                AppIcons.check,
                size: 16.0,
                color: AppColors.surfaceContainerLowest,
              ),
            ),
            Gap.w12,
            Flexible(
              child: Text(
                successLabel,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
