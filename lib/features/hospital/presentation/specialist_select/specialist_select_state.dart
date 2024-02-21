class SpecialistSelectState {
  final bool initScreen;
  SpecialistSelectState({this.initScreen = false});
  SpecialistSelectState copyWith({bool? initScreen}) {
    return SpecialistSelectState(
      initScreen: initScreen ?? this.initScreen,
    );
  }
}
