import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class BookDoctorInsuranceFormScreen extends ConsumerStatefulWidget {
  const BookDoctorInsuranceFormScreen({
    super.key,
    required this.doctor,
    required this.hospital,
    required this.patient,
    required this.guaranteeType,
    required this.dateTime,
    required this.specialistSerial,
  });
  final Doctor doctor;
  final Hospital hospital;
  final Patient patient;
  final AppointmentGuaranteeType guaranteeType;
  final DateTime dateTime;
  final String specialistSerial;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BookDoctorInsuranceFormScreenState();
}

class _BookDoctorInsuranceFormScreenState
    extends ConsumerState<BookDoctorInsuranceFormScreen> {
  BookDoctorInsuranceFormController get controller =>
      ref.watch(bookDoctorInsuranceFormControllerProvider.notifier);

  @override
  void initState() {
    safeRebuild(
      () => controller.init(
        widget.doctor,
        widget.hospital,
        widget.patient,
        widget.guaranteeType,
        widget.dateTime,
        widget.specialistSerial,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookDoctorInsuranceFormControllerProvider);

    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_guaranteeType.tr(),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: horizontalPadding,
              children: [
                Gap.h16,
                ImageUpload(
                  title: LocaleKeys.text_insuranceCardPhoto.tr(),
                  onChangeImage: controller.onCardChange,
                  value: state.selectedCard,
                  configCode: MediaConfigCodeKey.private,
                  onRemoveImage: controller.onCardRemove,
                  required: true,
                  formError: state.errors['insuranceCardSerial'],
                ),
                Gap.h32,
                ImageUpload(
                  title: LocaleKeys.text_photoOfYouWithYourInsuranceCard.tr(),
                  onChangeImage: controller.onCardWithPhotoChange,
                  value: state.selectedCardWithPhoto,
                  configCode: MediaConfigCodeKey.private,
                  onRemoveImage: controller.onCardWithPhotoRemove,
                  required: true,
                  formError: state.errors['insurancePhotoSerial'],
                ),
                Gap.h32,
                GestureDetector(
                  onTap: () {
                    controller.onAgreeChange(!state.isAgree);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckBoxWidget.primary(
                        value: state.isAgree,
                        onChanged: (val) {
                          controller.onAgreeChange(val);
                        },
                        size: CheckboxSize.small,
                      ),
                      Gap.w12,
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: LocaleKeys
                                    .text_byClickingSubmitButtonIReadAndAgreeWithAll
                                    .tr(),
                                style: TypographyTheme.textMRegular.toNeutral70,
                              ),
                              const TextSpan(
                                text: ' ',
                              ),
                              TextSpan(
                                text: LocaleKeys.text_termAndConditions.tr(),
                                style: TypographyTheme.textMBold
                                    .fontColor(BaseColor.primary3),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => context.pushNamed(
                                        AppRoute.termAndCondition,
                                        extra: const RouteParam(
                                          params: {
                                            RouteParamKey.code:
                                                TermAndConditionCode.insurance,
                                          },
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Gap.h12,
          Padding(
            padding: horizontalPadding,
            child: ButtonWidget.primary(
              isEnabled: state.selectedCard != null &&
                  state.selectedCardWithPhoto != null &&
                  state.isAgree,
              isLoading: state.isLoadingSubmit,
              text: LocaleKeys.text_submit.tr(),
              onTap: () {
                controller.handleCreate(context, ref);
              },
            ),
          ),
          Gap.h16,
        ],
      ),
    );
  }
}
