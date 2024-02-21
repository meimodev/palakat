import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class BookDoctorSummaryController
    extends StateNotifier<BookDoctorSummaryState> {
  BookDoctorSummaryController(
    this.hospitalService,
    this.appointmentService,
  ) : super(const BookDoctorSummaryState());
  final HospitalService hospitalService;
  final AppointmentService appointmentService;

  void init(
    Doctor doctor,
    Hospital hospital,
    DateTime dateTime,
    String specialistSerial,
  ) async {
    state = state.copyWith(
      doctor: doctor,
      hospital: hospital,
      specialistSerial: specialistSerial,
      dateTime: dateTime,
    );
  }

  void setPatient(Patient? value) {
    state = state.copyWith(patient: value);
  }

  void setGuaranteeType(AppointmentGuaranteeType? value) {
    state = state.copyWith(guaranteeType: value);
  }

  void handleCreate(BuildContext context, WidgetRef ref) async {
    state = state.copyWith(isLoadingSubmit: true);

    final result = await appointmentService.create(
      state.doctor?.serial ?? "",
      state.dateTime ?? DateTime.now(),
      state.guaranteeType ?? AppointmentGuaranteeType.personal,
      state.hospital?.serial ?? "",
      state.patient?.serial ?? "",
      state.specialistSerial ?? "",
      AppointmentType.doctor,
    );

    result.when(
      success: (data) async {
        state = state.copyWith(isLoadingSubmit: false);

        await showGeneralDialogWidget(
          context,
          image: Assets.images.check.image(
            width: BaseSize.customWidth(100),
            height: BaseSize.customWidth(100),
          ),
          title: LocaleKeys.text_bookAppointmentComplete.tr(),
          content: Gap.h48,
          hideButtons: true,
        );

        if (context.mounted) {
          context.pushNamed(
            AppRoute.rating,
            extra: RouteParam(
              params: {
                RouteParamKey.type: RatingType.appointmentDoctor,
                RouteParamKey.appointmentSerial: data.serial,
              },
            ),
          );
        }
      },
      failure: (error, _) {
        state = state.copyWith(isLoadingSubmit: false);
        final message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);
      },
    );
  }
}

final bookDoctorSummaryControllerProvider = StateNotifierProvider.autoDispose<
    BookDoctorSummaryController, BookDoctorSummaryState>((ref) {
  return BookDoctorSummaryController(
    ref.read(hospitalServiceProvider),
    ref.read(appointmentServiceProvider),
  );
});
