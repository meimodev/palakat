import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/presentation.dart';
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
      final noteError = validateNote(state.note);
      final titleError = validateTitle(state.title);
      final bipraError = validateBipra(state.bipra);

      final isValid = locationError == null &&
          pinpointError == null &&
          dateError == null &&
          timeError == null &&
          reminderError == null &&
          noteError == null &&
          titleError == null &&
          bipraError == null;

      state = state.copyWith(
        errorLocation: locationError,
        errorPinpointLocation: pinpointError,
        errorDate: dateError,
        errorTime: timeError,
        errorReminder: reminderError,
        errorNote: noteError,
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

      final isValid = titleError == null &&
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
      return BaseTranslation.locationRequired;
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

  Future<bool> submit() async {
    await validateForm();
    if (state.isFormValid) {
      print("Input Valid");
      return true;
    }
    return false;
  }

  void publish() {}

  void onChangedBipra(String value) {
    state = state.copyWith(bipra: value);
  }

  void onChangedLocation(String value) {
    state = state.copyWith(location: value);
  }

  void onChangedPinpointLocation(String value) {
    state = state.copyWith(pinpointLocation: value);
  }

  void onChangedDate(String value) {
    state = state.copyWith(date: value);
  }

  void onChangedTime(String value) {
    state = state.copyWith(time: value);
  }

  void onChangedDescription(String value) {
    state = state.copyWith(description: value);
  }

  void onChangedFile(String value) {
    state = state.copyWith(file: value);
  }

  void onChangedReminder(String value) {
    state = state.copyWith(reminder: value);
  }

  void onChangeNote(String value) {
    state = state.copyWith(note: value);
  }

  void onChangedTitle(String value) {
    state = state.copyWith(title: value);
  }
}
