import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pinput.dart';
import 'widgets.dart';

class PatientPortalAlreadyActiveWidget extends ConsumerWidget {
  const PatientPortalAlreadyActiveWidget({
    super.key,
    required this.loginByBiometric,
    required this.onPressedForgotButton,
    required this.inputPinTextController,
    this.onChangedPin,
    this.onCompletedPin,
  });

  final void Function() loginByBiometric;
  final void Function() onPressedForgotButton;
  final void Function(String value)? onChangedPin;
  final void Function(String value)? onCompletedPin;

  final TextEditingController inputPinTextController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mainPatientPortalController);

    final defaultPinTheme = PinTheme(
      height: BaseSize.customWidth(45),
      width: BaseSize.customWidth(45),
      textStyle: TypographyTheme.heading3Regular.toNeutral80,
      decoration: BoxDecoration(
        border: Border.all(
          color: BaseColor.neutral.shade40,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
      ),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const TitleLayoutWidget(
            authorized: false,
            bottomPadding: true,
          ),
          Assets.images.pin1.image(
            width: BaseSize.customWidth(88),
            height: BaseSize.customHeight(88),
          ),
          Gap.customGapHeight(24),
          Text(
            LocaleKeys.text_pleaseEnterYourPINtoAccessPatientPortal.tr(),
            style: TypographyTheme.textLRegular.toNeutral60,
            textAlign: TextAlign.center,
          ),
          Gap.h40,
          Pinput(
            controller: inputPinTextController,
            length: 6,
            pinAnimationType: PinAnimationType.none,
            autofocus: true,
            onChanged: onChangedPin,
            onCompleted: onCompletedPin,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: defaultPinTheme.copyWith(
              decoration: BoxDecoration(
                border: Border.all(
                  color: BaseColor.primary3,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(BaseSize.radiusLg),
              ),
            ),
          ),
          Gap.customGapHeight(24),
          ButtonWidget.text(
            text: LocaleKeys.text_forgotPin.tr(),
            onTap: onPressedForgotButton,
          ),
          Gap.customGapHeight(24),
          if (state.canUseBiometric) ...[
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 20.0),
                    child: Divider(
                      color: BaseColor.neutral.shade40,
                      height: 36,
                    ),
                  ),
                ),
                Text(
                  LocaleKeys.text_or.tr(),
                  style: TypographyTheme.textSRegular.toNeutral60,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 10.0),
                    child: Divider(
                      color: BaseColor.neutral.shade40,
                      height: 36,
                    ),
                  ),
                ),
              ],
            ),
            Gap.h12,
            GestureDetector(
              onTap: loginByBiometric,
              child: Column(
                children: [
                  listEquals([BiometricType.face], state.biometricType)
                      ? Assets.icons.line.faceId.svg(
                          width: BaseSize.w72,
                          height: BaseSize.w72,
                          colorFilter: BaseColor.primary3.filterSrcIn,
                        )
                      : Assets.icons.line.fingerprint.svg(
                          width: BaseSize.w72,
                          height: BaseSize.w72,
                          colorFilter: BaseColor.primary3.filterSrcIn,
                        ),
                  Gap.h8,
                  Text(
                    LocaleKeys.prefix_loginWith.tr(namedArgs: {
                      "value":
                          listEquals([BiometricType.face], state.biometricType)
                              ? LocaleKeys.text_faceId.tr()
                              : (listEquals([BiometricType.fingerprint],
                                      state.biometricType)
                                  ? LocaleKeys.text_fingerprint.tr()
                                  : LocaleKeys.text_biometric.tr()),
                    }),
                    style: TypographyTheme.textXSSemiBold.toNeutral50,
                  )
                ],
              ),
            )
          ]
        ],
      ),
    );
  }
}
