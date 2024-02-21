import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/fonts.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';

class ForgotPinHeaderLayoutWidget extends StatelessWidget {
  const ForgotPinHeaderLayoutWidget({
    super.key,
    required this.title,
    required this.otpProvider,
    required this.contact,
    required this.onFinishSendCodeTimeOut,
    required this.codeCoolDown,
    required this.onTapResetCode,
  });

  final String title;
  final OtpProvider otpProvider;
  final String contact;
  final void Function() onFinishSendCodeTimeOut;
  final void Function() onTapResetCode;
  final Duration codeCoolDown;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap.customGapHeight(20),
        Text(
          title,
          style: TypographyTheme.heading2Bold.copyWith(
            color: BaseColor.primary4,
          ),
        ),
        Gap.h16,
        RichText(
          text: TextSpan(
            text: LocaleKeys.text_enterTheVerificationCodeThatWasSentVia.tr(
              namedArgs: {"label": otpProvider.name},
            ),
            style: TypographyTheme.textLRegular.toNeutral60.copyWith(
              fontFamily: FontFamily.lexend,
            ),
            children: [
              TextSpan(
                text: contact,
                style: TypographyTheme.textLRegular.toNeutral80
                    .copyWith(fontFamily: FontFamily.lexend),
              ),
            ],
          ),
        ),
        Gap.customGapHeight(30),
        CountDownTimerWidget(
          duration: codeCoolDown,
          onFinishTimer: onFinishSendCodeTimeOut,
          onResetTimer: onTapResetCode,
          builderOnTicking: (
            String days,
            String hours,
            String minutes,
            String seconds,
          ) =>
              RichText(
            text: TextSpan(
              text: "${LocaleKeys.text_timeRemaining.tr()} ",
              style: TypographyTheme.textMRegular.toNeutral60.copyWith(
                fontFamily: FontFamily.lexend,
              ),
              children: [
                TextSpan(
                  text: "$minutes:$seconds",
                  style: TypographyTheme.textMBold.toPrimary.copyWith(
                    fontFamily: FontFamily.lexend,
                  ),
                ),
              ],
            ),
          ),
        ),
        Gap.customGapHeight(50),
      ],
    );
  }
}
