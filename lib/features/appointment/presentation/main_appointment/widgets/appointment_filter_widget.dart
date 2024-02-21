import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/model/serial_name.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class AppointmentFilterWidget extends ConsumerStatefulWidget {
  const AppointmentFilterWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AppointmentFilterWidgetState();
}

class _AppointmentFilterWidgetState
    extends ConsumerState<AppointmentFilterWidget> {
  MainAppointmentController get controller =>
      ref.read(mainAppointmentControllerProvider.notifier);

  String addChoose(String text) => "${LocaleKeys.text_choose.tr()} $text";

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mainAppointmentControllerProvider);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: ListView(
        padding: horizontalPadding,
        children: [
          Gap.h24,
          InputMultipleSelectWidget<SerialName>(
            value: state.tempServices,
            hintText: addChoose(LocaleKeys.text_services.tr()),
            label: LocaleKeys.text_services.tr(),
            getLabel: (val) => val.name,
            getValue: (val) => val.serial,
            onRemove: controller.onRemoveService,
            onBodyTap: () {
              showAppointmentTypeSelect(
                context,
                title: LocaleKeys.text_services.tr(),
                selectedValue: state.tempServices,
                onSave: controller.setSelectedServices,
                showSearch: false,
              );
            },
          ),
          Gap.h24,
          InputMultipleSelectWidget<Doctor>(
            value: state.tempDoctors,
            hintText: addChoose(LocaleKeys.text_doctor.tr()),
            label: LocaleKeys.text_doctor.tr(),
            getLabel: (val) => val.name,
            getValue: (val) => val.serial,
            onRemove: controller.onRemoveDoctor,
            onBodyTap: () {
              showDoctorSelect(
                context,
                title: LocaleKeys.text_doctor.tr(),
                selectedValue: state.tempDoctors,
                onSave: controller.setSelectedDoctors,
                showSearch: false,
              );
            },
          ),
          Gap.h24,
          InputMultipleSelectWidget<SerialName>(
            value: state.tempSpecialists,
            hintText: addChoose(LocaleKeys.text_specialist.tr()),
            label: LocaleKeys.text_specialist.tr(),
            getLabel: (val) => val.name,
            getValue: (val) => val.serial,
            onRemove: controller.onRemoveSpecialist,
            onBodyTap: () {
              showSpecialistsSelect(
                context,
                title: LocaleKeys.text_specialist.tr(),
                selectedValue: state.tempSpecialists,
                onSave: controller.setSelectedSpecialists,
                showSearch: false,
              );
            },
          ),
          Gap.h24,
          InputMultipleSelectWidget<Hospital>(
            value: state.tempHospitals,
            hintText: addChoose(LocaleKeys.text_hospital.tr()),
            label: LocaleKeys.text_hospital.tr(),
            getLabel: (val) => val.name,
            getValue: (val) => val.serial,
            onRemove: controller.onRemoveHospital,
            onBodyTap: () {
              showHospitalsSelect(
                context,
                title: LocaleKeys.text_hospital.tr(),
                selectedValue: state.tempHospitals,
                onSave: controller.setSelectedHospital,
                showSearch: false,
              );
            },
          ),
          Gap.h24,
          InputMultipleSelectWidget<SerialName>(
            value: state.tempPatients,
            hintText: addChoose(LocaleKeys.text_patient.tr()),
            label: LocaleKeys.text_patient.tr(),
            getLabel: (val) => val.name,
            getValue: (val) => val.serial,
            onRemove: controller.onRemovePatient,
            onBodyTap: () {
              showPatientSelect(
                context,
                title: LocaleKeys.text_patient.tr(),
                selectedValue: state.tempPatients,
                onSave: controller.setSelectedPatient,
                showSearch: false,
              );
            },
          ),
        ],
      ),
    );
  }
}
