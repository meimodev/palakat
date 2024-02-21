import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class DoctorFilterWidget extends ConsumerStatefulWidget {
  const DoctorFilterWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DoctorFilterWidgetState();
}

class _DoctorFilterWidgetState extends ConsumerState<DoctorFilterWidget> {
  DoctorListController get controller =>
      ref.read(doctorListControllerProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorListControllerProvider);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.70,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ListView(
          padding: horizontalPadding,
          children: [
            Gap.h20,
            InputFormWidget.dropdown(
              controller: controller.specialistController,
              hintText:
                  '${LocaleKeys.text_choose.tr()} ${LocaleKeys.text_specialist.tr()}',
              hasIconState: false,
              label: LocaleKeys.text_specialist.tr(),
              onBodyTap: () {
                showSpecialistSelect(
                  context,
                  title: LocaleKeys.text_specialist.tr(),
                  selectedValue: state.tempSpecialist,
                  onSave: controller.setSelectedSpecialist,
                  showSearch: true,
                );
              },
            ),
            Gap.h24,
            InputFormWidget.dropdown(
              controller: controller.locationController,
              hintText:
                  '${LocaleKeys.text_choose.tr()} ${LocaleKeys.text_location.tr()}',
              hasIconState: false,
              label: LocaleKeys.text_location.tr(),
              onBodyTap: () {
                showLocationSelect(
                  context,
                  title: LocaleKeys.text_location.tr(),
                  selectedValue: state.tempLocation,
                  onSaveValue: controller.setSelectedLocation,
                  showSearch: false,
                );
              },
            ),
            Gap.h24,
            InputMultipleSelectWidget<int>(
              hintText:
                  '${LocaleKeys.text_choose.tr()} ${LocaleKeys.text_day.tr()}',
              label: LocaleKeys.text_day.tr(),
              value: state.tempDays,
              getLabel: (val) => DateUtil.labelWeekDay(val),
              getValue: (val) => val,
              onRemove: controller.onRemoveDay,
              onBodyTap: () {
                showSelectMultipleWidget<int>(
                  context,
                  title: LocaleKeys.text_day.tr(),
                  selectedValue: state.tempDays,
                  getLabel: (val) => DateUtil.labelWeekDay(val),
                  getValue: (val) => val,
                  onSave: controller.setSelectedDay,
                  options: List.generate(7, (index) => index + 1),
                );
              },
            ),
            Gap.h24,
            InputMultipleSelectWidget<Hospital>(
              value: state.tempHospitals,
              hintText:
                  '${LocaleKeys.text_choose.tr()} ${LocaleKeys.text_hospital.tr()}',
              label: LocaleKeys.text_hospital.tr(),
              getLabel: (val) => val.name,
              getValue: (val) => val.serial,
              onRemove: controller.onRemoveHospital,
              onBodyTap: () {
                showHospitalsSelect(
                  context,
                  selectedValue: state.tempHospitals,
                  title: LocaleKeys.text_hospital.tr(),
                  onSave: (value) => controller.setSelectedHospital(value),
                  showSearch: false,
                  serials: state.tempLocation?.hospitals
                      .map((e) => e.serial)
                      .toList(),
                );
              },
            ),
            Gap.h24,
            InputFormWidget(
              hintText: LocaleKeys.text_doctorsName.tr(),
              label: LocaleKeys.text_doctorsName.tr(),
              controller: controller.doctorNameController,
              textInputAction: TextInputAction.done,
            ),
            Gap.h24,
            SegmentedGenderSelect(
              value: state.tempGender,
              onValueChanged: controller.setGender,
            ),
            Gap.h20,
          ],
        ),
      ),
    );
  }
}
