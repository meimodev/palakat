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
import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';
import 'package:halo_hermina/features/self_checkin/presentation/self_checkin_laboratory/widgets/widgets.dart';

const List<Map<String, dynamic>> _queueList = [
  {
    "text": "#",
    "index": "14",
    "current": false,
  },
  {
    "text": "#",
    "index": "15",
    "current": false,
  },
  {
    "text": "#",
    "index": "16",
    "current": true,
  },
  {
    "text": "#",
    "index": "17",
    "current": false,
  },
];

List<PatientJourney> _journeyList = [
  PatientJourney(
    title: LocaleKeys.text_registration.tr(),
    subTitle: LocaleKeys.text_selfCheckIn.tr(),
    time: "11:00",
    status: ListItemPatientJourneyCardStatus.done,
  ),
  PatientJourney(
    title: LocaleKeys.text_nurseAssessment.tr(),
    subTitle: LocaleKeys.text_done.tr(),
    time: "12:00",
    status: ListItemPatientJourneyCardStatus.done,
  ),
  PatientJourney(
    title: LocaleKeys.text_consultation.tr(),
    subTitle: "4 People Ahead",
    time: "12:00",
    status: ListItemPatientJourneyCardStatus.queue,
  ),
  PatientJourney(
    title: LocaleKeys.text_prescription.tr(),
    subTitle: LocaleKeys.text_theDoctorHasPrescribedMedicineForYou.tr(),
    status: ListItemPatientJourneyCardStatus.done,
  ),
  PatientJourney(
    title: LocaleKeys.text_payment.tr(),
    subTitle:
        LocaleKeys.text_makeAPaymentImmediatelyByClickingTheButtonBelow.tr(),
    status: ListItemPatientJourneyCardStatus.done,
  ),
  PatientJourney(
    title: LocaleKeys.text_pharmacy.tr(),
    subTitle: "Done",
    time: "12:00",
    status: ListItemPatientJourneyCardStatus.inProgress,
  ),
  PatientJourney(
    title: LocaleKeys.text_delivery.tr(),
    subTitle: "Rumah",
    time: "18:00",
    status: ListItemPatientJourneyCardStatus.queue,
  ),
];

// final takeAllMedicineProvider = StateProvider<bool>((ref) => true);

class SelfCheckInConsultationVirtualQueueScreen extends ConsumerStatefulWidget {
  const SelfCheckInConsultationVirtualQueueScreen({super.key});

  @override
  ConsumerState<SelfCheckInConsultationVirtualQueueScreen> createState() =>
      _SelfCheckInConsultationVirtualQueueScreenState();
}

class _SelfCheckInConsultationVirtualQueueScreenState
    extends ConsumerState<SelfCheckInConsultationVirtualQueueScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(
      selfCheckInConsultationVirtualQueueController(_journeyList).notifier,
    );
    final state = ref.watch(
      selfCheckInConsultationVirtualQueueController(_journeyList),
    );

    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        backgroundColor: Colors.transparent,
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_virtualQueue.tr(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w20,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              FeaturingAppointmentWidget(
                variety: LocaleKeys.text_doctor.tr(),
                date: "16 Mar 2023  13:30",
                doctorName: "dr. Leon Gerald, SpPD",
                hospital: "RSH Kemayoran",
                journey: LocaleKeys.text_consultation.tr(),
                name: "Pricilla Pamela",
                number: "16",
              ),
              Gap.h20,
              PatientJourneyLayoutWidget(
                listJourney: state.journeys,
                currentListJourneyIndex: 2,
                image: Assets.icons.tint.stetoskop,
                title: "${LocaleKeys.text_consultationTime.tr()}!",
                subtitle:
                    LocaleKeys.text_nowItsYourTurnToEnterTheConsultingRoom.tr(),
                queueNumber: '16',
                patientName: 'Pricilia Pamella',
                doctorName: 'dr. Jan Gerard, SpPD',
                medicalRecordNo: '12789878890',
                onPressedButtons: (PatientJourney journey) async {
                  print(journey.toString());
                  if (journey.title == LocaleKeys.text_consultation.tr()) {
                    if (journey.status ==
                        ListItemPatientJourneyCardStatus.queue) {
                      await _mockProgressFromConsultationToPrescription(
                        journey: journey,
                        controller: controller,
                        state: state,
                      );
                      return;
                    }
                  }

                  if (journey.title == LocaleKeys.text_prescription.tr()) {
                    if (journey.status ==
                        ListItemPatientJourneyCardStatus.prescription) {
                      await _mockProgressFromPrescriptionToPayment(
                        journey: journey,
                        controller: controller,
                        state: state,
                      );
                      return;
                    }

                    if (journey.status ==
                        ListItemPatientJourneyCardStatus.medicationUpdate) {
                      context.pushNamed(
                          AppRoute.selfCheckInConsultationPrescriptionDetail);
                    }
                    if (journey.status ==
                        ListItemPatientJourneyCardStatus.waitingMedication) {
                      context.pushNamed(
                          AppRoute.selfCheckInConsultationPrescriptionDetail);
                    }

                    if (journey.status ==
                        ListItemPatientJourneyCardStatus.done) {
                      context.pushNamed(
                          AppRoute.selfCheckInConsultationPrescriptionDetail);
                    }
                  }

                  if (journey.title == LocaleKeys.text_laboratory.tr()) {
                    if (journey.status ==
                        ListItemPatientJourneyCardStatus.queue) {
                      await showQueueingListBottomSheetWidget(
                        context,
                        queueList: _queueList,
                        onPressedOk: () async {},
                      );

                      await Future.delayed(const Duration(seconds: 1));
                      PatientJourney altered = journey
                        ..status = ListItemPatientJourneyCardStatus.inProgress
                        ..subTitle = ""
                        ..time = "01:01";
                      controller.updateList(journey, altered);
                      await Future.delayed(const Duration(seconds: 1));
                      altered = journey
                        ..status = ListItemPatientJourneyCardStatus.done
                        ..time = "01:01";
                      controller.updateList(journey, altered);
                      await Future.delayed(const Duration(seconds: 1));

                      if (context.mounted) {
                        showJourneyCompletedDialogWidget(context);
                      }

                      return;
                    }
                  }

                  if (journey.title == LocaleKeys.text_pharmacy.tr()) {
                    if (journey.status ==
                        ListItemPatientJourneyCardStatus.queue) {
                      showQueueingListBottomSheetWidget(
                        context,
                        queueList: _queueList,
                        onPressedOk: () {},
                      );
                      return;
                    }
                    showYourTurnToEnterBottomSheet(
                      context,
                      image: Assets.icons.tint.medication,
                      title: LocaleKeys.text_pickUpYourMedication.tr(),
                      subTitle: LocaleKeys
                          .text_nowItsYourTurnToHavePickedUpYourMedication
                          .tr(),
                      queueNumber: "123",
                      patientName: "Pricilia Pamella",
                      methodName: LocaleKeys.text_queue.tr(),
                      onPressedOk: () async {
                        await Future.delayed(const Duration(seconds: 1));
                        PatientJourney altered = journey
                          ..status = ListItemPatientJourneyCardStatus.inProgress
                          ..time = "01:01";
                        controller.updateList(journey, altered);
                        await Future.delayed(const Duration(seconds: 3));
                        altered = journey
                          ..status = ListItemPatientJourneyCardStatus.done
                          ..subTitle = "Done"
                          ..time = "20:33";
                        controller.updateList(journey, altered);
                        await Future.delayed(const Duration(seconds: 1));
                        if (context.mounted) {
                          showJourneyCompletedDialogWidget(context);
                        }
                      },
                    );
                    return;
                  }

                  if (journey.title == LocaleKeys.text_delivery.tr()) {
                    showYourTurnToEnterBottomSheet(
                      context,
                      image: Assets.icons.tint.delivery,
                      title: LocaleKeys.text_medicationOnDelivery.tr(),
                      subTitle: LocaleKeys
                          .text_yourMedicineIsOnDeliveryProcessPleaseWait
                          .tr(),
                      queueNumber: "123",
                      patientName: "Pricilia Pamella",
                      methodName: LocaleKeys.text_delivery.tr(),
                      onPressedOk: () async {
                        await Future.delayed(const Duration(seconds: 1));
                        PatientJourney altered = journey
                          ..status =
                              ListItemPatientJourneyCardStatus.inProgress;
                        controller.updateList(journey, altered);
                        await Future.delayed(const Duration(seconds: 3));
                        altered = journey
                          ..status = ListItemPatientJourneyCardStatus.done
                          ..subTitle = "Done"
                          ..time = "20:33";
                        controller.updateList(journey, altered);
                        final pharmacyJourney = PatientJourney(
                          title: LocaleKeys.text_pharmacy.tr(),
                          subTitle: "Done",
                          time: "20:33",
                          status: ListItemPatientJourneyCardStatus.done,
                        );
                        controller.updateList(
                          altered..title = LocaleKeys.text_pharmacy.tr(),
                          pharmacyJourney,
                        );
                        await Future.delayed(const Duration(seconds: 1));
                        if (context.mounted) {
                          showJourneyCompletedDialogWidget(context);
                        }
                      },
                    );
                  }

                  if (journey.title == LocaleKeys.text_payment.tr()) {
                    if (journey.status ==
                        ListItemPatientJourneyCardStatus.done) {
                      context.pushNamed(
                          AppRoute.selfCheckInConsultationPaymentSummary);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _mockProgressFromConsultationToPrescription({
    required PatientJourney journey,
    required SelfCheckInConsultationVirtualQueueController controller,
    required SelfCheckInConsultationVirtualQueueState state,
  }) async {
    showCustomDialogWidget(
      context,
      title: LocaleKeys.text_queueList.tr(),
      hideLeftButton: true,
      btnRightText: LocaleKeys.text_ok.tr(),
      content: const BottomSheetQueueingListWidget(
        queueList: _queueList,
      ),
      onTap: () async {
        context.pop();
        await showYourTurnToEnterBottomSheet(context,
            image: Assets.icons.tint.stetoskop,
            title: LocaleKeys.text_consultationTime.tr(),
            subTitle:
                LocaleKeys.text_nowItsYourTurnToEnterTheConsultingRoom.tr(),
            queueNumber: "16",
            patientName: "Pricilia Pamella",
            doctorName: 'dr. Jan Gerard, SpPD',
            medicalRecordNo: '12789878890', onPressedOk: () async {
          await Future.delayed(const Duration(seconds: 1));
          PatientJourney altered = journey
            ..status = ListItemPatientJourneyCardStatus.inExamination
            ..time = "01:01";
          controller.updateList(journey, altered);
          await Future.delayed(const Duration(seconds: 3));
          altered = journey
            ..status = ListItemPatientJourneyCardStatus.done
            ..subTitle = "Done"
            ..time = "20:33";
          controller.updateList(journey, altered);

          //Prescription - Prescription
          final int index = state.journeys.indexOf(journey);
          if (index != -1 && index < state.journeys.length - 1) {
            final PatientJourney journey = state.journeys[index + 1];
            PatientJourney altered = journey
              ..status = ListItemPatientJourneyCardStatus.prescription
              ..subTitle =
                  LocaleKeys.text_theDoctorHasPrescribedMedicineForYou.tr()
              ..time = "01:01";
            controller.updateList(journey, altered);
          }
        });
      },
    );
  }

  Future<void> _mockProgressFromPrescriptionToPayment({
    required PatientJourney journey,
    required SelfCheckInConsultationVirtualQueueController controller,
    required SelfCheckInConsultationVirtualQueueState state,
  }) async {
    await showCustomDialogWidget(
      context,
      title: "",
      hideLeftButton: true,
      btnRightText: LocaleKeys.text_viewPrescription.tr(),
      onTap: () {
        context.pushNamed(AppRoute.selfCheckInConsultationPrescriptionDetail);
      },
      content: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Assets.images.prescription.image(
                height: BaseSize.customHeight(100),
                width: BaseSize.customWidth(100)),
            Gap.h20,
            Text(
              LocaleKeys.text_prescription.tr(),
              style: TypographyTheme.textLBold.toNeutral80,
            ),
            Gap.h20,
            Text(
              LocaleKeys.text_hereYourPrescriptionPleaseCheck.tr(),
              style: TypographyTheme.textMRegular.toNeutral60,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));
    if (!context.mounted) {
      return;
    }
    await showYourTurnToEnterBottomSheet(
      context,
      image: Assets.icons.tint.payment,
      title: "Do Payment",
      subTitle: "Now it’s your turn to have to make payment at the cashier",
      location: "Cashier ",
      patientName: "Jhon wick",
    );
    await Future.delayed(const Duration(seconds: 2));
    controller.updateList(
        journey,
        PatientJourney(
          title: LocaleKeys.text_prescription.tr(),
          subTitle: "Some Subtitle",
          status: ListItemPatientJourneyCardStatus.done,
        ));
    await Future.delayed(const Duration(seconds: 2));
    controller.updateList(
        journey..title = LocaleKeys.text_payment.tr(),
        PatientJourney(
          title: LocaleKeys.text_payment.tr(),
          subTitle: "Payment in process",
          status: ListItemPatientJourneyCardStatus.inProgress,
        ));
    await Future.delayed(const Duration(seconds: 3));
    controller.updateList(
        journey..title = LocaleKeys.text_payment.tr(),
        PatientJourney(
          title: LocaleKeys.text_payment.tr(),
          subTitle: "",
          time: "12:00",
          status: ListItemPatientJourneyCardStatus.done,
        ));
  }
}
