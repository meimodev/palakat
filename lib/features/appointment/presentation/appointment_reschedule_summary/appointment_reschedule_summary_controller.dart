import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/network/network.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/extensions/build_context_extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class AppointmentRescheduleSummaryController
    extends StateNotifier<AppointmentRescheduleSummaryState> {
  AppointmentRescheduleSummaryController(this.appointmentService)
      : super(AppointmentRescheduleSummaryState());
  final AppointmentService appointmentService;

  void init(
    Appointment appointment,
    DateTime rescheduleDateTime,
  ) async {
    state = state.copyWith(
      appointment: appointment,
      rescheduleDateTime: rescheduleDateTime,
    );
  }

  void handleConfirm(BuildContext context, WidgetRef ref) async {
    state = state.copyWith(isLoading: true);

    final result = await appointmentService.reschedule(
      state.appointment?.serial ?? "",
      state.rescheduleDateTime ?? DateTime.now(),
    );

    result.when(
      success: (data) {
        state = state.copyWith(isLoading: false);

        Snackbar.success(message: LocaleKeys.text_rescheduleSuccessful.tr());

        context.navigateToAppointment(ref);
      },
      failure: (error, _) {
        state = state.copyWith(isLoading: false);
        final message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);
      },
    );
  }
}

final appointmentRescheduleSummaryControllerProvider =
    StateNotifierProvider.autoDispose<AppointmentRescheduleSummaryController,
        AppointmentRescheduleSummaryState>(
  (ref) {
    return AppointmentRescheduleSummaryController(
      ref.read(appointmentServiceProvider),
    );
  },
);
