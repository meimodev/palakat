import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/network/network.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/presentation.dart';

class SlotScheduleSelectController
    extends StateNotifier<SlotScheduleSelectState> {
  SlotScheduleSelectController(this.hospitalService)
      : super(SlotScheduleSelectState());
  final HospitalService hospitalService;

  void init(
    DateTime dateTime,
    String doctorSerial,
    String hospitalSerial,
    String specialistSerial,
  ) async {
    state = state.copyWith(
      dateTime: dateTime,
      doctorSerial: doctorSerial,
      hospitalSerial: hospitalSerial,
      specialistSerial: specialistSerial,
    );

    loadData();
  }

  void setSelectedIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);

    final result = await hospitalService.getDoctorHospitalSLot(
      DoctorHospitalSlotRequest(
        date: state.dateTime!,
        doctorSerial: state.doctorSerial!,
        hospitalSerial: state.hospitalSerial!,
        specialistSerial: state.specialistSerial!,
      ),
    );
    result.when(
      success: (data) {
        state = state.copyWith(
          times: data.times,
          isLoading: false,
        );
      },
      failure: (error, _) {
        state = state.copyWith(
          isLoading: false,
        );
        final message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);
      },
    );
  }
}

final slotScheduleSelectControllerProvider = StateNotifierProvider.autoDispose<
    SlotScheduleSelectController, SlotScheduleSelectState>(
  (ref) {
    return SlotScheduleSelectController(ref.read(hospitalServiceProvider));
  },
);
