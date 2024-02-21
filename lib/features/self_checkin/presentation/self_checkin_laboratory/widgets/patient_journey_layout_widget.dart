import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';

import 'widgets.dart';

class PatientJourneyLayoutWidget extends StatelessWidget {
  const PatientJourneyLayoutWidget({
    super.key,
    required this.listJourney,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.queueNumber,
    required this.patientName,
    required this.doctorName,
    required this.currentListJourneyIndex,
    this.contentBuilder,
    required this.onPressedButtons,
    this.delivery = false,
    this.medicalRecordNo = "",
  });

  final List<PatientJourney> listJourney;

  final SvgGenImage image;
  final String title;
  final String subtitle;
  final String queueNumber;
  final String patientName;
  final String doctorName;
  final int currentListJourneyIndex;
  final bool delivery;
  final String medicalRecordNo;

  final Widget? Function(PatientJourney journey)? contentBuilder;
  final void Function(PatientJourney journey) onPressedButtons;


  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.text_patientJourney.tr(),
              style: TypographyTheme.textLSemiBold.toNeutral80,
            ),
            Text(
              "${LocaleKeys.text_step.tr()} "
              "$currentListJourneyIndex ${LocaleKeys.text_of.tr()} "
              "${listJourney.length}",
              style: TypographyTheme.textXSRegular.toNeutral50,
            ),
          ],
        ),
        Gap.h20,
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.customWidth(30),
            vertical: BaseSize.customHeight(30),
          ),
          child: Column(
            children: [
              for (int i = 0; i < listJourney.length; i++)
                ListItemPatientJourneyCardWidget(
                  journey: listJourney[i],
                  onPressedButton: onPressedButtons,
                  calculateDotsHeight: (PatientJourney journey) {
                    if (journey.title == LocaleKeys.text_delivery.tr()) {
                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.queue) {
                        return 80.0;
                      }
                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.inProgress) {
                        return 80.0;
                      }
                    }
                    if (journey.title == LocaleKeys.text_consultation.tr()) {
                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.queue) {
                        return 100.0;
                      }
                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.inExamination) {
                        return 80.0;
                      }
                    }
                    if (journey.title == LocaleKeys.text_prescription.tr()) {
                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.prescription) {
                        return 120.0;
                      }
                      if (journey.status ==
                              ListItemPatientJourneyCardStatus
                                  .medicationConsideration ||
                          journey.status ==
                              ListItemPatientJourneyCardStatus
                                  .waitingMedication ||
                          journey.status ==
                              ListItemPatientJourneyCardStatus
                                  .medicationUpdate) {
                        return 200.0;
                      }
                    }
                    if (journey.status ==
                            ListItemPatientJourneyCardStatus.notDone ||
                        journey.status ==
                            ListItemPatientJourneyCardStatus.notDoneEnd) {
                      return 60.0;
                    }
                    return null;
                  },
                  contentBuilder: (PatientJourney journey) {
                    if (journey.title == LocaleKeys.text_consultation.tr()) {
                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.inExamination) {
                        return ListItemPatientJourneyContentWidget(
                          title: LocaleKeys.text_inExamination.tr(),
                          subtitle: LocaleKeys.text_examinationInProgress.tr(),
                          subtitleColor: BaseColor.neutral.shade40,
                          removeSubTitleIcon: true,
                          backgroundColor: BaseColor.primary1,
                        );
                      }
                    }

                    if (journey.title == LocaleKeys.text_prescription.tr()) {
                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.notDone) {
                        return const SizedBox();
                      }
                      //Prescription
                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.prescription) {
                        return ListItemPatientJourneyContentWidget(
                          title: journey.title,
                          subtitle: journey.subTitle,
                          subtitleColor: BaseColor.neutral.shade40,
                          backgroundColor: BaseColor.primary1,
                          removeTitleIcon: true,
                          removeSubTitleIcon: true,
                          children: [
                            ButtonWidget.outlined(
                              text: LocaleKeys.text_viewPrescription.tr(),
                              onTap: () => onPressedButtons(journey),
                              buttonSize: ButtonSize.small,
                            ),
                          ],
                        );
                      }

                      //Medication Consideration
                      if (journey.status ==
                          ListItemPatientJourneyCardStatus
                              .medicationConsideration) {
                        return Column(
                          children: [
                            ListItemPatientJourneyContentWidget(
                              title:
                                  LocaleKeys.text_medicationConsideration.tr(),
                              subtitle: journey.subTitle,
                              subtitleColor: BaseColor.neutral.shade40,
                              backgroundColor: BaseColor.primary1,
                              titleIcon: Assets.icons.fill.handWithAPill,
                              removeSubTitleIcon: true,
                            ),
                            Gap.h16,
                            ListItemPatientJourneyContentWidget(
                              title: LocaleKeys.text_prescription.tr(),
                              subtitle: LocaleKeys
                                  .text_theDoctorHasPrescribedMedicineForYou
                                  .tr(),
                              subtitleColor: BaseColor.neutral.shade40,
                              backgroundColor: BaseColor.primary1,
                              removeTitleIcon: true,
                              removeSubTitleIcon: true,
                              children: [
                                ButtonWidget.outlined(
                                  text: LocaleKeys.text_viewPrescription.tr(),
                                  onTap: () => onPressedButtons(journey),
                                  buttonSize: ButtonSize.small,
                                ),
                              ],
                            )
                          ],
                        );
                      }

                      //Waiting Pharmacy Update
                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.waitingMedication) {
                        return Column(
                          children: [
                            ListItemPatientJourneyContentWidget(
                              titleIcon: Assets.icons.fill.mapPin,
                              title: "Pharmacy - Floor 1",
                              titleColor: BaseColor.black,
                              subTitleIcon: Assets.icons.fill.handWithAPill,
                              subtitle: journey.subTitle,
                              subtitleColor: BaseColor.primary3,
                              backgroundColor: BaseColor.primary1,
                            ),
                            Gap.h16,
                            ListItemPatientJourneyContentWidget(
                              title: LocaleKeys.text_prescription.tr(),
                              subtitle: journey.subTitle,
                              subtitleColor: BaseColor.neutral.shade40,
                              backgroundColor: BaseColor.primary1,
                              removeTitleIcon: true,
                              removeSubTitleIcon: true,
                              children: [
                                ButtonWidget.outlined(
                                  text: LocaleKeys.text_viewPrescription.tr(),
                                  onTap: () => onPressedButtons(journey),
                                  buttonSize: ButtonSize.small,
                                ),
                              ],
                            )
                          ],
                        );
                      }

                      //Medicatiion Updated
                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.medicationUpdate) {
                        return Column(
                          children: [
                            ListItemPatientJourneyContentWidget(
                              titleIcon: Assets.icons.fill.mapPin,
                              title: "Pharmacy - Floor 1",
                              titleColor: BaseColor.black,
                              subTitleIcon: Assets.icons.fill.handWithAPill,
                              subtitle: journey.subTitle,
                              subtitleColor: BaseColor.primary3,
                              backgroundColor: BaseColor.primary1,
                            ),
                            Gap.h16,
                            ListItemPatientJourneyContentWidget(
                              title: LocaleKeys.text_prescription.tr(),
                              subtitle: journey.subTitle,
                              subtitleColor: BaseColor.neutral.shade40,
                              backgroundColor: BaseColor.primary1,
                              removeTitleIcon: true,
                              removeSubTitleIcon: true,
                              children: [
                                ButtonWidget.outlined(
                                  text: LocaleKeys.text_viewPrescription.tr(),
                                  onTap: () => onPressedButtons(journey),
                                  buttonSize: ButtonSize.small,
                                ),
                              ],
                            )
                          ],
                        );
                      }

                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.done) {
                        return ListItemPatientJourneyContentWidget(
                          title: journey.title,
                          subtitle: journey.subTitle,
                          subtitleColor: BaseColor.neutral.shade40,
                          backgroundColor: BaseColor.primary1,
                          removeTitleIcon: true,
                          removeSubTitleIcon: true,
                          children: [
                            ButtonWidget.outlined(
                              text: LocaleKeys.text_viewPrescription.tr(),
                              onTap: () => onPressedButtons(journey),
                              buttonSize: ButtonSize.small,
                            ),
                          ],
                        );
                      }
                    }

                    if (journey.title == LocaleKeys.text_payment.tr()) {
                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.notDone) {
                        return const SizedBox();
                      }
                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.done) {
                        if (journey.time.isNotEmpty) {
                          return ListItemPatientJourneyContentWidget(
                            title:
                            LocaleKeys.text_done.tr(),
                            titleColor: BaseColor.neutral.shade40,
                            removeTitleIcon: true,
                            removeSubTitleIcon: true,
                          );
                        }
                        return ListItemPatientJourneyContentWidget(
                          title:
                              '${LocaleKeys.text_waitingFor.tr()} ${journey.title}',
                          subtitle: journey.subTitle,
                          subtitleColor: BaseColor.neutral.shade40,
                          backgroundColor: BaseColor.primary1,
                          removeTitleIcon: true,
                          removeSubTitleIcon: true,
                          children: [
                            ButtonWidget.outlined(
                              text: LocaleKeys.text_viewPaymentSummary.tr(),
                              onTap: () => onPressedButtons(journey),
                              buttonSize: ButtonSize.small,
                            ),
                          ],
                        );
                      }

                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.inProgress) {
                        return ListItemPatientJourneyContentWidget(
                          title:
                          LocaleKeys.text_paymentInProcess.tr(),
                          backgroundColor: BaseColor.primary1,
                          titleIcon: Assets.icons.fill.clock,
                        );
                      }
                    }

                    if (journey.title == LocaleKeys.text_pharmacy.tr()) {
                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.notDone) {
                        return const SizedBox();
                      }
                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.notDoneEnd) {
                        return const SizedBox();
                      }
                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.queue) {
                        if (delivery) {
                          return ListItemPatientJourneyContentWidget(
                            title: "${LocaleKeys.text_medication.tr()} "
                                "${LocaleKeys.text_readyForPickUpAt.tr()} "
                                "${journey.time}",
                            titleIcon: Assets.icons.fill.clock,
                          );
                        }
                        return ListItemPatientJourneyContentWidget(
                          title: LocaleKeys.text_waitingInQueue.tr(),
                          titleIcon: Assets.icons.fill.clock,
                          children: [
                            ButtonWidget.primary(
                              text: LocaleKeys.text_viewQueueingList.tr(),
                              onTap: () => onPressedButtons(journey),
                              buttonSize: ButtonSize.small,
                            ),
                          ],
                        );
                      }
                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.inProgress) {
                        if (delivery) {
                          return ListItemPatientJourneyContentWidget(
                            title: LocaleKeys.text_delivery.tr(),
                            titleIcon: Assets.icons.fill.handWithAPill,
                            titleIconColor: BaseColor.primary3,
                            titleColor: BaseColor.primary3,
                            subtitle: "Medication Method",
                            subtitleColor: BaseColor.neutral.shade40,
                            subTitleIconColor: Colors.transparent,
                            backgroundColor: BaseColor.primary1,
                          );
                        }

                        return ListItemPatientJourneyContentWidget(
                          title: '${LocaleKeys.text_medication.tr()} - '
                              '${LocaleKeys.text_readyForPickUpAt.tr()} '
                              '${journey.time}',
                        );
                      }
                    }

                    if (journey.title == LocaleKeys.text_delivery.tr()) {
                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.queue) {
                        return ListItemPatientJourneyContentWidget(
                          title: journey.subTitle,
                          titleColor: BaseColor.neutral.shade80,
                          titleIcon: Assets.icons.fill.mapPin,
                          subtitle: "Medication is being prepared",
                          subTitleIcon: Assets.icons.fill.clock,
                          subtitleColor: BaseColor.primary3,
                          children: [
                            ButtonWidget.primary(
                              text: "for testing only, remove later",
                              onTap: () => onPressedButtons(journey),
                              buttonSize: ButtonSize.small,
                            )
                          ],
                        );
                      }

                      if (journey.status ==
                          ListItemPatientJourneyCardStatus.inProgress) {
                        return ListItemPatientJourneyContentWidget(
                          title: journey.subTitle,
                          titleColor: BaseColor.neutral.shade80,
                          titleIcon: Assets.icons.fill.mapPin,
                          subtitle: "Delivery in process",
                          subTitleIcon: Assets.icons.fill.clock,
                          subtitleColor: BaseColor.primary3,
                        );
                      }
                    }
                    return null;
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
