import 'package:halo_hermina/features/patient/domain/enum/enum.dart';

class PatientPortalAdmissionDetailState {
  final PatientPortalAdmissionDetailScreenTabEnum activeTab;

  PatientPortalAdmissionDetailState({required this.activeTab});

  PatientPortalAdmissionDetailState copyWith(
          {PatientPortalAdmissionDetailScreenTabEnum? activeTab}) =>
      PatientPortalAdmissionDetailState(
        activeTab: activeTab ?? this.activeTab,
      );
}
