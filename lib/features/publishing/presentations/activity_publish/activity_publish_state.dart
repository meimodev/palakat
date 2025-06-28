import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/constants/enums/enums.dart';

part 'activity_publish_state.freezed.dart';

@freezed
abstract class ActivityPublishState with _$ActivityPublishState {
  const factory ActivityPublishState({
    required ActivityType type,
    String? location,
    String? pinpointLocation,
    String? date,
    String? time,
    String? description,
    String? file,
    String? reminder,
    String? note,
    String? title,
    String? bipra,
    String? errorLocation,
    String? errorPinpointLocation,
    String? errorDate,
    String? errorTime,
    String? errorDescription,
    String? errorFile,
    String? errorReminder,
    String? errorNote,
    String? errorTitle,
    String? errorBipra,
    bool? loading,
    @Default(false) bool isFormValid,
  }) = _ActivityPublishState;
}
