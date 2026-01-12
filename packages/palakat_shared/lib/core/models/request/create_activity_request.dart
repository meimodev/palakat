import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';

part 'create_activity_request.freezed.dart';
part 'create_activity_request.g.dart';

DateTime? _createActivityRequestDateFromJson(dynamic value) {
  if (value == null) return null;
  return DateTime.parse(value as String);
}

String? _createActivityRequestDateToJson(DateTime? value) {
  return value?.toUtc().toIso8601String();
}

/// Finance data to create alongside activity
@freezed
abstract class CreateActivityFinance with _$CreateActivityFinance {
  const factory CreateActivityFinance({
    /// Type of finance record: 'REVENUE' or 'EXPENSE'
    required String type,

    /// The account number string
    required String accountNumber,

    /// The amount in the smallest currency unit
    required int amount,

    /// The payment method
    required PaymentMethod paymentMethod,

    /// Optional ID of the financial account number record
    int? financialAccountNumberId,
  }) = _CreateActivityFinance;

  factory CreateActivityFinance.fromJson(Map<String, dynamic> json) =>
      _$CreateActivityFinanceFromJson(json);
}

/// Request model for creating a new activity.
/// Used by ActivityRepository.createActivity method.
@freezed
abstract class CreateActivityRequest with _$CreateActivityRequest {
  const factory CreateActivityRequest({
    /// The membership ID of the supervisor creating the activity
    required int supervisorId,

    bool? publishToColumnOnly,

    /// The target demographic group for the activity
    Bipra? bipra,

    /// The title of the activity
    required String title,

    /// Optional description (required for ANNOUNCEMENT type)
    String? description,

    /// Location name (required for SERVICE/EVENT types)
    String? locationName,

    /// Location latitude (required for SERVICE/EVENT types)
    double? locationLatitude,

    /// Location longitude (required for SERVICE/EVENT types)
    double? locationLongitude,

    /// Optional date for the activity (required for SERVICE/EVENT types)
    @JsonKey(
      fromJson: _createActivityRequestDateFromJson,
      toJson: _createActivityRequestDateToJson,
    )
    DateTime? date,

    /// Optional note for additional information
    String? note,

    int? fileId,

    /// The type of activity being created
    required ActivityType activityType,

    /// Optional reminder preference for SERVICE/EVENT activities
    Reminder? reminder,

    /// Optional finance record to create alongside the activity
    CreateActivityFinance? finance,
  }) = _CreateActivityRequest;

  factory CreateActivityRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateActivityRequestFromJson(json);
}
