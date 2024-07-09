// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/constants/enums/enums.dart';
import 'package:palakat/core/models/models.dart';

part 'membership.freezed.dart';

part 'membership.g.dart';

@freezed
class Membership with _$Membership {
  const factory Membership({
    @Default("") String serial,
    @JsonKey(name: "account_serial") @Default("") String accountSerial,
    @JsonKey(name: "church_serial") @Default("") String churchSerial,
    @JsonKey(name: "column_serial") @Default("") String columnSerial,
    @Default(false) bool baptize,
    @Default(false) bool sidi,
    @Default(Bipra.general) Bipra bipra,
    Account? account,
    Church? church,
    Column? column,
  }) = _Membership;

  factory Membership.fromJson(Map<String, dynamic> data) =>
      _$MembershipFromJson(data);
}
