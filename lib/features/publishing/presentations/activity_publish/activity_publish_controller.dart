import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/activity.dart';
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


    if (state.type == ActivityType.service) {

    }

    if (state.type == ActivityType.event) {
    }

    if (state.type == ActivityType.announcement) {
    }

    // state = state.copyWith(
    //   errorLocation: locationError,
    //   errorPinpointLocation: pinpointLocationError,
    //   errorDate: dateError,
    //   errorTime: timeError,
    //   errorTitle: titleError,
    //   errorFile: fileError,
    //   errorBipra: bipraError,
    //   isFormValid: locationError == null &&
    //       pinpointLocationError == null &&
    //       dateError == null &&
    //       timeError == null &&
    //       titleError == null &&
    //       fileError == null &&
    //       bipraError == null,
    // );


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

  void onChangedFile(String value) {
    state = state.copyWith(file: value);
  }

  void onChangedTitle(String value) {
    state = state.copyWith(title: value);
  }
}
