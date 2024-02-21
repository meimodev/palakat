import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';
import 'package:halo_hermina/features/self_checkin/presentation/self_checkin_laboratory/widgets/widgets.dart';

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
    title: "Registration",
    subTitle: "Self Check-In",
    time: "11:00",
    status: ListItemPatientJourneyCardStatus.done,
  ),
  PatientJourney(
    title: "Pregnancy Exercise",
    subTitle: "12 People Ahead",
    time: "",
    status: ListItemPatientJourneyCardStatus.queue,
  ),
];

class SelfCheckInPregnancyExerciseVirtualQueueScreen extends ConsumerWidget {
  const SelfCheckInPregnancyExerciseVirtualQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(
      selfCheckInPregnancyExerciseVirtualQueueController(_journeyList).notifier,
    );
    final state = ref.watch(
      selfCheckInPregnancyExerciseVirtualQueueController(_journeyList),
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
          child: Column(
            children: [
              FeaturingAppointmentWidget(
                variety: LocaleKeys.text_pregnancyExercise.tr(),
                date: "16 Mar 2023  13:30",
                doctorName: "dr. Leon Gerald, SpPD",
                hospital: "RSH Kemayoran",
                journey: LocaleKeys.text_pregnancyExercise.tr(),
                name: "Pricilla Pamela",
                number: "016",
              ),
              Gap.h20,
              PatientJourneyLayoutWidget(
                listJourney: state.journeys,
                currentListJourneyIndex: 1,
                image: Assets.icons.tint.pregnant,
                title: LocaleKeys.text_pregnancyExercise.tr(),
                subtitle: LocaleKeys
                    .text_nowItsYourTimeToEnterPregnancyExerciseClass
                    .tr(),
                queueNumber: '016',
                patientName: 'Pricilia Pamella',
                doctorName: 'dr. Jan Gerard, SpPD',
                onPressedButtons: (PatientJourney journey) {  },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
