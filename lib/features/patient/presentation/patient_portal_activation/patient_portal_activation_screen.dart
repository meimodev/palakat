import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/patient/presentation/main_patient_portal_screen/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'widgets/widgets.dart';

class PatientPortalActivationScreen extends ConsumerWidget {
  const PatientPortalActivationScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(patientPortalActivationController.notifier);
    final state = ref.watch(patientPortalActivationController);

    return ScaffoldWidget(
      resizeToAvoidBottomInset: true,
      appBar: AppBarWidget(
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_patientPortalActivation.tr(),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap.customGapHeight(20),
                    InputFormWidget(
                      controller: controller.tecFirstName,
                      hintText: LocaleKeys.text_firstName.tr(),
                      hasIconState: false,
                      label: LocaleKeys.text_firstName.tr(),
                      keyboardType: TextInputType.text,
                      hasBorderState: false,
                      isActive: false,
                      onChanged: (_) => controller.checkProceed(),
                      validator: ValidationBuilder(
                              label: LocaleKeys.text_firstName.tr())
                          .required()
                          .build(),
                    ),
                    Gap.customGapHeight(30),
                    InputFormWidget(
                      controller: controller.tecLastName,
                      hintText: LocaleKeys.text_lastName.tr(),
                      hasIconState: false,
                      label: LocaleKeys.text_lastName.tr(),
                      keyboardType: TextInputType.text,
                      hasBorderState: false,
                      isActive: false,
                      onChanged: (_) => controller.checkProceed(),
                      validator: ValidationBuilder(
                              label: LocaleKeys.text_lastName.tr())
                          .required()
                          .build(),
                    ),
                    Gap.customGapHeight(30),
                    InputFormWidget(
                      controller: controller.tecDateOfBirth,
                      hintText: LocaleKeys.text_dateOfBirth.tr(),
                      hasIconState: false,
                      label: LocaleKeys.text_dateOfBirth.tr(),
                      keyboardType: TextInputType.text,
                      hasBorderState: false,
                      isActive: false,
                      validator: ValidationBuilder(
                              label: LocaleKeys.text_dateOfBirth.tr())
                          .required()
                          .build(),
                    ),
                    Gap.customGapHeight(30),
                    InputFormWidget(
                      controller: controller.tecPhoneNumber,
                      hintText: LocaleKeys.text_phoneNumber.tr(),
                      hasIconState: false,
                      label: LocaleKeys.text_phoneNumber.tr(),
                      keyboardType: TextInputType.number,
                      hasBorderState: false,
                      isActive: false,
                      validator: ValidationBuilder(
                              label: LocaleKeys.text_phoneNumber.tr())
                          .required()
                          .build(),
                    ),
                    Gap.customGapHeight(30),
                    InputFormWidget(
                      controller: controller.tecEmail,
                      hintText: LocaleKeys.text_email.tr(),
                      hasIconState: false,
                      label: LocaleKeys.text_email.tr(),
                      keyboardType: TextInputType.text,
                      hasBorderState: false,
                      isActive: false,
                      validator:
                          ValidationBuilder(label: LocaleKeys.text_email.tr())
                              .required()
                              .build(),
                    ),
                    Gap.customGapHeight(30),
                    // InputFormWidget.dropdown(
                    //   onBodyTap: () {},
                    //   initialValue: LocaleKeys.text_ktp.tr(),
                    //   // controller: controller.tecIdentityCard,
                    //   hintText: LocaleKeys.text_identityCard.tr(),
                    //   hasIconState: false,
                    //   label: LocaleKeys.text_identityCard.tr(),
                    //   keyboardType: TextInputType.text,
                    //   hasBorderState: false,
                    //   onChanged: (_) => controller.checkProceed(),
                    // ),
                    InputFormWidget.dropdown(
                      controller: controller.tecIdentityCard,
                      hintText: LocaleKeys.text_identityCard.tr(),
                      hasIconState: true,
                      label: LocaleKeys.text_identityCard.tr(),
                      onBodyTap: () {
                        showSelectSingleWidget<IdentityType>(
                          context,
                          title: LocaleKeys.text_identityCard.tr(),
                          options: FormConstants.identityTypes,
                          getValue: (type) => type.name,
                          getLabel: (type) => type.label,
                          onSave: (selected) {
                            controller.setIdentity(selected);
                          },
                        );
                      },
                      error: state.errors['identityType'],
                    ),
                    Gap.customGapHeight(30),
                    InputFormWidget(
                      controller: controller.tecIdentityCardNumber,
                      hintText: LocaleKeys.text_identityCardNumber.tr(),
                      label: LocaleKeys.text_identityCardNumber.tr(),
                      isInputNumber: true,
                      hasBorderState: false,
                      onChanged: (_) => controller.checkProceed(),
                      validator: ValidationBuilder(
                              label: LocaleKeys.text_identityCardNumber.tr())
                          .required()
                          .build(),
                    ),
                    Gap.customGapHeight(30),
                    SegmentedGenderSelect(
                      onValueChanged: (_){},
                      value: state.genderSerial,
                      enabled: false,
                    ),
                    Gap.customGapHeight(30),
                    ImageUpload(
                      title: LocaleKeys.text_identityCardPhoto.tr(),
                      onChangeImage: controller.onPhotoChange,
                      value: state.selectedPhoto,
                      configCode: MediaConfigCodeKey.private,
                      onRemoveImage: controller.onPhotoRemove,
                      formError: state.errors['photo'],
                    ),
                    Gap.h32,
                    ImageUpload(
                      title: LocaleKeys.text_photoOfYouWithYourIDCard.tr(),
                      onChangeImage: controller.onPhotoWithIdCardChange,
                      value: state.selectedPhotoWithIdentityCard,
                      configCode: MediaConfigCodeKey.private,
                      onRemoveImage: controller.onPhotoWithIdCardRemove,
                      formError: state.errors['photoWithId'],
                    ),
                    Gap.h32,
                    TermsAndConditionDialogWidget(
                      onChangedCheck: (bool value) {
                        controller.setTNCAccept(value);
                      },
                      onTapTermsAndCondition: () {
                        context.pushNamed(
                          AppRoute.termAndCondition,
                          extra: const RouteParam(
                            params: {
                              RouteParamKey.code:
                                  TermAndConditionCode.activationPatientPortal,
                            },
                          ),
                        );
                      },
                    ),
                    Gap.customGapHeight(20),
                  ],
                ),
              ),
            ),
          ),
          BottomActionWrapper(
            showDataAssuranceText: true,
            actionButton: ButtonWidget.primary(
              text: LocaleKeys.text_submit.tr(),
              onTap: state.canProceed
                  ? () {
                      controller.onPressedSubmit(onProceed: (data) {
                        showSendCodeOptionBottomSheet(
                          context,
                          isResend: false,
                          onPressedSubmitChooseOption: (method) async {
                            context.pushNamed(
                              AppRoute.patientPortalCreatePIN,
                              extra: RouteParam(
                                params: {
                                  RouteParamKey.activatePatientPortalForm: data,
                                  RouteParamKey.otpProvider: method,
                                },
                              ),
                            );
                          },
                        );
                      });
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
