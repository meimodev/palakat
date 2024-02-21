import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class BookSummaryWidget extends StatelessWidget {
  const BookSummaryWidget({
    super.key,
    required this.hospital,
    required this.dateTime,
    this.isLoadingSubmit = false,
    this.enableSubmit = true,
    this.package,
    this.specialist,
    this.service,
    this.doctor,
    this.patient,
    this.guaranteeType,
    this.onChangePatient,
    this.onChangeGuaranteeType,
    required this.onPressedConfirm,
  });

  final bool isLoadingSubmit;
  final bool enableSubmit;
  final String hospital;
  final String dateTime;
  final String? doctor;
  final String? package;
  final String? specialist;
  final String? service;
  final Patient? patient;
  final AppointmentGuaranteeType? guaranteeType;
  final void Function(Patient? patient)? onChangePatient;
  final void Function(AppointmentGuaranteeType? type)? onChangeGuaranteeType;
  final void Function()? onPressedConfirm;

  List<Widget> _labelValue({required String label, String? text}) {
    return [
      LabelValueWidget(
        label: label,
        text: text ?? "",
      ),
      Gap.h20,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.customWidth(20)),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Gap.h20,
                  ..._labelValue(
                    label: LocaleKeys.text_hospital.tr(),
                    text: hospital,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_dateAndTime.tr(),
                    text: dateTime,
                  ),
                  if (doctor != null)
                    ..._labelValue(
                      label: LocaleKeys.text_doctor.tr(),
                      text: doctor,
                    ),
                  if (specialist != null)
                    ..._labelValue(
                      label: LocaleKeys.text_specialist.tr(),
                      text: specialist,
                    ),
                  if (package != null)
                    ..._labelValue(
                      label: LocaleKeys.text_package.tr(),
                      text: package,
                    ),
                  if (service != null)
                    ..._labelValue(
                      label: LocaleKeys.text_services.tr(),
                      text: service,
                    ),
                  PatientPickerWidget(
                    patient: patient,
                    onSelectedPatient: onChangePatient,
                  ),
                  GuaranteeTypePickerWidget(
                    selectedType: guaranteeType,
                    onSelectedGuaranteeType: onChangeGuaranteeType,
                  ),
                ],
              ),
            ),
          ),
          ButtonWidget.primary(
            isEnabled: enableSubmit,
            isLoading: isLoadingSubmit,
            text: LocaleKeys.text_confirm.tr(),
            onTap: onPressedConfirm,
          ),
          Gap.h16,
        ],
      ),
    );
  }
}
