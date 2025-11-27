import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';

part 'create_activity_request.freezed.dart';
part 'create_activity_request.g.dart';

/// Request model for creating a new activity.
/// Used by ActivityRepository.createActivity method.
@freezed
abstract class CreateActivityRequest with _$CreateActivityRequest {
  const factory CreateActivityRequest({
    /// The membership ID of the supervisor creating the activity
    required int supervisorId,

    /// The target demographic group for the activity
    required Bipra bipra,

    /// The title of the activity
    required String title,

    /// Optional description (required for ANNOUNCEMENT type)
    String? description,

    /// Optional location ID (required for SERVICE/EVENT types)
    int? locationId,

    /// Optional date for the activity (required for SERVICE/EVENT types)
    DateTime? date,

    /// Optional note for additional information
    String? note,

    /// The type of activity being created
    required ActivityType activityType,
  }) = _CreateActivityRequest;

  factory CreateActivityRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateActivityRequestFromJson(json);
}
