import 'package:halo_hermina/features/food_menu_request/domain/enums/food_menu_segment_enum.dart';

class FoodMenuRequestWithCompanionState {
  final FoodMenuSegment selectedSegment;
  final String selectedMorningPatient;
  final String selectedAfternoonPatient;
  final String selectedEveningPatient;
  final String selectedMorningCompanion;
  final String selectedAfternoonCompanion;
  final String selectedEveningCompanion;

  const FoodMenuRequestWithCompanionState({
    required this.selectedSegment,
    this.selectedMorningPatient = "",
    this.selectedAfternoonPatient = "",
    this.selectedEveningPatient = "",
    this.selectedMorningCompanion = "",
    this.selectedAfternoonCompanion = "",
    this.selectedEveningCompanion = "",
  });

  FoodMenuRequestWithCompanionState copyWith({
    FoodMenuSegment? selectedSegment,
    String? selectedMorningPatient,
    String? selectedAfternoonPatient,
    String? selectedEveningPatient,
    String? selectedMorningCompanion,
    String? selectedAfternoonCompanion,
    String? selectedEveningCompanion,
  }) => FoodMenuRequestWithCompanionState(
      selectedSegment: selectedSegment ?? this.selectedSegment,
      selectedMorningPatient:
          selectedMorningPatient ?? this.selectedMorningPatient,
      selectedAfternoonPatient:
          selectedAfternoonPatient ?? this.selectedAfternoonPatient,
      selectedEveningPatient:
          selectedEveningPatient ?? this.selectedEveningPatient,
      selectedMorningCompanion:
          selectedMorningCompanion ?? this.selectedMorningCompanion,
      selectedAfternoonCompanion:
          selectedAfternoonCompanion ?? this.selectedAfternoonCompanion,
      selectedEveningCompanion:
          selectedEveningCompanion ?? this.selectedEveningCompanion,
    );

}
