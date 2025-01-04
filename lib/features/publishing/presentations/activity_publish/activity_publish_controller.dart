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

  void validateForm() {
    String? locationError = validateLocation(state.location);
    String? pinpointLocationError =
        validatePinpointLocation(state.pinpointLocation);
    String? dateError = validateDate(state.date);
    String? timeError = validateTime(state.time);
    String? titleError = validateTitle(state.title);
    String? fileError = validateFile(state.file);
    String? bipraError = validateBipra(state.bipra);

    state = state.copyWith(
      errorLocation: locationError,
      errorPinpointLocation: pinpointLocationError,
      errorDate: dateError,
      errorTime: timeError,
      errorTitle: titleError,
      errorFile: fileError,
      errorBipra: bipraError,
      isFormValid: locationError == null &&
          pinpointLocationError == null &&
          dateError == null &&
          timeError == null &&
          titleError == null &&
          fileError == null &&
          bipraError == null,
    );
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

  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
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
        validateFile(state.file) == null &&
        validateBipra(state.bipra) == null;
  }

  bool validateService() {
    return validateLocation(state.location) == null &&
        validateDate(state.date) == null &&
        validateTime(state.time) == null &&
        validateTitle(state.title) == null &&
        validatePinpointLocation(state.pinpointLocation) == null &&
        validateBipra(state.bipra) == null;
  }

  Future<bool> submit() async {
    return true;
  }
}
