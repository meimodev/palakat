import 'package:halo_hermina/core/model/model.dart';
import 'package:halo_hermina/features/domain.dart';

class DoctorSearchState {
  final SerialName? specialist;
  final Doctor? doctor;
  final Location? location;

  const DoctorSearchState({
    this.specialist,
    this.doctor,
    this.location,
  });

  DoctorSearchState copyWith({
    SerialName? specialist,
    Doctor? doctor,
    Location? location,
  }) {
    return DoctorSearchState(
      specialist: specialist ?? this.specialist,
      doctor: doctor ?? this.doctor,
      location: location ?? this.location,
    );
  }
}
