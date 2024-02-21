import 'package:halo_hermina/core/model/model.dart';
import 'package:halo_hermina/features/domain.dart';

class DoctorListState {
  final bool isLoading;
  final bool hasMore;
  final int page;
  final List<Doctor> doctors;
  final SerialName? specialist;
  final Location? location;
  final List<int> days;
  final List<Hospital>? hospitals;
  final String? gender;
  final String? searchText;
  final SerialName? tempSpecialist;
  final Location? tempLocation;
  final List<int> tempDays;
  final List<Hospital> tempHospitals;
  final String? tempGender;

  const DoctorListState({
    this.page = 1,
    this.isLoading = true,
    this.hasMore = false,
    this.doctors = const [],
    this.specialist,
    this.location,
    this.searchText,
    this.days = const [],
    this.hospitals = const [],
    this.gender,
    this.tempSpecialist,
    this.tempLocation,
    this.tempDays = const [],
    this.tempHospitals = const [],
    this.tempGender,
  });

  DoctorListState copyWith({
    bool? isLoading,
    bool? hasMore,
    int? page,
    List<Doctor>? doctors,
    SerialName? specialist,
    Location? location,
    List<int>? days,
    List<Hospital>? hospitals,
    String? searchText,
    String? gender,
    SerialName? tempSpecialist,
    Location? tempLocation,
    List<int>? tempDays,
    List<Hospital>? tempHospitals,
    String? tempGender,
  }) {
    return DoctorListState(
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      doctors: doctors ?? this.doctors,
      location: location ?? this.location,
      specialist: specialist ?? this.specialist,
      days: days ?? this.days,
      searchText: searchText ?? this.searchText,
      hospitals: hospitals ?? this.hospitals,
      gender: gender ?? this.gender,
      tempSpecialist: tempSpecialist ?? this.tempSpecialist,
      tempLocation: tempLocation ?? this.tempLocation,
      tempDays: tempDays ?? this.tempDays,
      tempHospitals: tempHospitals ?? this.tempHospitals,
      tempGender: tempGender ?? this.tempGender,
    );
  }
}
