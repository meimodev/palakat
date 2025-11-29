import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_screen_state_counts.freezed.dart';
part 'member_screen_state_counts.g.dart';

/// Counts for member statistics displayed on the member screen.
@freezed
abstract class MemberScreenStateCounts with _$MemberScreenStateCounts {
  const factory MemberScreenStateCounts({
    @Default(0) int total,
    @Default(0) int claimed,
    @Default(0) int baptized,
    @Default(0) int sidi,
  }) = _MemberScreenStateCounts;

  factory MemberScreenStateCounts.fromJson(Map<String, dynamic> json) =>
      _$MemberScreenStateCountsFromJson(json);
}
