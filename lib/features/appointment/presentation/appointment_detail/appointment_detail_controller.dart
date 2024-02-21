import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/presentation.dart';

class AppointmentDetailController
    extends StateNotifier<AppointmentDetailState> {
  final AppointmentService appointmentService;
  AppointmentDetailController(this.appointmentService)
      : super(const AppointmentDetailState());

  final TextEditingController cancelReasonController = TextEditingController();

  String get cancelReasonText => cancelReasonController.text;

  void init(String serial) {
    state = state.copyWith(serial: serial);

    getData();
  }

  Future<void> getData({bool withoutLoading = false}) async {
    if (!withoutLoading) state = state.copyWith(isLoading: true);

    var result =
        await appointmentService.getAppointmentDoctorBySerial(state.serial);

    await result.when(
      success: (data) async {
        state = state.copyWith(
          isLoading: false,
          appointment: data,
        );
      },
      failure: (error, stackTrace) {
        state = state.copyWith(
          isLoading: false,
        );

        var message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);
      },
    );
  }

  void handleCancel(BuildContext context, WidgetRef ref) async {
    final result = await appointmentService.cancel(
      state.serial,
      cancelReasonText,
    );

    result.when(
      success: (data) {
        cancelReasonController.clear();
        context.pop();
        getData();
        showSuccessfullyCancelAppointmentDialog(
          context: context,
          onProceedTap: () {
            context.navigateToAppointment(ref);
          },
        );
      },
      failure: (error, _) {
        state = state.copyWith();
        final message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);
      },
    );
  }
}

final appointmentDetailControllerProvider = StateNotifierProvider.autoDispose<
    AppointmentDetailController, AppointmentDetailState>(
  (ref) {
    return AppointmentDetailController(ref.read(appointmentServiceProvider));
  },
);
