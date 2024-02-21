class SlotScheduleSelectState {
  final bool initScreen;
  final bool isLoading;
  final int selectedIndex;
  final List<String> times;
  final String? doctorSerial;
  final String? hospitalSerial;
  final String? specialistSerial;
  final DateTime? dateTime;

  SlotScheduleSelectState({
    this.initScreen = false,
    this.isLoading = true,
    this.selectedIndex = -1,
    this.times = const [],
    this.doctorSerial,
    this.hospitalSerial,
    this.specialistSerial,
    this.dateTime,
  });

  SlotScheduleSelectState copyWith({
    bool? initScreen,
    bool? isLoading,
    int? selectedIndex,
    List<String>? times,
    String? doctorSerial,
    String? hospitalSerial,
    String? specialistSerial,
    DateTime? dateTime,
  }) {
    return SlotScheduleSelectState(
      isLoading: isLoading ?? this.isLoading,
      initScreen: initScreen ?? this.initScreen,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      times: times ?? this.times,
      doctorSerial: doctorSerial ?? this.doctorSerial,
      hospitalSerial: hospitalSerial ?? this.hospitalSerial,
      specialistSerial: specialistSerial ?? this.specialistSerial,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
