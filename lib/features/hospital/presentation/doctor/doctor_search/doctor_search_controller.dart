import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/model/model.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class DoctorSearchController extends StateNotifier<DoctorSearchState> {
  DoctorSearchController() : super(const DoctorSearchState()) {
    // DO SOMETHING
  }

  final specialistController = TextEditingController();
  final locationController = TextEditingController();
  final doctorController = TextEditingController();

  setSelectedSpecialist(SerialName value) {
    state = state.copyWith(specialist: value);
    specialistController.text = value.name;
  }

  setSelectedLocation(Location value) {
    state = state.copyWith(location: value);
    locationController.text = value.name;
  }
}

final doctorSearchControllerProvider = StateNotifierProvider.autoDispose<
    DoctorSearchController, DoctorSearchState>((ref) {
  return DoctorSearchController();
});
