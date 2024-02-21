class PatientSelectState {
  final bool initScreen;
  PatientSelectState({this.initScreen = false});
  PatientSelectState copyWith({bool? initScreen}) {
    return PatientSelectState(
      initScreen: initScreen ?? this.initScreen,
    );
  }
}
