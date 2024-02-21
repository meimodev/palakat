import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

const String _name = "Pricilia Pamella";
const String _otp = "123456";

class PatientPortalEmailVerifyPinScreen extends ConsumerWidget {
  const PatientPortalEmailVerifyPinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScaffoldWidget(
      type: ScaffoldType.authGradient,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gap.customGapHeight(24),
            Center(
              child: Assets.images.logoWithText.image(
                width: BaseSize.customWidth(204),
                height: BaseSize.customWidth(71),
              ),
            ),
            Gap.h40,
            Row(
              children: [
                Text(
                  "${LocaleKeys.text_hello.tr().replaceFirst("!", "")}, ",
                  style: TypographyTheme.heading2Regular,
                ),
                Text(
                  _name,
                  style: TypographyTheme.textLBold,
                ),
              ],
            ),
            Gap.h20,
            Text(
              LocaleKeys.text_pleaseEnterTheOtpCodeBellowToContinue.tr(),
              style: TypographyTheme.textLRegular.copyWith(height: 1.5),
            ),
            Gap.h48,
            Row(
              children: [
                for (final o in _otp.split(""))
                  Text(
                    "$o   ",
                    style: TypographyTheme.heading4Regular
                        .copyWith(fontSize: 30.sp),
                  ),
              ],
            ),
            Gap.h48,
            Text(
              LocaleKeys.text_doNotGiveTheOtpCodeToAnyParty.tr(),
              style: TypographyTheme.textLRegular.copyWith(height: 1.5),
            ),
            Gap.h24,
            GestureDetector(
              onTap: () {
                context.pushNamed(AppRoute.patientPortalCreatePIN);
              },
              child: Text(
                LocaleKeys.text_clickHereToActivation.tr(),
                style: TypographyTheme.textLRegular.toPrimary.copyWith(
                  height: 1.5,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "© ${DateTime.now().year} Halo Hermina",
                  style: TypographyTheme.textSRegular.toNeutral40,
                ),
              ),
            ),
            Gap.customGapHeight(25),
          ],
        ),
      ),
    );
  }
}
