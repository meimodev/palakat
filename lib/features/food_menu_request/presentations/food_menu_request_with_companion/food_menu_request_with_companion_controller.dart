import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/food_menu_request/domain/enums/food_menu_segment_enum.dart';
import 'food_menu_request_with_companion_state.dart';

class FoodMenuRequestWithCompanionController
    extends StateNotifier<FoodMenuRequestWithCompanionState> {
  FoodMenuRequestWithCompanionController()
      : super(const FoodMenuRequestWithCompanionState(
          selectedSegment: FoodMenuSegment.patient,
        ));

  void setSelectedMorningPatient(String value) {
    state = state.copyWith(selectedMorningPatient: value);
  }

  void setSelectedAfternoonPatient(String value) {
    state = state.copyWith(selectedAfternoonPatient: value);
  }

  void setSelectedEveningPatient(String value) {
    state = state.copyWith(selectedEveningPatient: value);
  }

  void setSelectedMorningCompanion(String value) {
    state = state.copyWith(selectedMorningCompanion: value);
  }

  void setSelectedAfternoonCompanion(String value) {
    state = state.copyWith(selectedAfternoonCompanion: value);
  }

  void setSelectedEveningCompanion(String value) {
    state = state.copyWith(selectedEveningCompanion: value);
  }

  void setSegment(FoodMenuSegment segment) {
    state = state.copyWith(
      selectedSegment: segment,
    );
  }

  bool checkCanProceed() {
    return state.selectedMorningPatient.isNotEmpty &&
        state.selectedAfternoonPatient.isNotEmpty &&
        state.selectedEveningPatient.isNotEmpty &&
        state.selectedMorningCompanion.isNotEmpty &&
        state.selectedAfternoonCompanion.isNotEmpty &&
        state.selectedEveningCompanion.isNotEmpty;
  }

  Map<String, dynamic> patientMenu = {
    "morning": [
      {
        "package": "Set A Morning Patient",
        "descriptions": [
          "Savoury Rice, Galangal Chicken, Orek Tempeh, Veggies, Banana, Beef Blackpapper, Vegetable Soup, ",
          "Bread filled with Srikaya",
        ],
        "image":
            "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
      },
      {
        "package": "Set B Morning Patient",
        "descriptions": [
          "Savoury Rice, Galangal Chicken, Orek Tempeh, Veggies, Banana, Beef Blackpapper, Vegetable Soup, ",
          "Bread filled with Srikaya",
        ],
        "image":
            "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
      },
      {
        "package": "Set C Morning Patient",
        "descriptions": [
          "Savoury Rice, Galangal Chicken, Orek Tempeh, Veggies, Banana, Beef Blackpapper, Vegetable Soup, ",
          "Bread filled with Srikaya",
        ],
        "image":
            "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
      },
    ],
    "afternoon": [
      {
        "package": "Set A Afternoon Patient",
        "descriptions": [
          "Strawberry, Beef Black Pepper, Vegetable Soup",
          "Strawberry Pudding",
        ],
        "image":
            "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
      },
      {
        "package": "Set B Afternoon Patient",
        "descriptions": [
          "Strawberry, Beef Black Pepper, Vegetable Soup",
          "Strawberry Pudding",
        ],
        "image":
            "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
      },
      {
        "package": "Set C Afternoon Patient",
        "descriptions": [
          "Strawberry, Beef Black Pepper, Vegetable Soup",
          "Strawberry Pudding",
        ],
        "image":
            "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
      },
    ],
    "evening": [
      {
        "package": "Set A Evening Patient",
        "descriptions": [
          "Rice, Chicken Katsu with Cheese Sauce, Sauteed Vegetables",
          "Water Melon",
        ],
        "image":
            "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
      },
      {
        "package": "Set B Evening Patient",
        "descriptions": [
          "Rice, Chicken Katsu with Cheese Sauce, Sauteed Vegetables",
          "Water Melon",
        ],
        "image":
            "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
      },
      {
        "package": "Set C Evening Patient",
        "descriptions": [
          "Rice, Chicken Katsu with Cheese Sauce, Sauteed Vegetables",
          "Water Melon",
        ],
        "image":
            "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
      },
    ],
  };

  Map<String, dynamic> companionMenu = {
    "morning": [
      {
        "package": "Set A Morning Comp",
        "descriptions": [
          "Savoury Rice, Galangal Chicken, Orek Tempeh, Veggies, Banana, Beef Blackpapper, Vegetable Soup, ",
          "Bread filled with Srikaya",
        ],
        "image":
            "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
      },
      {
        "package": "Set B Morning Comp",
        "descriptions": [
          "Savoury Rice, Galangal Chicken, Orek Tempeh, Veggies, Banana, Beef Blackpapper, Vegetable Soup, ",
          "Bread filled with Srikaya",
        ],
        "image":
            "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
      },
      {
        "package": "Set C Morning Comp",
        "descriptions": [
          "Savoury Rice, Galangal Chicken, Orek Tempeh, Veggies, Banana, Beef Blackpapper, Vegetable Soup, ",
          "Bread filled with Srikaya",
        ],
        "image":
            "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
      },
    ],
    "afternoon": [
      {
        "package": "Set A Afternoon Comp",
        "descriptions": [
          "Strawberry, Beef Black Pepper, Vegetable Soup",
          "Strawberry Pudding",
        ],
        "image":
            "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
      },
      {
        "package": "Set B Afternoon Comp",
        "descriptions": [
          "Strawberry, Beef Black Pepper, Vegetable Soup",
          "Strawberry Pudding",
        ],
        "image":
            "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
      },
      {
        "package": "Set C Afternoon Comp",
        "descriptions": [
          "Strawberry, Beef Black Pepper, Vegetable Soup",
          "Strawberry Pudding",
        ],
        "image":
            "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
      },
    ],
    "evening": [
      {
        "package": "Set A Evening Comp",
        "descriptions": [
          "Rice, Chicken Katsu with Cheese Sauce, Sauteed Vegetables",
          "Water Melon",
        ],
        "image":
            "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
      },
      {
        "package": "Set B Evening Comp",
        "descriptions": [
          "Rice, Chicken Katsu with Cheese Sauce, Sauteed Vegetables",
          "Water Melon",
        ],
        "image":
            "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
      },
      {
        "package": "Set C Evening Comp",
        "descriptions": [
          "Rice, Chicken Katsu with Cheese Sauce, Sauteed Vegetables",
          "Water Melon",
        ],
        "image":
            "https://static.spotapps.co/spots/cd/ba90c6a8ae4d71b86c19f2859763c3/full"
      },
    ],
  };
}

final foodMenuRequestWithCompanionControllerProvider =
    StateNotifierProvider.autoDispose<FoodMenuRequestWithCompanionController,
        FoodMenuRequestWithCompanionState>((ref) {
  return FoodMenuRequestWithCompanionController();
});
