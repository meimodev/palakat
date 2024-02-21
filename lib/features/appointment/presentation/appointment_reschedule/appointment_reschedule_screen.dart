import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'widgets/widgets.dart';

class AppointmentRescheduleScreen extends ConsumerStatefulWidget {
  const AppointmentRescheduleScreen({
    super.key,
    required this.appointment,
  });
  final Appointment appointment;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AppointmentRescheduleScreenState();
}

class _AppointmentRescheduleScreenState
    extends ConsumerState<AppointmentRescheduleScreen> {
  AppointmentRescheduleController get controller =>
      ref.watch(appointmentRescheduleControllerProvider.notifier);

  @override
  void initState() {
    safeRebuild(() => controller.init(widget.appointment));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentRescheduleControllerProvider);
    final appointment = state.appointment;

    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_reschedule.tr(),
      ),
      child: ListView(
        padding: horizontalPadding.add(
          EdgeInsets.symmetric(vertical: BaseSize.h8),
        ),
        children: [
          if (appointment?.guaranteeType == AppointmentGuaranteeType.insurance)
            InlineAlertWidget(
              message: LocaleKeys
                  .text_ifYouBookOnDifferentDayTheInsuranceWillGoThrough
                  .tr(),
            ),
          Gap.h20,
          DoctorInfoLayoutWidget(
            imageUrl: appointment?.doctor?.content?.pictureURL ?? "",
            name: appointment?.doctor?.name ?? "",
            field: appointment?.specialist?.name ?? "",
            isLoadingPrice: state.isLoadingPrice,
            price: state.doctorPrice,
          ),
          Gap.h16,
          HospitalCardLayoutWidget(
            text: appointment?.hospital?.name ?? "",
          ),
          Gap.h16,
          DoctorScheduleCalendar(
            onSelectedAvailableDateTime: (selectedDateTime) {
              context.pop();
              context.pushNamed(
                AppRoute.appointmentRescheduleSummary,
                extra: RouteParam(params: {
                  RouteParamKey.appointment: state.appointment,
                  RouteParamKey.rescheduleDateTime: selectedDateTime,
                }),
              );
            },
            doctorSerial: appointment?.doctor?.serial ?? "",
            hospitalSerial: appointment?.hospital?.serial ?? "",
            specialistSerial: appointment?.specialist?.serial ?? "",
          ),
        ],
      ),
    );
  }
}
