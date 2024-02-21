import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class PatientPickerDialogController
    extends StateNotifier<PatientPickerDialogState> {
  final PatientService patientService;
  final BuildContext context;
  PatientPickerDialogController(this.patientService, this.context)
      : super(const PatientPickerDialogState());

  void init(Patient? value) async {
    state = state.copyWith(selected: value);

    loadData();
  }

  Future handleRefresh() async {
    await loadData();
  }

  void setSelectedPatient(Patient value) {
    state = state.copyWith(selected: value);
  }

  Future<void> loadData({bool withLoading = false}) async {
    if (withLoading) state = state.copyWith(isLoading: true);

    final result = await patientService.getPatientUsers(
      const PaginationRequest(
        page: 1,
        pageSize: 100,
      ),
    );

    result.when(
      success: (response) {
        state = state.copyWith(
          data: response.data,
          isLoading: false,
        );
      },
      failure: (error, _) {
        final message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);
      },
    );
  }
}

final patientPickerDialogControllerProvider = StateNotifierProvider.family<
    PatientPickerDialogController, PatientPickerDialogState, BuildContext>(
  (ref, context) {
    return PatientPickerDialogController(
      ref.read(patientServiceProvider),
      context,
    );
  },
);
