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

class BookDoctorInsuranceFormController
    extends StateNotifier<BookDoctorInsuranceFormState> {
  BookDoctorInsuranceFormController(
    this.appointmentService,
  ) : super(const BookDoctorInsuranceFormState());
  final AppointmentService appointmentService;

  void init(
    Doctor doctor,
    Hospital hospital,
    Patient patient,
    AppointmentGuaranteeType guaranteeType,
    DateTime dateTime,
    String specialistSerial,
  ) async {
    state = state.copyWith(
      doctor: doctor,
      hospital: hospital,
      specialistSerial: specialistSerial,
      dateTime: dateTime,
      patient: patient,
      guaranteeType: guaranteeType,
    );
  }

  void clearError(String key) {
    if (state.errors.containsKey(key)) {
      final errors = state.errors;
      errors.removeWhere((k, _) => k == key);
      state = state.copyWith(
        errors: errors,
      );
    }
  }

  void clearAllError() {
    state = state.copyWith(errors: {});
  }

  void onCardChange(MediaUpload val) {
    state = state.copyWith(selectedCard: val);
  }

  void onCardRemove() {
    state = state.copyWith(selectedCard: const MediaUpload());
  }

  void onCardWithPhotoChange(MediaUpload val) {
    state = state.copyWith(selectedCardWithPhoto: val);
  }

  void onCardWithPhotoRemove() {
    state = state.copyWith(selectedCardWithPhoto: const MediaUpload());
  }

  onAgreeChange(bool val) {
    state = state.copyWith(
      isAgree: val,
    );
  }

  void handleCreate(BuildContext context, WidgetRef ref) async {
    clearAllError();

    state = state.copyWith(isLoadingSubmit: true);

    final result = await appointmentService.create(
      state.doctor?.serial ?? "",
      state.dateTime ?? DateTime.now(),
      state.guaranteeType ?? AppointmentGuaranteeType.personal,
      state.hospital?.serial ?? "",
      state.patient?.serial ?? "",
      state.specialistSerial ?? "",
      AppointmentType.doctor,
      insuranceCardSerial: state.selectedCard?.serial,
      insurancePhotoSerial: state.selectedCardWithPhoto?.serial,
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
          subtitle:
              LocaleKeys.text_youhaveToWaitForApprovalMaximum1x24Hours.tr(),
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
        final errors = NetworkExceptions.getErrors(error);

        if (errors.isNotEmpty) {
          state = state.copyWith(
            errors: errors,
          );
        } else {
          Snackbar.error(message: message);
        }
      },
    );
  }
}

final bookDoctorInsuranceFormControllerProvider =
    StateNotifierProvider.autoDispose<BookDoctorInsuranceFormController,
        BookDoctorInsuranceFormState>((ref) {
  return BookDoctorInsuranceFormController(
    ref.read(appointmentServiceProvider),
  );
});
