import 'package:halo_hermina/features/patient/domain/enum/enum.dart';

class PatientPortalListActiveHistoryState {
  final PatientPortalListActiveHistoryTab activeTab;
  final String activePatient;

  const PatientPortalListActiveHistoryState({
    required this.activeTab,
    required this.activePatient,
  });

  PatientPortalListActiveHistoryState copyWith({
    PatientPortalListActiveHistoryTab? activeTab,
    String? activePatient,
  }) {
    return PatientPortalListActiveHistoryState(
      activeTab: activeTab ?? this.activeTab,
      activePatient: activePatient ?? this.activePatient,
    );
  }
}
