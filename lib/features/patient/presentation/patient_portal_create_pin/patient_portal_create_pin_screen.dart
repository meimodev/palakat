import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/assets/fonts.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/patient/presentation/patient_portal_activation/widgets/bottom_sheet_account_under_review_widget.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'widgets/widgets.dart';

class PatientPortalCreatePinScreen extends ConsumerStatefulWidget {
  const PatientPortalCreatePinScreen({
    super.key,
    required this.formData,
    this.otpProvider = OtpProvider.whatsapp,
  });

  final ActivatePatientPortalFormRequest formData;
  final OtpProvider otpProvider;

  @override
  ConsumerState createState() => _PatientPortalCreatePinScreenState();
}

class _PatientPortalCreatePinScreenState
    extends ConsumerState<PatientPortalCreatePinScreen> {
  PatientPortalCreatePinController get controller =>
      ref.read(patientPortalCreatePinProvider.notifier);

  PatientPortalCreatePinState get state =>
      ref.watch(patientPortalCreatePinProvider);

  @override
  void initState() {
    super.initState();
    safeRebuild(
      () => controller.requestOtp(
        widget.formData.phone ?? "",
        widget.otpProvider,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      resizeToAvoidBottomInset: true,
      type: ScaffoldType.authGradient,
      appBar: AppBarWidget(
        backgroundColor: Colors.transparent,
        height: BaseSize.customHeight(70),
      ),
      child: LoadingWrapper(
        value: state.loading,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap.customGapHeight(20),
                    Text(
                      LocaleKeys.text_createPin.tr(),
                      style: TypographyTheme.heading2Bold.copyWith(
                        color: BaseColor.primary4,
                      ),
                    ),
                    Gap.h16,
                    RichText(
                      text: TextSpan(
                        text:
                            "${LocaleKeys.text_enterTheVerificationCodeThatWasSentVia.tr(namedArgs: {
                              "label": widget.otpProvider.name
                            })} ",
                        style:
                            TypographyTheme.textLRegular.toNeutral60.copyWith(
                          fontFamily: FontFamily.lexend,
                        ),
                        children: [
                          TextSpan(
                            text: widget.formData.phone,
                            style: TypographyTheme.textLRegular.toNeutral80
                                .copyWith(
                              fontFamily: FontFamily.lexend,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap.customGapHeight(30),
                    state.duration == Duration.zero
                        ? const SizedBox()
                        : CountDownTimerWidget(
                            duration: state.duration,
                            onFinishTimer: () {},
                            builderOnTicking: (
                              String days,
                              String hours,
                              String minutes,
                              String seconds,
                            ) =>
                                RichText(
                              text: TextSpan(
                                text: "${LocaleKeys.text_timeRemaining.tr()} ",
                                style: TypographyTheme.textMRegular.toNeutral60
                                    .copyWith(
                                  fontFamily: FontFamily.lexend,
                                ),
                                children: [
                                  TextSpan(
                                    text: "$minutes:$seconds",
                                    style: TypographyTheme.textMBold.toPrimary
                                        .copyWith(
                                      fontFamily: FontFamily.lexend,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onResetTimer: () {
                              controller.requestOtp(
                                widget.formData.phone ?? "",
                                widget.otpProvider,
                              );
                            },
                          ),
                    Gap.customGapHeight(50),
                    Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
                          InputFormWidget(
                            controller: controller.tecVerificationCode,
                            label: LocaleKeys.text_verificationCode.tr(),
                            hintText: "${LocaleKeys.text_enter.tr()} "
                                "${LocaleKeys.text_verificationCode.tr()}",
                            hasIconState: false,
                            keyboardType: TextInputType.text,
                            hasBorderState: false,
                            onChanged: controller.onChangedOtp,
                            error:
                                state.errorOtp.isEmpty ? null : state.errorOtp,
                            validator: ValidationBuilder(
                                    label:
                                        LocaleKeys.text_verificationCode.tr())
                                .required()
                                .build(),
                          ),
                          Gap.customGapHeight(30),
                          ToggleableInputTextWidget(
                            controller: controller.tecNewPin,
                            mainLabel: LocaleKeys.text_sixDigitsPin.tr(),
                            obscure: true,
                            onChanged: (_) => controller.checkProceed(),
                            validator: ValidationBuilder(
                                    label: LocaleKeys.text_sixDigitsPin.tr())
                                .required()
                                .build(),
                          ),
                          Gap.customGapHeight(30),
                          ToggleableInputTextWidget(
                            controller: controller.tecNewPinConfirm,
                            mainLabel: LocaleKeys.text_confirmationPin.tr(),
                            obscure: true,
                            onChanged: (_) => controller.checkProceed(),
                            validator: ValidationBuilder(
                                    label: LocaleKeys.text_confirmationPin.tr())
                                .required()
                                .same(controller.tecNewPin.text)
                                .build(),
                          ),
                        ],
                      ),
                    ),
                    Gap.customGapHeight(20),
                  ],
                ),
              ),
            ),
            BottomActionWrapper(
              actionButton: ButtonWidget.primary(
                text: LocaleKeys.text_submit.tr(),
                onTap: state.canProceed
                    ? () {
                        controller.onPressedSubmit(
                          widget.formData,
                          () {
                            showAccountUnderReviewDialog(
                                context: context,
                                dismissible: false,
                                draggable: false,
                                onPressedClose: () {
                                  context.popUntilNamedWithResult(
                                    targetRouteName: AppRoute.home,
                                    result: true,
                                  );
                                },
                                onPressedBackToHome: () {
                                  Navigator.pop(context);
                                  context.popUntilNamedWithResult(
                                    targetRouteName: AppRoute.home,
                                    result: true,
                                  );
                                });
                          },
                        );
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
