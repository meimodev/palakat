class AppointmentTypeSelectState {
  final bool initScreen;
  AppointmentTypeSelectState({this.initScreen = false});
  AppointmentTypeSelectState copyWith({bool? initScreen}) {
    return AppointmentTypeSelectState(
      initScreen: initScreen ?? this.initScreen,
    );
  }
}
