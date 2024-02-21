import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:halo_hermina/features/patient/domain/enum/enum.dart';

class PatientPortalListActiveHistoryController
    extends StateNotifier<PatientPortalListActiveHistoryState> {
  PatientPortalListActiveHistoryController()
      : super(
          const PatientPortalListActiveHistoryState(
            activeTab: PatientPortalListActiveHistoryTab.active,
            activePatient: "First Patient",
          ),
        );

  void setActiveTab(PatientPortalListActiveHistoryTab tab) {
    state = state.copyWith(activeTab: tab);
  }

  void setActivePatient(String patientName) {
    state = state.copyWith(activePatient: patientName);
  }
}

final patientPortalListActiveHistoryControllerProvider =
    StateNotifierProvider.autoDispose<PatientPortalListActiveHistoryController,
        PatientPortalListActiveHistoryState>((ref) {
  return PatientPortalListActiveHistoryController();
});

final filteredPatientPortalListActiveHistoryControllerProvider = Provider
    .autoDispose
    .family<List<Map<String, dynamic>>, List<Map<String, dynamic>>>(
        (ref, admissions) {
  final controller =
      ref.watch(patientPortalListActiveHistoryControllerProvider);

  return admissions
      .where(
        (e) =>
            e["name"].toString().toLowerCase() ==
            controller.activePatient.toLowerCase(),
      )
      .toList();
});
