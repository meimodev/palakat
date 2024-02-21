import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

const _htmlTermCondition = r"""
<p>I hereby declare that:</p>

    <ol>
        <li>I have received complete drug information from the doctor.</li>
        <li>I have no allergies from the prescribed medication.</li>
        <li>The medicine is in accordance with my therapeutic needs.</li>
        <li>The medicine I received had the correct patient identity, the correct dosage of the drug, the correct name of the drug, the correct time to take the drug, and the correct method of administration.</li>
    </ol>

    <p>If there is a discrepancy in the future, it will be my personal responsibility and not the responsibility of the Hospital.</p>
""";

final List<Map<String, dynamic>> _prescription = [
  {
    "item_name": "ESOFER 40MG INJ ESOFER 40MG INJ",
    "qty": "100",
    "dosage": "2 times per day",
    "instructions": "Before Meal",
    "time": "Morning, Evening",
    "notes": "Consumed on an empty stomach",
  },
  {
    "item_name": "ESOFER 40MG INJ ESOFER 40MG INJ",
    "qty": "50",
    "dosage": "2 times per day",
    "instructions": "Before Meal",
    "time": "Morning, Evening",
    "notes": "Consumed on an empty stomach",
  },
  {
    "item_name": "ESOFER 40MG INJ ESOFER 40MG INJ",
    "qty": "100",
    "dosage": "2 times per day",
    "instructions": "Before Meal",
    "time": "Morning, Evening",
    "notes": "Consumed on an empty stomach",
  },
  {
    "item_name": "ESOFER 40MG INJ ESOFER 40MG INJ",
    "qty": "70",
    "dosage": "2 times per day",
    "instructions": "Before Meal",
    "time": "Morning, Evening",
    "notes": "Consumed on an empty stomach",
  },
];

final medicalConsiderationProvider = StateProvider<bool>((ref) => false);

class SelfCheckInConsultationPrescriptionDetailScreen extends ConsumerWidget {
  const SelfCheckInConsultationPrescriptionDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref
        .watch(selfCheckinConsultationPrescriptionControllerProvider.notifier);
    final state =
        ref.watch(selfCheckinConsultationPrescriptionControllerProvider);
    bool takeAllMedicine = true;

    void handleContinueTap(bool selectedOption) {
      if (selectedOption == true) {
        takeAllMedicine = true;
        controller.selectAllMedicine(true);
      } else {
        takeAllMedicine = false;
        controller.selectAllMedicine(false);
      }
    }

    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        title: LocaleKeys.text_prescriptionDetail.tr(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    PatientBasicCardWidget(),
                    Gap.h16,
                    PrescriptionHeaderCardWidget(),
                    Gap.h16,
                    PrescriptionDetailCardWidget(prescription: _prescription),
                    Gap.h16,
                    PrescriptionTermAndConditionWidget(
                        htmlTermCondition: _htmlTermCondition),
                    Gap.h8,
                  ],
                ),
              ),
            ),
            Gap.h16,
            ButtonWidget.primary(
              text: LocaleKeys.text_continue.tr(),
              onTap: () {
                showCustomDialogWidget(
                  context,
                  title: LocaleKeys.text_prescription.tr(),
                  hideLeftButton: true,
                  btnRightText: LocaleKeys.text_submit.tr(),
                  onTap: () {
                    //Take All Medicine Dialog
                    if (takeAllMedicine == true) {
                      context.pop();
                      showCustomDialogWidget(
                        context,
                        title: "",
                        btnLeftText: LocaleKeys.text_cancel.tr(),
                        btnRightText: LocaleKeys.text_confirm.tr(),
                        onTap: () {
                          context.pushNamed(
                              AppRoute.selfCheckInConsultationPaymentSummary);
                        },
                        content: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              Assets.images.questionMark.image(
                                height: BaseSize.customHeight(100),
                                width: BaseSize.customWidth(100),
                              ),
                              Gap.h36,
                              Text(
                                LocaleKeys.text_takeAllMedicineQuestionMark
                                    .tr(),
                                style: TypographyTheme.textLSemiBold.toNeutral80,
                              ),
                              Gap.h16,
                              Text(
                                LocaleKeys.text_byClickingTheTakeAllMedicine
                                    .tr(),
                                style: TypographyTheme.textMRegular.toNeutral60,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      //Medicine Consideration Dialog
                      context.pop();
                      showCustomDialogWidget(
                        context,
                        title: "",
                        btnLeftText: LocaleKeys.text_cancel.tr(),
                        btnRightText: LocaleKeys.text_confirm.tr(),
                        onTap: () {
                          Navigator.pop(context, "TRUE");
                          context.goNamed(
                              AppRoute.selfCheckInConsultationVirtualQueue);
                        },
                        content: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              Assets.images.questionMark.image(
                                height: BaseSize.customHeight(100),
                                width: BaseSize.customWidth(100),
                              ),
                              Gap.h36,
                              Text(
                                LocaleKeys.text_medicationConsideration.tr(),
                                style: TypographyTheme.textLSemiBold.toNeutral80,
                              ),
                              Gap.h16,
                              Text(
                                LocaleKeys
                                    .text_ifThereArePrescriptionConsiderationPleaseVisitPharmacy
                                    .tr(),
                                style: TypographyTheme.textMRegular.toNeutral60,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  content: Builder(
                    builder: (BuildContext context) {
                      return MedicineOptionsWidget(
                        onSelectedMedicine: handleContinueTap,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
