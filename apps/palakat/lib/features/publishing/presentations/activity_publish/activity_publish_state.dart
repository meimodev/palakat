import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/location.dart';

part 'activity_publish_state.freezed.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class ActivityPublishState with _$ActivityPublishState {
  const factory ActivityPublishState({
    required ActivityType type,
    // Form fields
    String? bipra,
    Bipra? selectedBipra,
    String? title,
    String? location,
    String? pinpointLocation,
    Location? selectedMapLocation,
    String? date,
    DateTime? selectedDate,
    String? time,
    TimeOfDay? selectedTime,
    String? reminder,
    String? note,
    String? description,
    String? file,
    // Error messages for form fields
    String? errorBipra,
    String? errorTitle,
    String? errorLocation,
    String? errorPinpointLocation,
    String? errorDate,
    String? errorTime,
    String? errorReminder,
    String? errorNote,
    String? errorDescription,
    String? errorFile,
    // UI state
    @Default(false) bool loading,
    @Default(false) bool isFormValid,
    String? errorMessage,
    // Author info
    String? authorName,
    String? churchName,
    @Default([]) List<String> authorPositions,
    String? authorColumn,
    Bipra? authorBipra,
    String? currentDate,
    Reminder? selectedReminder,
  }) = _ActivityPublishState;
}
