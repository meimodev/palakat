import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/approver.dart';
import 'package:palakat_shared/core/models/location.dart';
import 'package:palakat_shared/core/models/membership.dart';

part 'activity.freezed.dart';

part 'activity.g.dart';

@freezed
abstract class Activity with _$Activity {
  const factory Activity({
    int? id,
    int? supervisorId,
    Bipra? bipra,
    required String title,
    String? description,
    int? locationId,
    required DateTime date,
    String? note,
    String? fileUrl,
    @Default(ActivityType.service) ActivityType activityType,
    required DateTime createdAt,
    DateTime? updatedAt,
    required Membership supervisor,
    required List<Approver> approvers,
    Location? location,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
}
