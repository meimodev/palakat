import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/utils/debounce.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class DoctorAutocompleteController
    extends StateNotifier<DoctorAutocompleteState> {
  DoctorAutocompleteController(this.hospitalService)
      : super(const DoctorAutocompleteState());
  final HospitalService hospitalService;
  final Debounce debounce = Debounce(const Duration(milliseconds: 300));

  void init(List<String>? hospital, List<String>? specialist) {
    state = state.copyWith(
      hospitalSerial: hospital,
      specialistSerial: specialist,
    );
  }

  void handleClick(Doctor doctor) {
    state = state.copyWith(doctors: []);
  }

  void onChanged(String value) {
    if (value.isNotEmpty && value.length >= 3) {
      debounce.call(() {
        loadData(value);
      });
    }
  }

  void setHospital(List<String>? value) {
    state = state.copyWith(hospitalSerial: value);
  }

  void setSpecialist(List<String>? value) {
    state = state.copyWith(specialistSerial: value);
  }

  FutureOr<List<Doctor>> handleOptions(
    TextEditingValue textEditingValue,
  ) async {
    return await loadData(textEditingValue.text);
  }

  Future<List<Doctor>> loadData(String keyword) async {
    state = state.copyWith(isLoading: true);

    final result = await hospitalService.getDoctors(
      DoctorListRequest(
        page: 1,
        pageSize: 1,
        search: keyword,
        hospitalSerial: state.hospitalSerial,
        specialistSerial: state.specialistSerial,
      ),
    );

    return result.when<List<Doctor>>(
      success: (response) {
        state = state.copyWith(
          doctors: response.data,
          isLoading: false,
        );
        return response.data;
      },
      failure: (error, _) {
        state = state.copyWith(
          isLoading: false,
        );

        final message = NetworkExceptions.getErrorMessage(error);
        Snackbar.error(message: message);

        return [];
      },
    );
  }
}

final doctorAutocompleteControllerProvider = StateNotifierProvider.autoDispose<
    DoctorAutocompleteController, DoctorAutocompleteState>((ref) {
  return DoctorAutocompleteController(ref.read(hospitalServiceProvider));
});
