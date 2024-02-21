import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/presentation.dart';

class PatientDetailController extends StateNotifier<PatientDetailState> {
  final BuildContext context;
  final PatientService patientService;

  PatientDetailController(this.context, this.patientService)
      : super(const PatientDetailState());

  void init(String serial) {
    state = state.copyWith(serial: serial);

    getData();
  }

  Future handleRefresh() async {
    await getData(withLoading: false);
  }

  Future getData({bool withLoading = true}) async {
    if (withLoading) state = state.copyWith(isLoading: true);

    var result = await patientService.getPatientUserBySerial(
      state.serial ?? "",
    );

    result.when(
      success: (response) {
        state = state.copyWith(
          isLoading: false,
          patient: response,
        );

        return true;
      },
      failure: (error, _) {
        state = state.copyWith(
          isLoading: false,
        );
        var message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);

        return false;
      },
    );
  }
}

final patientDetailControllerProvider = StateNotifierProvider.family
    .autoDispose<PatientDetailController, PatientDetailState, BuildContext>(
  (ref, context) {
    return PatientDetailController(context, ref.read(patientServiceProvider));
  },
);
