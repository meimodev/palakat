import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/hospital/domain/doctor.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:pinput/pinput.dart';

class DoctorAutocomplete extends ConsumerStatefulWidget {
  const DoctorAutocomplete({
    super.key,
    this.specialistSerial,
    this.hospitalSerial,
    required this.controller,
  });
  final List<String>? specialistSerial;
  final List<String>? hospitalSerial;
  final TextEditingController controller;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DoctorAutocompleteState();
}

class _DoctorAutocompleteState extends ConsumerState<DoctorAutocomplete> {
  DoctorAutocompleteController get controller =>
      ref.read(doctorAutocompleteControllerProvider.notifier);

  @override
  void initState() {
    safeRebuild(
      () => controller.init(widget.hospitalSerial, widget.specialistSerial),
    );
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DoctorAutocomplete oldWidget) {
    safeRebuild(() {
      if (widget.hospitalSerial != oldWidget.hospitalSerial) {
        controller.setHospital(widget.hospitalSerial);
      } else if (widget.specialistSerial != oldWidget.specialistSerial) {
        controller.setSpecialist(widget.specialistSerial);
      }
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    DoctorAutocompleteState state =
        ref.watch(doctorAutocompleteControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputFormWidget(
          hintText: LocaleKeys.text_doctorsName.tr(),
          label: LocaleKeys.text_doctorsName.tr(),
          controller: widget.controller,
          onChanged: (text) => controller.onChanged(text),
          textInputAction: TextInputAction.done,
        ),
        ListBuilderWidget<Doctor>(
          shrinkWrap: true,
          isLoading: state.isLoading,
          data: state.doctors,
          itemBuilder: (context, index, doctor) {
            return DoctorListItemWidget(
              name: doctor.name,
              onTap: () {
                widget.controller.setText(doctor.name);
                controller.handleClick(doctor);
              },
              specialist: doctor.specialist?.name,
              image: doctor.content?.pictureURL ?? "",
            );
          },
        ),
      ],
    );
  }
}
