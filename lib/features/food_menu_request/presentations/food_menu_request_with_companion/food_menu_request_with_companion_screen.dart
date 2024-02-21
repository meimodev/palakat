import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/food_menu_request/domain/enums/food_menu_segment_enum.dart';
import 'food_menu_request_with_companion_controller.dart';
import 'widgets/patient_and_companion_segment_widget.dart';

class FoodMenuRequestWithCompanionScreen extends ConsumerWidget {
  const FoodMenuRequestWithCompanionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.read(foodMenuRequestWithCompanionControllerProvider.notifier);

    final state = ref.watch(foodMenuRequestWithCompanionControllerProvider);

    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: const AppBarWidget(
        title: '13 July 2023',
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Gap.h12,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
                child: SegmentedControlWidget<FoodMenuSegment>(
                  value: state.selectedSegment,
                  options: {
                    FoodMenuSegment.patient: LocaleKeys.text_patient.tr(),
                    FoodMenuSegment.companion: LocaleKeys.text_companion.tr(),
                  },
                  onValueChanged: controller.setSegment,
                ),
              ),
              Gap.h24,
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.selectedSegment == FoodMenuSegment.patient)
                        PatientAndCompanionSegmentWidget(
                          morningMenus: controller.patientMenu['morning'],
                          afternoonMenus: controller.patientMenu['afternoon'],
                          eveningMenus: controller.patientMenu['evening'],
                          onChangedMorningRadioGroup:
                              controller.setSelectedMorningPatient,
                          onChangedAfternoonRadioGroup:
                              controller.setSelectedAfternoonPatient,
                          onChangedEveningRadioGroup:
                              controller.setSelectedEveningPatient,
                          selectedMorningValue: state.selectedMorningPatient,
                          selectedAfternoonValue:
                              state.selectedAfternoonPatient,
                          selectedEveningValue: state.selectedEveningPatient,
                        )
                      else
                        const SizedBox(),
                      if (state.selectedSegment == FoodMenuSegment.companion)
                        PatientAndCompanionSegmentWidget(
                          morningMenus: controller.companionMenu['morning'],
                          afternoonMenus: controller.companionMenu['afternoon'],
                          eveningMenus: controller.companionMenu['evening'],
                          onChangedMorningRadioGroup:
                              controller.setSelectedMorningCompanion,
                          onChangedAfternoonRadioGroup:
                              controller.setSelectedAfternoonCompanion,
                          onChangedEveningRadioGroup:
                              controller.setSelectedEveningCompanion,
                          selectedMorningValue: state.selectedMorningCompanion,
                          selectedAfternoonValue:
                              state.selectedAfternoonCompanion,
                          selectedEveningValue: state.selectedEveningCompanion,
                        )
                      else
                        const SizedBox(),
                    ],
                  ),
                ),
              ),
              BottomActionWrapper(
                actionButton: ButtonWidget.primary(
                  text: LocaleKeys.text_next.tr(),
                  onTap: controller.checkCanProceed()
                      ? () => context.pushNamed(
                          AppRoute.foodMenuRequestSummary)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
