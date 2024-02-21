import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class ChooseScheduleController extends StateNotifier<ChooseScheduleState> {
  ChooseScheduleController(this.hospitalService)
      : super(const ChooseScheduleState());
  final HospitalService hospitalService;

  void init(
    Doctor doctor,
    Hospital hospital,
    String specialistSerial,
  ) async {
    state = state.copyWith(
      doctor: doctor,
      hospital: hospital,
      specialistSerial: specialistSerial,
    );

    getDoctorPrice(
      doctor.serial,
      hospital.serial,
    );
  }

  void setHospital(Hospital value) {
    if (state.hospital?.serial != value.serial) {
      getDoctorPrice(
        state.doctor?.serial ?? "",
        state.hospital?.serial ?? "",
      );
    }

    state = state.copyWith(hospital: value);
  }

  Future<void> getDoctorPrice(
    String doctorSerial,
    String hospitalSerial,
  ) async {
    state = state.copyWith(
      isLoadingPrice: true,
    );

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

final chooseScheduleControllerProvider = StateNotifierProvider.autoDispose<
    ChooseScheduleController, ChooseScheduleState>((ref) {
  return ChooseScheduleController(ref.read(hospitalServiceProvider));
});
