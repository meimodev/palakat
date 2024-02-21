import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class AppointmentRescheduleSummaryScreen extends ConsumerStatefulWidget {
  const AppointmentRescheduleSummaryScreen({
    super.key,
    required this.appointment,
    required this.rescheduleDateTime,
  });

  final Appointment appointment;
  final DateTime rescheduleDateTime;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AppointmentRescheduleSummaryScreenState();
}

class _AppointmentRescheduleSummaryScreenState
    extends ConsumerState<AppointmentRescheduleSummaryScreen> {
  AppointmentRescheduleSummaryController get controller =>
      ref.read(appointmentRescheduleSummaryControllerProvider.notifier);

  @override
  void initState() {
    safeRebuild(
      () => controller.init(widget.appointment, widget.rescheduleDateTime),
    );
    super.initState();
  }

  List<Widget> _labelValue({required String label, String? text}) {
    return [
      LabelValueWidget(
        label: label,
        text: text ?? "",
      ),
      Gap.h24,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentRescheduleSummaryControllerProvider);
    final appointment = state.appointment;

    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_rescheduleSummary.tr(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: BaseSize.customWidth(20)),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Gap.h20,
                    ..._labelValue(
                      label: LocaleKeys.text_hospital.tr(),
                      text: appointment?.hospital?.name,
                    ),
                    ..._labelValue(
                      label: LocaleKeys.text_dateAndTime.tr(),
                      text: appointment?.date.eeeDMmmYyyyHhMm,
                    ),
                    ..._labelValue(
                      label: "${LocaleKeys.text_reschedule.tr()} "
                          "${LocaleKeys.text_dateAndTime.tr()}",
                      text: state.rescheduleDateTime?.eeeDMmmYyyyHhMm,
                    ),
                    ..._labelValue(
                      label: LocaleKeys.text_doctor.tr(),
                      text: appointment?.doctor?.name,
                    ),
                    ..._labelValue(
                      label: LocaleKeys.text_specialist.tr(),
                      text: appointment?.specialist?.name,
                    ),
                    PatientPickerWidget(
                      patient: appointment?.patient,
                    ),
                    GuaranteeTypePickerWidget(
                      selectedType: appointment?.guaranteeType,
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ButtonWidget.outlined(
                    text: LocaleKeys.text_cancel.tr(),
                    isShrink: true,
                    onTap: () {
                      context.navigateToAppointment(ref);
                    },
                  ),
                ),
                Gap.w16,
                Expanded(
                  child: ButtonWidget.primary(
                    text: LocaleKeys.text_confirm.tr(),
                    isShrink: true,
                    isLoading: state.isLoading,
                    onTap: () {
                      controller.handleConfirm(context, ref);
                    },
                  ),
                ),
              ],
            ),
            Gap.h16,
          ],
        ),
      ),
    );
  }
}
