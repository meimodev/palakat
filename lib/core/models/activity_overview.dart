import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/constants/constants.dart';

part 'activity_overview.freezed.dart';

part 'activity_overview.g.dart';

@freezed
class ActivityOverview  with _$ActivityOverview{
  const factory ActivityOverview({
    required String serial,
    required String title,
    required ActivityType type,
  }) = _ActivityOverview;

  factory ActivityOverview.fromJson(Map<String, dynamic> data) =>
      _$ActivityOverviewFromJson(data);
}
