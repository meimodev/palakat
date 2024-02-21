import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class BookDoctorSummaryScreen extends ConsumerStatefulWidget {
  const BookDoctorSummaryScreen({
    super.key,
    required this.doctor,
    required this.hospital,
    required this.dateTime,
    required this.specialistSerial,
  });
  final Doctor doctor;
  final Hospital hospital;
  final DateTime dateTime;
  final String specialistSerial;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BookDoctorSummaryScreenState();
}

class _BookDoctorSummaryScreenState
    extends ConsumerState<BookDoctorSummaryScreen> {
  BookDoctorSummaryController get controller =>
      ref.watch(bookDoctorSummaryControllerProvider.notifier);

  @override
  void initState() {
    safeRebuild(
      () => controller.init(
        widget.doctor,
        widget.hospital,
        widget.dateTime,
        widget.specialistSerial,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookDoctorSummaryControllerProvider);

    final hospital = state.hospital;
    final doctor = state.doctor;

    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_appointmentSummary.tr(),
      ),
      child: BookSummaryWidget(
        hospital: hospital?.name ?? "",
        doctor: doctor?.name ?? "",
        dateTime: state.dateTime?.eeeDMmmYyyyHhMm ?? "",
        specialist: doctor?.specialist?.name,
        onChangePatient: (patient) => controller.setPatient(patient),
        onChangeGuaranteeType: (type) => controller.setGuaranteeType(type),
        enableSubmit: state.patient != null && state.guaranteeType != null,
        isLoadingSubmit: state.isLoadingSubmit,
        onPressedConfirm: () {
          if (state.guaranteeType == AppointmentGuaranteeType.insurance) {
            context.pushNamed(
              AppRoute.bookDoctorInsuranceForm,
              extra: RouteParam(params: {
                RouteParamKey.dateTime: state.dateTime,
                RouteParamKey.doctor: state.doctor,
                RouteParamKey.hospital: state.hospital,
                RouteParamKey.patient: state.patient,
                RouteParamKey.guaranteeType: state.guaranteeType,
                RouteParamKey.specialistSerial: state.specialistSerial,
              }),
            );
          } else {
            controller.handleCreate(context, ref);
          }
        },
      ),
    );
  }
}
