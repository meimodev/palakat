import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/membership.dart';

part 'account.freezed.dart';

part 'account.g.dart';

@freezed
abstract class Account with _$Account {
  // ignore: invalid_annotation_target
  @JsonSerializable(includeIfNull: false)
  factory Account({
    int? id,
    required String name,
    required String phone,
    String? email,
    @Default(Gender.male) Gender gender,
    @Default(MaritalStatus.single) MaritalStatus maritalStatus,
    required DateTime dob,
    @Default(false) bool claimed,
    DateTime? createdAt,
    DateTime? updatedAt,
    Membership? membership,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}

