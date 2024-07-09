// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart';

part 'activity.freezed.dart';

part 'activity.g.dart';

@freezed
class Activity with _$Activity {
  const factory Activity({
    required String serial,
    required String title,
    required ActivityType type,
    required Bipra bipra,
    @DateTimeConverterTimestamp()
    @JsonKey(name: "publish_date")
    required DateTime publishDate,
    @DateTimeConverterTimestamp()
    @JsonKey(name: "activity_date")
    required DateTime activityDate,
    @JsonKey(name: "account_serial") required String accountSerial,
    Account? account,
    @JsonKey(name: "church_serial") required String churchSerial,
    Church? church,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> data) =>
      _$ActivityFromJson(data);
}
