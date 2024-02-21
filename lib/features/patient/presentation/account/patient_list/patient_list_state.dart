import 'package:halo_hermina/features/domain.dart';

class PatientListState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final List<Patient> patients;

  const PatientListState({
    this.page = 1,
    this.isLoadingMore = false,
    this.isLoading = true,
    this.hasMore = false,
    this.patients = const [],
  });

  PatientListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    List<Patient>? patients,
  }) {
    return PatientListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      patients: patients ?? this.patients,
    );
  }
}
