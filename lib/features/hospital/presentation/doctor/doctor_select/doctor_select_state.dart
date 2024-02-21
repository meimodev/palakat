class DoctorSelectState {
  final bool initScreen;
  DoctorSelectState({this.initScreen = false});
  DoctorSelectState copyWith({bool? initScreen}) {
    return DoctorSelectState(
      initScreen: initScreen ?? this.initScreen,
    );
  }
}
