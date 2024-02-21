class DoctorScheduleCalendarState {
  final bool isLoading;
  final List<DateTime> schedules;
  final String? doctorSerial;
  final String? hospitalSerial;

  DoctorScheduleCalendarState({
    this.isLoading = true,
    this.schedules = const [],
    this.doctorSerial,
    this.hospitalSerial,
  });

  DoctorScheduleCalendarState copyWith({
    bool? isLoading,
    List<DateTime>? schedules,
    String? doctorSerial,
    String? hospitalSerial,
  }) {
    return DoctorScheduleCalendarState(
      isLoading: isLoading ?? this.isLoading,
      schedules: schedules ?? this.schedules,
      doctorSerial: doctorSerial ?? this.doctorSerial,
      hospitalSerial: hospitalSerial ?? this.hospitalSerial,
    );
  }
}
