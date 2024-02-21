import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class PatientFormGeneralConsentStepWidget extends ConsumerWidget {
  const PatientFormGeneralConsentStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(patientFormControllerProvider.notifier);
    final state = ref.watch(patientFormControllerProvider);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(
        LocaleKeys.text_generalConsentHaloHermina.tr(),
        style:
            TypographyTheme.bodySemiBold.fontColor(BaseColor.neutral.shade80),
      ),
      Gap.h16,
      const TermAndConditionContent(
        code: TermAndConditionCode.registrationPatient,
      ),
      Gap.h20,
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              fillColor: MaterialStateProperty.resolveWith(
                  WidgetTheme.getCheckboxPrimaryColor),
              value: state.isAgree,
              onChanged: (bool? value) {
                controller.onAgreeChange(value);
              },
            ),
          ),
          Gap.w12,
          Flexible(
              child: Text.rich(TextSpan(children: [
            TextSpan(
                text: LocaleKeys.text_byClickingSubmitButtonGeneralConsent.tr(),
                style: TypographyTheme.textMRegular
                    .fontColor(BaseColor.neutral.shade60)),
          ])))
        ],
      ),
    ]);
  }
}
