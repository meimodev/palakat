import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart';

part 'activity.freezed.dart';

part 'activity.g.dart';

@freezed
abstract class Activity with _$Activity {
  const factory Activity({
    required int id,
    required int supervisorId,
    required Bipra bipra,
    required String title,
    String? description,
    @DateTimeConverterTimestamp() required DateTime date,
    String? note,
    String? fileUrl,
    required ActivityType type,
    @DateTimeConverterTimestamp() required DateTime createdAt,
    @DateTimeConverterTimestamp() required DateTime updatedAt,
    required Membership supervisor,
    required List<Approver> approvers,
    int? locationId,
    Location? location,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> data) =>
      _$ActivityFromJson(data);
}
