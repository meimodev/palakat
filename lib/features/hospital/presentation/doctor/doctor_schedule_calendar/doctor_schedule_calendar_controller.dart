import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/network/network.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/presentation.dart';

class DoctorScheduleCalendarController
    extends StateNotifier<DoctorScheduleCalendarState> {
  DoctorScheduleCalendarController(this.hospitalService)
      : super(DoctorScheduleCalendarState());
  final HospitalService hospitalService;

  void init(
    String doctorSerial,
    String hospitalSerial,
  ) async {
    state = state.copyWith(
      doctorSerial: doctorSerial,
      hospitalSerial: hospitalSerial,
    );

    loadData();
  }

  void setDoctorSerial(String value) {
    state = state.copyWith(doctorSerial: value);

    loadData();
  }

  void setHospitalSerial(String value) {
    state = state.copyWith(hospitalSerial: value);

    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);

    final result = await hospitalService.getDoctorSchedule(
      DoctorScheduleRequest(
        doctorSerial: state.doctorSerial!,
        hospitalSerial: state.hospitalSerial!,
      ),
    );
    result.when(
      success: (data) {
        List<int> weekDay = DateUtil.replaceScheduleDayToWeekDays(
          data.map((e) => e.day).toList(),
        );

        state = state.copyWith(
          schedules: DateUtil.getDaysInNextNMonths(
            DateTime.now(),
            includeWeekDay: weekDay,
          ),
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

final doctorScheduleCalendarControllerProvider = StateNotifierProvider
    .autoDispose<DoctorScheduleCalendarController, DoctorScheduleCalendarState>(
  (ref) {
    return DoctorScheduleCalendarController(ref.read(hospitalServiceProvider));
  },
);
