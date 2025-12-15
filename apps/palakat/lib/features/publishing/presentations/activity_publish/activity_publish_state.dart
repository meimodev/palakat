import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/finance_data.dart';
import 'package:palakat_shared/core/models/location.dart';

part 'activity_publish_state.freezed.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class ActivityPublishState with _$ActivityPublishState {
  const factory ActivityPublishState({
    required ActivityType type,
    // Form fields
    @Default(false) bool publishToColumnOnly,
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
    // File path for upload (stores the actual file path)
    String? filePath,
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
    // Attached finance data (revenue or expense)
    // Requirements: 1.4, 5.1
    FinanceData? attachedFinance,
  }) = _ActivityPublishState;
}
