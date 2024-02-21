import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';

import '../widgets/widgets.dart';

const List<Map<String, dynamic>> _queueList = [
  {
    "text": "#",
    "index": "20",
    "current": false,
  },
  {
    "text": "#",
    "index": "21",
    "current": false,
  },
  {
    "text": "#",
    "index": "22",
    "current": true,
  },
  {
    "text": "#",
    "index": "23",
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
    title: LocaleKeys.text_laboratory.tr(),
    subTitle: "4 ${LocaleKeys.text_peopleAhead.tr()}",
    time: "12:00",
    status: ListItemPatientJourneyCardStatus.queue,
  ),
  PatientJourney(
    title: LocaleKeys.text_nurseAssessment.tr(),
    subTitle: LocaleKeys.text_done.tr(),
    time: "12:00",
    status: ListItemPatientJourneyCardStatus.done,
  ),
  PatientJourney(
    title: LocaleKeys.text_consultation.tr(),
    subTitle: LocaleKeys.text_done.tr(),
    time: "12:10",
    status: ListItemPatientJourneyCardStatus.done,
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

class SelfCheckInLaboratoryVirtualQueueScreen extends ConsumerWidget {
  const SelfCheckInLaboratoryVirtualQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      selfCheckInLaboratoryVirtualQueueController(_journeyList).notifier,
    );
    final state = ref.watch(
      selfCheckInLaboratoryVirtualQueueController(_journeyList),
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
                variety: LocaleKeys.text_laboratory.tr(),
                date: "16 Mar 2023  13:30",
                doctorName: "dr. Leon Gerald, SpPD",
                hospital: "RSH Kemayoran",
                journey: LocaleKeys.text_laboratory.tr(),
                name: "Pricilla Pamela",
                number: "23",
              ),
              Gap.h20,
              PatientJourneyLayoutWidget(
                listJourney: state.journeys,
                currentListJourneyIndex: 6,
                image: Assets.icons.tint.microscope1,
                title: "${LocaleKeys.text_laboratoryCheck.tr()}!",
                subtitle:
                    LocaleKeys.text_nowItsYourTurnToEnterTheLaboratory.tr(),
                queueNumber: '23',
                patientName: 'Pricilia Pamella',
                doctorName: 'dr. Jan Gerard, SpPD',
                delivery: true,
                onPressedButtons: (PatientJourney journey) async {
                  print("patient journey button");
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

                  if (journey.title == LocaleKeys.text_prescription.tr()) {
                    if (journey.status == ListItemPatientJourneyCardStatus.done) {
                      context.pushNamed(AppRoute.selfCheckInConsultationPrescriptionDetail);
                    }
                  }

                  if (journey.title == LocaleKeys.text_payment.tr()) {
                    if (journey.status == ListItemPatientJourneyCardStatus.done) {
                      context.pushNamed(AppRoute.selfCheckInConsultationPaymentSummary);
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
}
