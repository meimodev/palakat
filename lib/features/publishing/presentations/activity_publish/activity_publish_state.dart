import 'package:palakat/core/constants/enums/enums.dart';

class ActivityPublishState {
  final ActivityType type;
  final String? location;
  final String? pinpointLocation;
  final String? date;
  final String? time;
  final String? file;
  final String? title;
  final String? bipra;

  final String? errorLocation;
  final String? errorPinpointLocation;
  final String? errorDate;
  final String? errorTime;
  final String? errorFile;
  final String? errorTitle;
  final String? errorBipra;

  final bool isFormValid;

  ActivityPublishState({
    required this.type,
    this.location,
    this.pinpointLocation,
    this.date,
    this.time,
    this.file,
    this.title,
    this.bipra,
    this.errorLocation,
    this.errorPinpointLocation,
    this.errorDate,
    this.errorTime,
    this.errorFile,
    this.errorTitle,
    this.errorBipra,
    this.isFormValid = false,
  });
  ActivityPublishState copyWith({
    ActivityType? type,
    String? location,
    String? pinpointLocation,
    String? date,
    String? time,
    String? file,
    String? title,
    String? bipra,
    String? errorLocation,
    String? errorPinpointLocation,
    String? errorDate,
    String? errorTime,
    String? errorFile,
    String? errorTitle,
    String? errorBipra,
    bool? isFormValid,
  }) {
    return ActivityPublishState(
      type: type ?? this.type,
      location: location ?? this.location,
      pinpointLocation: pinpointLocation ?? this.pinpointLocation,
      date: date ?? this.date,
      time: time ?? this.time,
      file: file ?? this.file,
      title: title ?? this.title,
      bipra: bipra ?? this.bipra,
      errorLocation: errorLocation ?? this.errorLocation,
      errorPinpointLocation:
          errorPinpointLocation ?? this.errorPinpointLocation,
      errorDate: errorDate ?? this.errorDate,
      errorTime: errorTime ?? this.errorTime,
      errorFile: errorFile ?? this.errorFile,
      errorTitle: errorTitle ?? this.errorTitle,
      errorBipra: errorBipra ?? this.errorBipra,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}
