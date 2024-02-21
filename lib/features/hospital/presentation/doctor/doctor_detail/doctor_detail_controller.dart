import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/widgets/snackbar/snackbar_widget.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/presentation.dart';

class DoctorDetailController extends StateNotifier<DoctorDetailState> {
  DoctorDetailController(this.hospitalService, this.authService)
      : super(const DoctorDetailState()) {
    // DO SOMETHING
  }
  final HospitalService hospitalService;
  final AuthenticationService authService;

  void init(String serial) {
    state = state.copyWith(serial: serial);

    getData();
    getSchedule();
  }

  Future handleRefresh() async {
    await Future.wait([
      getData(withoutLoading: true),
      getSchedule(withoutLoading: true),
    ]);
  }

  Future<void> getData({bool withoutLoading = false}) async {
    if (!withoutLoading) state = state.copyWith(isLoading: true);

    var result = await hospitalService.getDoctorBySerial(state.serial ?? "");

    await result.when(
      success: (data) async {
        state = state.copyWith(
          isLoading: false,
          doctor: data,
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

  Future<void> getSchedule({bool withoutLoading = false}) async {
    if (!withoutLoading) state = state.copyWith(isLoadingSchedule: true);

    var result =
        await hospitalService.getDoctorHospitalSchedule(state.serial ?? "");

    await result.when(
      success: (data) async {
        state = state.copyWith(
          isLoadingSchedule: false,
          schedules: data,
        );
      },
      failure: (error, stackTrace) {
        state = state.copyWith(
          isLoadingSchedule: false,
        );

        var message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);
      },
    );
  }
}

final doctorDetailControllerProvider = StateNotifierProvider.autoDispose<
    DoctorDetailController, DoctorDetailState>((ref) {
  return DoctorDetailController(ref.read(hospitalServiceProvider),
      ref.read(authenticationServiceProvider));
});
