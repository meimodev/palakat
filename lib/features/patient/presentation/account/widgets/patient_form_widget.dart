import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class PatientFormWidget extends ConsumerWidget {
  const PatientFormWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      patientFormControllerProvider.notifier,
    );
    final state = ref.watch(patientFormControllerProvider);
    var isLastStep = state.formStep == controller.steps.length - 1;

    List<EasyStep> steps = controller.steps
        .where((element) => controller.steps.indexOf(element) != 3)
        .map((step) => EasyStep(
            customStep: ClipRRect(
                child: state.formStep > controller.steps.indexOf(step)
                    ? Assets.icons.line.done.svg(
                        colorFilter: Colors.white.filterSrcIn,
                        width: BaseSize.w48,
                        height: BaseSize.w48,
                      )
                    : Text((controller.steps.indexOf(step) + 1).toString(),
                        style: TypographyTheme.textXLSemiBold
                            .fontColor(BaseColor.white))),
            customTitle: Padding(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w36),
              child: Text(
                step,
                textAlign: TextAlign.center,
                style: TypographyTheme.textLSemiBold.fontColor(
                    state.formStep >= controller.steps.indexOf(step)
                        ? BaseColor.neutral.shade80
                        : BaseColor.neutral.shade40),
              ),
            )))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isLastStep) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w36),
            child: EasyStepper(
                internalPadding: BaseSize.w28,
                lineThickness: 2,
                lineLength: BaseSize.customWidth(150),
                lineType: LineType.normal,
                lineSpace: 5,
                disableScroll: true,
                showLoadingAnimation: false,
                activeStep: state.formStep,
                activeStepBackgroundColor: BaseColor.primary3,
                activeStepTextColor: Colors.black,
                unreachedStepBackgroundColor: BaseColor.neutral.shade30,
                unreachedLineColor: BaseColor.neutral.shade30,
                activeLineColor: BaseColor.neutral.shade30,
                steps: steps),
          ),
          Gap.h12,
        ],
        Expanded(
          child: ListView(
            controller: controller.scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            children: [
              Gap.h28,
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: Padding(
                  padding: horizontalPadding,
                  child: Form(
                    key: controller.patientFormKey,
                    child: _showForm(state.formStep),
                  ),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: horizontalPadding.add(EdgeInsets.only(top: BaseSize.h12)),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: ButtonWidget.outlined(
                    outlineColor: BaseColor.primary3,
                    overlayColor: BaseColor.white.withOpacity(.5),
                    isShrink: true,
                    text: state.formStep == 0
                        ? LocaleKeys.text_cancel.tr()
                        : LocaleKeys.text_back.tr(),
                    onTap: controller.onBackPatientFormStep,
                  )),
                  Gap.w12,
                  Expanded(
                    child: ButtonWidget.primary(
                      color: BaseColor.primary3,
                      overlayColor: BaseColor.white.withOpacity(.5),
                      isShrink: true,
                      isLoading: state.valid.isLoading,
                      isEnabled: controller.isValidGeneralConsentAgreement(),
                      text: state.formStep == controller.steps.length - 1
                          ? LocaleKeys.text_agree.tr()
                          : LocaleKeys.text_next.tr(),
                      onTap: controller.onPatientWithNoMRNSubmit,
                    ),
                  ),
                ],
              ),
              if (state.formStep >= controller.steps.length - 2) ...[
                Gap.h8,
                Text(
                  LocaleKeys
                      .text_theDataYouProvideIsGuaranteedToBeSecureAndUsedAccordingToYourNeeds
                      .tr(),
                  style: TypographyTheme.textMRegular.toNeutral60,
                  textAlign: TextAlign.center,
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}

Widget _showForm(int currentStep) {
  if (currentStep == 0) {
    return const PatientFormPersonalInformationStepWidget();
  } else if (currentStep == 1) {
    return const PatientFormAddressStepWidget();
  } else if (currentStep == 2) {
    return const PatientFormAdditionalInformationStepWidget();
  } else if (currentStep == 3) {
    return const PatientFormGeneralConsentStepWidget();
  }

  return const SizedBox();
}
