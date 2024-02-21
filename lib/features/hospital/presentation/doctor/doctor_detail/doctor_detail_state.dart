import 'package:halo_hermina/features/domain.dart';

class DoctorDetailState {
  final DoctorDetailSegment? selectedSegment;
  final String? serial;
  final bool isLoading;
  final bool isLoadingSchedule;
  final Doctor? doctor;
  final List<DoctorHospitalSchedule> schedules;

  const DoctorDetailState({
    this.selectedSegment,
    this.serial,
    this.isLoading = true,
    this.isLoadingSchedule = true,
    this.doctor,
    this.schedules = const [],
  });

  DoctorDetailState copyWith({
    DoctorDetailSegment? selectedSegment,
    String? serial,
    bool? isLoading,
    bool? isLoadingSchedule,
    Doctor? doctor,
    List<DoctorHospitalSchedule>? schedules,
  }) {
    return DoctorDetailState(
      selectedSegment: selectedSegment ?? this.selectedSegment,
      serial: serial ?? this.serial,
      isLoading: isLoading ?? this.isLoading,
      isLoadingSchedule: isLoadingSchedule ?? this.isLoadingSchedule,
      doctor: doctor ?? this.doctor,
      schedules: schedules ?? this.schedules,
    );
  }
}

enum DoctorDetailSegment { schedule, profile }
