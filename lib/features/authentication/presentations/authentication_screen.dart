import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
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
          padding: EdgeInsets.only(
            left: BaseSize.w12,
            right: BaseSize.w12,
            bottom: BaseSize.h12,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputWidget.text(
                currentInputValue: state.phone,
                onChanged: controller.onChangedTextPhone,
                leadIcon: Assets.icons.fill.phone,
                hint: 'Phone',
                label: 'Use Phone Number for Signing',
                textInputType: TextInputType.number,
              ),
              Gap.h24,
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
        borderRadius: BorderRadius.circular(8),
        color: BaseColor.cardBackground1,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: BaseColor.black),
      borderRadius: BorderRadius.circular(8),
    );

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(BaseSize.w12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OTP Sent to ${state.phone}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Gap.h12,
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
                        final success = await controller.verifyOtp(context);
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
                          style: TextStyle(
                            fontSize: 14,
                            color: state.canResendOtp
                                ? BaseColor.black
                                : Colors.grey[400],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Gap.w12,
                      Text(
                        controller.formatTime(state.remainingTime),
                        style: TextStyle(
                          fontSize: 14,
                          color: state.remainingTime > 0
                              ? BaseColor.black
                              : Colors.grey[400],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Gap.h24,
              // ButtonWidget.primary(
              //   text: "Continue",
              //   isLoading: state.loading,
              //   onTap: () async {
              //     final success = await controller.verifyOtp();
              //     if (success && context.mounted) {
              //       context.pushNamed(AppRoute.membership);
              //     }
              //   },
              // ),
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
