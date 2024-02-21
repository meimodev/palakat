import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/patient/domain/enum/enum.dart';
import 'package:halo_hermina/features/presentation.dart';

class PatientPortalAdmissionDetailController
    extends StateNotifier<PatientPortalAdmissionDetailState> {
  PatientPortalAdmissionDetailController()
      : super(
          PatientPortalAdmissionDetailState(
            activeTab: PatientPortalAdmissionDetailScreenTabEnum.laboratory,
          ),
        );

  void setActiveTab(PatientPortalAdmissionDetailScreenTabEnum tab) {
    state = state.copyWith(activeTab: tab);
  }
}

final patientPortalAdmissionDetailControllerProvider =
    StateNotifierProvider.autoDispose<PatientPortalAdmissionDetailController,
        PatientPortalAdmissionDetailState>((ref) {
  return PatientPortalAdmissionDetailController();
});
