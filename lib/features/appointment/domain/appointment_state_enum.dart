enum AppointmentState { active, past, upcoming }

extension AppointmentStateExtension on AppointmentState {
  String get name {
    switch (this) {
      case AppointmentState.active:
        return 'ACTIVE';
      case AppointmentState.past:
        return 'PAST';
      case AppointmentState.upcoming:
        return 'UPCOMING';
    }
  }
}
