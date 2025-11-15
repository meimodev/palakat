import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/models/account.dart';
import 'package:palakat_shared/core/models/church.dart';
import 'package:palakat_shared/core/models/column.dart';
import 'package:palakat_shared/core/models/member_position.dart';

part 'membership.freezed.dart';

part 'membership.g.dart';

@freezed
abstract class Membership with _$Membership {
  const factory Membership({
    int? id,
    @Default(false) bool baptize,
    @Default(false) bool sidi,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default([]) List<MemberPosition> membershipPositions,
    Church? church,
    Column? column,
    Account? account,
  }) = _Membership;

  factory Membership.fromJson(Map<String, dynamic> json) =>
      _$MembershipFromJson(json);
}
