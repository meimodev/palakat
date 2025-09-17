// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/models/models.dart';

part 'membership.freezed.dart';

part 'membership.g.dart';

@freezed
abstract class Membership with _$Membership {
  const factory Membership({
    required int id,
    required int accountId,
    required int churchId,
    required int columnId,
    required bool baptize,
    required bool sidi,
    @Default([]) List<MemberPosition> membershipPositions,
    Account? account,
    Church? church,
    Column? column,
  }) = _Membership;

  factory Membership.fromJson(Map<String, dynamic> json) =>
      _$MembershipFromJson(json);
}
