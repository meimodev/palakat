import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class AppointmentRescheduleController
    extends StateNotifier<AppointmentRescheduleState> {
  AppointmentRescheduleController(this.hospitalService)
      : super(AppointmentRescheduleState());
  final HospitalService hospitalService;

  void init(
    Appointment appointment,
  ) async {
    state = state.copyWith(
      appointment: appointment,
    );

    getDoctorPrice(
      appointment.doctor?.serial ?? "",
      appointment.hospital?.serial ?? "",
    );
  }

  Future<void> getDoctorPrice(
    String doctorSerial,
    String hospitalSerial,
  ) async {
    final result = await hospitalService.getDoctorPrice(
      DoctorPriceRequest(
        doctorSerial: doctorSerial,
        hospitalSerial: hospitalSerial,
      ),
    );
    result.when(
      success: (data) {
        state = state.copyWith(
          doctorPrice: data.price,
          isLoadingPrice: false,
        );
      },
      failure: (error, _) {
        state = state.copyWith(
          isLoadingPrice: false,
        );
        final message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);
      },
    );
  }
}

final appointmentRescheduleControllerProvider = StateNotifierProvider
    .autoDispose<AppointmentRescheduleController, AppointmentRescheduleState>(
  (ref) {
    return AppointmentRescheduleController(ref.read(hospitalServiceProvider));
  },
);
