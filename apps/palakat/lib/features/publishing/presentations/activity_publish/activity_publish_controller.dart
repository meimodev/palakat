import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/constants.dart';
import 'package:palakat_shared/extensions.dart';
import 'package:palakat_shared/models.dart';
import 'package:palakat_shared/repositories.dart';
import 'package:palakat_shared/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_publish_controller.g.dart';

@riverpod
class ActivityPublishController extends _$ActivityPublishController {
  @override
  ActivityPublishState build(ActivityType activityType) {
    return ActivityPublishState(type: activityType);
  }

  Future<void> validateForm() async {
    state = state.copyWith(loading: true);

    if (state.type == ActivityType.service ||
        state.type == ActivityType.event) {
      final locationError = validateLocation(state.location);
      final pinpointError = validatePinpointLocation(state.pinpointLocation);
      final dateError = validateDate(state.date);
      final timeError = validateTime(state.time);
      final reminderError = validateReminder(state.reminder);
      // final noteError = validateNote(state.note);
      final titleError = validateTitle(state.title);
      final bipraError = validateBipra(state.bipra);

      final isValid =
          locationError == null &&
          pinpointError == null &&
          dateError == null &&
          timeError == null &&
          reminderError == null &&
          // noteError == null &&
          titleError == null &&
          bipraError == null;

      state = state.copyWith(
        errorLocation: locationError,
        errorPinpointLocation: pinpointError,
        errorDate: dateError,
        errorTime: timeError,
        errorReminder: reminderError,
        // errorNote: noteError,
        errorTitle: titleError,
        errorBipra: bipraError,
        isFormValid: isValid,
      );
    }

    if (state.type == ActivityType.announcement) {
      final titleError = validateTitle(state.title);
      final descriptionError = validateDescription(state.description);
      final fileError = validateFile(state.file);
      final bipraError = validateBipra(state.bipra);

      final isValid =
          titleError == null &&
          descriptionError == null &&
          fileError == null &&
          bipraError == null;

      state = state.copyWith(
        errorTitle: titleError,
        errorDescription: descriptionError,
        errorFile: fileError,
        errorBipra: bipraError,
        isFormValid: isValid,
      );
    }

    await Future.delayed(const Duration(milliseconds: 400));
    state = state.copyWith(loading: false);
  }

  String? validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Location is required';
    }
    return null;
  }

  String? validatePinpointLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pinpoint location is required';
    }
    return null;
  }

  String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }
    return null;
  }

  String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time is required';
    }
    return null;
  }

  String? validateReminder(String? value) {
    if (value == null || value.isEmpty) {
      return 'Reminder is required';
    }
    return null;
  }

  String? validateNote(String? value) {
    if (value == null || value.isEmpty) {
      return 'Note is required';
    }
    return null;
  }

  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    return null;
  }

  String? validateFile(String? value) {
    if (value == null || value.isEmpty) {
      return 'File is required';
    }
    return null;
  }

  String? validateBipra(String? value) {
    if (value == null || value.isEmpty) {
      return 'Must be selected';
    }
    return null;
  }

  bool validateAnnouncement() {
    return validateTitle(state.title) == null &&
        validateDescription(state.description) == null &&
        validateFile(state.file) == null &&
        validateBipra(state.bipra) == null;
  }

  bool validateService() {
    return validateLocation(state.location) == null &&
        validateDate(state.date) == null &&
        validateTime(state.time) == null &&
        validateReminder(state.reminder) == null &&
        validateNote(state.note) == null &&
        validateTitle(state.title) == null &&
        validatePinpointLocation(state.pinpointLocation) == null &&
        validateBipra(state.bipra) == null;
  }

  /// Submits the activity creation form.
  /// Returns true on success, false on validation failure or API error.
  /// Requirements: 6.1, 6.2, 6.3, 6.4
  Future<bool> submit() async {
    // Step 1: Validate form first
    await validateForm();

    // Step 2: If invalid, return false
    if (!state.isFormValid) {
      return false;
    }

    // Step 3: Set loading state to true
    state = state.copyWith(loading: true, errorMessage: null);

    try {
      // Get the current membership for supervisorId
      final localStorage = ref.read(localStorageServiceProvider);
      final membership = localStorage.currentMembership;

      if (membership == null || membership.id == null) {
        state = state.copyWith(
          loading: false,
          errorMessage: 'Session expired. Please sign in again.',
        );
        return false;
      }

      // Step 4: Build CreateActivityRequest from state
      // Use selectedBipra directly instead of parsing from string
      final bipra = state.selectedBipra;
      if (bipra == null) {
        state = state.copyWith(
          loading: false,
          errorMessage: 'Invalid Bipra selection.',
        );
        return false;
      }

      // Combine selectedDate and selectedTime into a single DateTime
      DateTime? activityDate;
      if (state.selectedDate != null) {
        activityDate = state.selectedDate!;
        if (state.selectedTime != null) {
          activityDate = DateTime(
            state.selectedDate!.year,
            state.selectedDate!.month,
            state.selectedDate!.day,
            state.selectedTime!.hour,
            state.selectedTime!.minute,
          );
        }
      }

      // Get location data from selectedMapLocation
      final location = state.selectedMapLocation;

      final request = CreateActivityRequest(
        supervisorId: membership.id!,
        bipra: bipra,
        title: state.title ?? '',
        description: state.description,
        locationName: location?.name ?? state.location,
        locationLatitude: location?.latitude,
        locationLongitude: location?.longitude,
        date: activityDate,
        note: state.note,
        activityType: state.type,
      );

      // Step 5: Call ActivityRepository.createActivity
      final activityRepository = ref.read(activityRepositoryProvider);
      final result = await activityRepository.createActivity(request: request);

      // Step 6 & 7: Handle success/failure
      bool success = false;
      result.when(
        onSuccess: (_) {
          // Handle success: set loading false, return true
          state = state.copyWith(loading: false);
          success = true;
        },
        onFailure: (failure) {
          // Handle failure: set loading false, set errorMessage, return false
          state = state.copyWith(loading: false, errorMessage: failure.message);
          success = false;
        },
      );
      return success;
    } catch (e) {
      // Handle unexpected errors
      state = state.copyWith(
        loading: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  void publish() {}

  void onChangedBipra(String value) {
    state = state.copyWith(bipra: value, errorBipra: validateBipra(value));
  }

  void onSelectedBipra(Bipra? bipra) {
    if (bipra == null) return;
    state = state.copyWith(
      selectedBipra: bipra,
      bipra: bipra.name,
      errorBipra: null,
    );
  }

  void onChangedLocation(String value) {
    state = state.copyWith(
      location: value,
      errorLocation: validateLocation(value),
    );
  }

  void onChangedPinpointLocation(String value) {
    state = state.copyWith(
      pinpointLocation: value,
      errorPinpointLocation: validatePinpointLocation(value),
    );
  }

  void onSelectedMapLocation(Location? location) {
    if (location == null) return;
    final displayName = location.name.isNotEmpty
        ? location.name
        : '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}';
    state = state.copyWith(
      selectedMapLocation: location,
      pinpointLocation: displayName,
      errorPinpointLocation: null,
    );
  }

  void onChangedDate(String value) {
    state = state.copyWith(date: value, errorDate: validateDate(value));
  }

  void onSelectedDate(DateTime? date) {
    if (date == null) return;
    state = state.copyWith(
      selectedDate: date,
      date: date.EEEEddMMMyyyyShort,
      errorDate: null,
    );
  }

  void onChangedTime(String value) {
    state = state.copyWith(time: value, errorTime: validateTime(value));
  }

  void onSelectedTime(TimeOfDay? time) {
    if (time == null) return;
    final formattedTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    state = state.copyWith(
      selectedTime: time,
      time: formattedTime,
      errorTime: null,
    );
  }

  void onChangedDescription(String value) {
    state = state.copyWith(
      description: value,
      errorDescription: validateDescription(value),
    );
  }

  void onChangedFile(String value) {
    state = state.copyWith(file: value, errorFile: validateFile(value));
  }

  void onChangedReminder(String value) {
    state = state.copyWith(
      reminder: value,
      errorReminder: validateReminder(value),
    );
  }

  void onChangedNote(String value) {
    state = state.copyWith(note: value, errorNote: validateNote(value));
  }

  void onChangedTitle(String value) {
    state = state.copyWith(title: value, errorTitle: validateTitle(value));
  }

  /// Fetches author info from the signed-in account and updates state
  /// Requirements: 7.1, 7.2, 7.3
  Future<void> fetchAuthorInfo() async {
    final localStorage = ref.read(localStorageServiceProvider);
    final currentAuth = localStorage.currentAuth;

    if (currentAuth == null) {
      return;
    }

    final account = currentAuth.account;
    final authorName = account.name;

    // Try to get membership from currentMembership first, then fall back to account.membership
    final membership = localStorage.currentMembership ?? account.membership;

    // Get church name from membership if available
    final churchName = membership?.church?.name;

    // Get all position names
    final authorPositions =
        membership?.membershipPositions
            .map((p) => p.name)
            .whereType<String>()
            .toList() ??
        [];

    // Get column name
    final authorColumn = membership?.column?.name;

    // Get author's BIPRA category
    final authorBipra = account.calculateBipra;

    // Format current date using the date extension
    final currentDate = DateTime.now().EEEEddMMMyyyyShort;

    state = state.copyWith(
      authorName: authorName,
      churchName: churchName,
      authorPositions: authorPositions,
      authorColumn: authorColumn,
      authorBipra: authorBipra,
      currentDate: currentDate,
    );
  }

  void onSelectedReminder(Reminder? reminder) {
    if (reminder == null) return;
    state = state.copyWith(
      selectedReminder: reminder,
      reminder: reminder.name,
      errorReminder: null,
    );
  }
}
