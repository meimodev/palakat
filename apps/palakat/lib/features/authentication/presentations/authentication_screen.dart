import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat_admin/core/extension/build_context_extension.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';
import 'package:pinput/pinput.dart';

class AuthenticationScreen extends ConsumerWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authenticationControllerProvider);
    final controller = ref.read(authenticationControllerProvider.notifier);

    ref.listen<AuthenticationState>(authenticationControllerProvider, (
      previous,
      next,
    ) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        _showSnackBar(context, next.errorMessage!);
        Future.microtask(() => controller.clearError());
      }
    });

    if (state.showOtpVerification) {
      return _buildOtpVerification(context, ref);
    }
    return _buildPhoneInput(context, ref);
  }

  Widget _buildPhoneInput(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authenticationControllerProvider);
    final controller = ref.read(authenticationControllerProvider.notifier);

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(BaseSize.w12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                              Icons.phone_outlined,
                              size: BaseSize.w16,
                              color: BaseColor.teal[700],
                            ),
                          ),
                          Gap.w12,
                          Expanded(
                            child: Text(
                              "Sign In",
                              style: BaseTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: BaseColor.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap.h16,
                      InputWidget.text(
                        currentInputValue: state.phone,
                        onChanged: controller.onChangedTextPhone,
                        leadIcon: Assets.icons.fill.phone,
                        hint: 'Phone',
                        label: 'Use Phone Number for Signing',
                        textInputType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              Gap.h16,
              ButtonWidget.primary(
                text: "Continue",
                isLoading: state.loading,
                onTap: () async {
                  final success = await controller.sendOtp();
                  if (success) {
                    // OTP verification screen will be shown automatically
                    // through state.showOtpVerification = true
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpVerification(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authenticationControllerProvider);
    final controller = ref.read(authenticationControllerProvider.notifier);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        color: BaseColor.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: BaseColor.secondaryText),
        borderRadius: BorderRadius.circular(12),
        color: BaseColor.cardBackground1,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: BaseColor.teal[700]!),
      borderRadius: BorderRadius.circular(12),
    );

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(BaseSize.w12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      Gap.h8,
                      Text(
                        'OTP Sent to ${state.phone}',
                        style: BaseTypography.bodyMedium.copyWith(
                          color: BaseColor.secondaryText,
                        ),
                      ),
                      Gap.h16,
                      Center(
                        child: Pinput(
                          length: 6,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                          showCursor: true,
                          onChanged: (pin) {
                            controller.onChangedOtp(pin);
                          },

                          onCompleted: (pin) async {
                            controller.onChangedOtp(pin);
                            controller.verifyOtp(
                              onAlreadyRegistered: (account) {
                                context.popUntilNamedWithResult(
                                  targetRouteName: AppRoute.home,
                                  result: account,
                                );
                              },
                              onNotRegistered: () {
                                context.goNamed(AppRoute.account);
                              },
                            );
                          },
                        ),
                      ),
                      Gap.h12,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: state.canResendOtp ? controller.resendOtp : null,
                            child: Text(
                              'Resend Code',
                              style: BaseTypography.bodyMedium.copyWith(
                                color: state.canResendOtp
                                    ? BaseColor.black
                                    : BaseColor.secondaryText,
                              ),
                            ),
                          ),
                          Gap.w12,
                          Text(
                            controller.formatTime(state.remainingTime),
                            style: BaseTypography.bodyMedium.copyWith(
                              color: state.remainingTime > 0
                                  ? BaseColor.black
                                  : BaseColor.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Gap.h12,
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
